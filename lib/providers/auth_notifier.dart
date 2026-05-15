/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart' show Provider;
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:version/version.dart';
import 'package:wger/core/exceptions/http_exception.dart';
import 'package:wger/database/powersync/powersync.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/jwt.dart';
import 'package:wger/helpers/shared_preferences.dart';
import 'package:wger/providers/auth_state.dart';
import 'package:wger/providers/gallery_notifier.dart';
import 'package:wger/providers/helpers.dart';
import 'package:wger/providers/nutrition_notifier.dart';
import 'package:wger/providers/routines_notifier.dart';
import 'package:wger/providers/secure_token_storage.dart';
import 'package:wger/providers/trophy_notifier.dart';
import 'package:wger/providers/user_profile_notifier.dart';

part 'auth_notifier.g.dart';

const MIN_APP_VERSION_URL = 'min-app-version';
const SERVER_VERSION_URL = 'version';
const REGISTRATION_URL = 'register';
const LOGIN_URL = 'login';
const USERPROFILE_URL = 'userprofile';

/// `allauth.headless` `app` client refresh endpoint, relative to the
/// `/_allauth/app/v1/` base.
const HEADLESS_TOKENS_REFRESH_PATH = 'tokens/refresh';

/// HTTP client used by the auth notifier. Override in tests.
final authHttpClientProvider = Provider<http.Client>((ref) => http.Client());

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  final _logger = Logger('AuthNotifier');
  late http.Client _client;

  /// Holds the in-flight refresh future so concurrent callers share a single
  /// network roundtrip. Cleared in `whenComplete` so the next refresh starts
  /// a fresh request.
  Future<void>? _refreshInFlight;

  @override
  Future<AuthState> build() async {
    _client = ref.read(authHttpClientProvider);
    return _tryAutoLogin();
  }

  /// Registers a new user and logs in.
  Future<LoginActions> register({
    required String username,
    required String password,
    required String email,
    required String serverUrl,
    String locale = 'en',
  }) async {
    final appVersion = _currentOrBlank().applicationVersion ?? await PackageInfo.fromPlatform();
    final data = <String, String>{
      'username': username,
      'password': password,
    };
    if (email.isNotEmpty) {
      data['email'] = email;
    }
    final response = await _client.post(
      makeUri(serverUrl, REGISTRATION_URL),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.userAgentHeader: getAppNameHeader(appVersion),
        HttpHeaders.acceptLanguageHeader: locale,
      },
      body: json.encode(data),
    );

    if (response.statusCode >= 400) {
      throw WgerHttpException(response);
    }

    return login(username, password, serverUrl, null);
  }

  /// Authenticates a user (by password or API token).
  Future<LoginActions> login(
    String username,
    String password,
    String serverUrl,
    String? apiToken,
  ) async {
    final appVersion = _currentOrBlank().applicationVersion ?? await PackageInfo.fromPlatform();
    final String token;

    if (apiToken != null && apiToken.isNotEmpty) {
      final response = await _client.get(
        makeUri(serverUrl, USERPROFILE_URL),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
          HttpHeaders.userAgentHeader: getAppNameHeader(appVersion),
          HttpHeaders.authorizationHeader: 'Token $apiToken',
        },
      );

      if (response.statusCode >= 400) {
        throw WgerHttpException(response);
      }
      token = apiToken;
    } else {
      final response = await _client.post(
        makeUri(serverUrl, LOGIN_URL),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
          HttpHeaders.userAgentHeader: getAppNameHeader(appVersion),
        },
        body: json.encode({'username': username, 'password': password}),
      );

      if (response.statusCode >= 400) {
        throw WgerHttpException(response);
      }

      token = json.decode(response.body)['token'];
    }

    // Persist login before the update-gate checks, matching legacy behavior.
    final prefs = PreferenceHelper.asyncPref;
    await prefs.setString(
      PREFS_USER,
      json.encode({'token': token, 'serverUrl': serverUrl}),
    );
    await prefs.setString(
      PREFS_LAST_SERVER,
      json.encode({'serverUrl': serverUrl}),
    );

    // Both branches above produce a legacy permanent DRF token; the headless
    // JWT login path is added in a later step.
    const tokenType = AuthTokenType.legacyApiToken;

    var newState = await _resolveAuthState(
      token: token,
      tokenType: tokenType,
      serverUrl: serverUrl,
      appVersion: appVersion,
    );

    if (newState.status == AuthStatus.loggedIn &&
        !await _serverConfigSane(serverUrl, token, tokenType)) {
      newState = newState.copyWith(serverConfigWarning: true);
    }

    state = AsyncData(newState);

    if (newState.status == AuthStatus.loggedIn) {
      // If PowerSync was already running from a previous session, swap its
      // connector so it picks up the new user's credentials.
      await _reconnectPowerSyncIfBuilt(serverUrl);
      _invalidatePostLoginProviders();
    }

    return switch (newState.status) {
      AuthStatus.serverUpdateRequired || AuthStatus.updateRequired => LoginActions.update,
      _ => LoginActions.proceed,
    };
  }

  /// Clears the server config warning flag — called from the auth screen after
  /// the corresponding warning dialog has been shown to the user, so it doesn't
  /// re-appear on the next state read.
  void clearServerConfigWarning() {
    final current = state.asData?.value;
    if (current != null && current.serverConfigWarning) {
      state = AsyncData(current.copyWith(serverConfigWarning: false));
    }
  }

  /// Builds the `Authorization` header value for the given credential.
  ///
  /// Legacy permanent DRF tokens use `Token <key>`; headless-issued JWTs use
  /// `Bearer <jwt>`. Centralised here so every outgoing call inside the
  /// notifier picks the right scheme without callers having to know the
  /// token kind.
  static String _authHeader(String token, AuthTokenType type) => switch (type) {
    AuthTokenType.legacyApiToken => 'Token $token',
    AuthTokenType.headlessJwt => 'Bearer $token',
  };

  /// Detects reverse-proxy misconfiguration on the wger server: pagination
  /// URLs returned by the API should point to the same host and scheme as the
  /// configured [serverUrl]. Returns `true` when the configuration looks fine
  /// (or the check could not be completed conclusively).
  Future<bool> _serverConfigSane(String serverUrl, String token, AuthTokenType tokenType) async {
    try {
      final baseUri = Uri.parse(serverUrl);
      final response = await _client.get(
        Uri.parse('$serverUrl/api/v2/exercise/?limit=1'),
        headers: {
          HttpHeaders.authorizationHeader: _authHeader(token, tokenType),
          HttpHeaders.acceptHeader: 'application/json',
        },
      );

      if (response.statusCode != 200) {
        return true;
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final nextUrl = data['next'] as String?;
      if (nextUrl == null) {
        return true;
      }

      final nextUri = Uri.parse(nextUrl);
      return nextUri.host.toLowerCase() == baseUri.host.toLowerCase() &&
          nextUri.scheme == baseUri.scheme;
    } catch (e) {
      _logger.info('serverConfigSane check failed: $e');
      return true;
    }
  }

  /// Re-runs the auto-login flow. Used by the recovery screens
  /// ([ServerUnreachableScreen], [PowerSyncUnreachableScreen]) so the user
  /// can retry without restarting the app.
  Future<void> retryAutoLogin() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_tryAutoLogin);
  }

  Future<AuthState> _tryAutoLogin() async {
    final prefs = PreferenceHelper.asyncPref;
    final appVersion = await PackageInfo.fromPlatform();

    // Prefer the new headless-JWT keys when present. Falls back to the legacy
    // PREFS_USER blob below for users that haven't yet logged in via the
    // new flow.
    final headless = await _readHeadlessAuthFromPrefs(prefs);
    if (headless != null) {
      return _autoLoginWith(
        token: headless.accessToken,
        tokenType: AuthTokenType.headlessJwt,
        serverUrl: headless.serverUrl,
        appVersion: appVersion,
        accessExpiresAt: headless.accessExpiresAt,
      );
    }

    if (!(await prefs.containsKey(PREFS_USER))) {
      _logger.info('autologin failed, no saved user data');
      return AuthState(applicationVersion: appVersion);
    }

    final userData = json.decode((await prefs.getString(PREFS_USER))!);
    if (!userData.containsKey('token') || !userData.containsKey('serverUrl')) {
      _logger.info('autologin failed, no token or serverUrl');
      return AuthState(applicationVersion: appVersion);
    }

    final String? token = userData['token'];
    final String? serverUrl = userData['serverUrl'];
    if (token == null || serverUrl == null) {
      _logger.info('autologin failed, token or serverUrl is null');
      return AuthState(applicationVersion: appVersion);
    }

    return _autoLoginWith(
      token: token,
      tokenType: AuthTokenType.legacyApiToken,
      serverUrl: serverUrl,
      appVersion: appVersion,
    );
  }

  /// Common path for both the headless-JWT and the legacy auto-login flows:
  /// probe the server, then run the full gating chain. Wipes the matching
  /// stored credentials on a definitive 4xx so the user is routed to login.
  Future<AuthState> _autoLoginWith({
    required String token,
    required AuthTokenType tokenType,
    required String serverUrl,
    required PackageInfo appVersion,
    DateTime? accessExpiresAt,
  }) async {
    final response = await _probeWgerServer(serverUrl, token, tokenType, appVersion);
    // Network error before any HTTP response. Keep the saved session so the
    // user can retry from the recovery screen.
    if (response == null) {
      return switch (tokenType) {
        AuthTokenType.legacyApiToken => AuthState(
          status: AuthStatus.serverUnreachable,
          token: token,
          tokenType: tokenType,
          serverUrl: serverUrl,
          applicationVersion: appVersion,
        ),
        AuthTokenType.headlessJwt => AuthState(
          status: AuthStatus.serverUnreachable,
          accessToken: token,
          accessExpiresAt: accessExpiresAt,
          tokenType: tokenType,
          serverUrl: serverUrl,
          applicationVersion: appVersion,
        ),
      };
    }

    // Got a response but the server didn't like our token (typically 401/403),
    // wipe the matching credential bundle and route to login.
    if (response.statusCode != 200) {
      _logger.info('autologin failed, statusCode: ${response.statusCode}');
      await _wipeStoredCredentials(tokenType);
      return AuthState(applicationVersion: appVersion);
    }

    final newState = await _resolveAuthState(
      token: token,
      tokenType: tokenType,
      serverUrl: serverUrl,
      appVersion: appVersion,
      accessExpiresAt: accessExpiresAt,
    );
    if (newState.status == AuthStatus.loggedIn) {
      _logger.info('autologin successful');
    }
    return newState;
  }

  /// Reads the persisted headless-JWT bundle from shared preferences. Returns
  /// null when any required key is missing or unparseable; in that case the
  /// caller falls back to the legacy `PREFS_USER` blob.
  Future<_HeadlessAuthBundle?> _readHeadlessAuthFromPrefs(
    SharedPreferencesAsync prefs,
  ) async {
    final tokenTypeStr = await prefs.getString(PREFS_TOKEN_TYPE);
    if (tokenTypeStr != AuthTokenType.headlessJwt.name) {
      return null;
    }
    final accessToken = await prefs.getString(PREFS_ACCESS_TOKEN);
    final serverUrl = await prefs.getString(PREFS_SERVER_URL);
    if (accessToken == null || accessToken.isEmpty || serverUrl == null || serverUrl.isEmpty) {
      return null;
    }
    final expiresAtMs = await prefs.getInt(PREFS_ACCESS_EXPIRES_AT);
    final expiresAt = expiresAtMs == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(expiresAtMs, isUtc: true);
    return _HeadlessAuthBundle(
      accessToken: accessToken,
      serverUrl: serverUrl,
      accessExpiresAt: expiresAt,
    );
  }

  /// Wipes only the persisted credentials matching [tokenType]. Used on a
  /// definitive auth-rejection by the server so the next start routes the
  /// user to the login screen without touching the *other* token format
  /// (which a parallel user on the same device might still rely on).
  Future<void> _wipeStoredCredentials(AuthTokenType tokenType) async {
    final prefs = PreferenceHelper.asyncPref;
    switch (tokenType) {
      case AuthTokenType.legacyApiToken:
        await prefs.remove(PREFS_USER);
      case AuthTokenType.headlessJwt:
        await prefs.remove(PREFS_ACCESS_TOKEN);
        await prefs.remove(PREFS_ACCESS_EXPIRES_AT);
        await prefs.remove(PREFS_TOKEN_TYPE);
        await prefs.remove(PREFS_SERVER_URL);
        await ref.read(secureTokenStorageProvider).deleteRefreshToken();
    }
  }

  /// Runs the post-credentials gating chain (server version, min app
  /// version, PowerSync reachability) and returns the resulting
  /// [AuthState]. Shared by [_tryAutoLogin] and [login] so the routing
  /// rules live in exactly one place.
  ///
  /// [tokenType] selects which `Authorization` scheme outgoing probes use,
  /// and which [AuthState] field the credential is placed into:
  /// `legacyApiToken` populates `token`; `headlessJwt` populates
  /// `accessToken` plus the supplied [accessExpiresAt`.
  Future<AuthState> _resolveAuthState({
    required String token,
    required AuthTokenType tokenType,
    required String serverUrl,
    required PackageInfo appVersion,
    DateTime? accessExpiresAt,
  }) async {
    AuthState withStatus(AuthStatus status, String? serverVersion) => switch (tokenType) {
      AuthTokenType.legacyApiToken => AuthState(
        status: status,
        token: token,
        tokenType: tokenType,
        serverUrl: serverUrl,
        serverVersion: serverVersion,
        applicationVersion: appVersion,
      ),
      AuthTokenType.headlessJwt => AuthState(
        status: status,
        accessToken: token,
        accessExpiresAt: accessExpiresAt,
        tokenType: tokenType,
        serverUrl: serverUrl,
        serverVersion: serverVersion,
        applicationVersion: appVersion,
      ),
    };

    final serverVersion = await _fetchServerVersion(serverUrl);
    if (serverUpdateRequired(serverVersion)) {
      return withStatus(AuthStatus.serverUpdateRequired, serverVersion);
    }

    if (await _applicationUpdateRequired(serverUrl, appVersion.version)) {
      return withStatus(AuthStatus.updateRequired, serverVersion);
    }

    if (!await _isPowerSyncReachable(serverUrl, token, tokenType)) {
      return withStatus(AuthStatus.powerSyncUnreachable, serverVersion);
    }

    return withStatus(AuthStatus.loggedIn, serverVersion);
  }

  /// Probes the wger backend
  Future<http.Response?> _probeWgerServer(
    String serverUrl,
    String token,
    AuthTokenType tokenType,
    PackageInfo appVersion,
  ) async {
    try {
      return await _client.head(
        makeUri(serverUrl, 'routine'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
          HttpHeaders.userAgentHeader: getAppNameHeader(appVersion),
          HttpHeaders.authorizationHeader: _authHeader(token, tokenType),
        },
      );
    } on Exception catch (e, s) {
      if (_isNetworkError(e)) {
        _logger.warning('wger probe: server unreachable: $e', e, s);
        return null;
      }
      rethrow;
    }
  }

  /// Tries to reach the PowerSync service and returns true if it looks alive,
  /// but only the first time a user logs in (this is checked by reading the
  /// [PREFS_HAS_EVER_SYNCED] flag from shared preferences).
  Future<bool> _isPowerSyncReachable(
    String serverUrl,
    String token,
    AuthTokenType tokenType,
  ) async {
    final prefs = PreferenceHelper.asyncPref;
    final everSynced = (await prefs.getBool(PREFS_HAS_EVER_SYNCED)) ?? false;
    if (everSynced) {
      return true;
    }

    try {
      final tokenResponse = await _client.get(
        makeUri(serverUrl, 'powersync-token', trailingSlash: false),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: _authHeader(token, tokenType),
        },
      );
      if (tokenResponse.statusCode != 200) {
        _logger.warning(
          'PowerSync probe: token endpoint returned ${tokenResponse.statusCode}',
        );
        return false;
      }
      final body = json.decode(tokenResponse.body) as Map<String, dynamic>;
      final powerSyncUrl = body['powersync_url'] as String?;
      if (powerSyncUrl == null || powerSyncUrl.isEmpty) {
        _logger.warning('PowerSync probe: empty powersync_url in token response');
        return false;
      }

      final probeUri = Uri.parse(
        '$powerSyncUrl${powerSyncUrl.endsWith('/') ? '' : '/'}probes/liveness',
      );
      final probeResponse = await _client.get(probeUri);
      if (probeResponse.statusCode == 200) {
        // A status 200 is enough for us right now
        await prefs.setBool(PREFS_HAS_EVER_SYNCED, true);
        return true;
      }
      _logger.warning(
        'PowerSync probe: liveness returned ${probeResponse.statusCode}',
      );
      return false;
    } on Exception catch (e, s) {
      _logger.warning('PowerSync probe failed: $e', e, s);
      return false;
    }
  }

  /// Returns the current state value or a blank default. Callers that
  /// mutate state should always compose on top of this.
  AuthState _currentOrBlank() => state.asData?.value ?? const AuthState();

  /// Invalidates every notifier that depends on the authenticated HTTP base
  /// provider. Call this after a successful login so the providers refetch
  /// with the new token instead of replaying their pre-login error state.
  void _invalidatePostLoginProviders() {
    _logger.fine('Invalidating data providers after login');
    ref.invalidate(userProfileProvider);
    ref.invalidate(routinesRiverpodProvider);
    ref.invalidate(nutritionProvider);
    ref.invalidate(trophyStateProvider);
    ref.invalidate(galleryProvider);
  }

  /// Exchanges the persisted refresh token for a fresh access/refresh pair.
  ///
  /// Single-flight: concurrent callers share one HTTP request. On any
  /// failure (missing refresh token, missing serverUrl, network error,
  /// non-200 response, malformed body) the user is logged out — there is
  /// no usable session to fall back to once the refresh token is gone.
  ///
  /// On success: `state.accessToken` / `state.accessExpiresAt` are updated,
  /// the rotated refresh token (when present) is written to secure storage,
  /// and the new access token + its expiry are written to shared preferences.
  Future<void> refreshAccessToken() {
    return _refreshInFlight ??= _runRefresh().whenComplete(() {
      _refreshInFlight = null;
    });
  }

  Future<void> _runRefresh() async {
    final current = _currentOrBlank();
    final serverUrl = current.serverUrl;
    if (serverUrl == null) {
      _logger.warning('refreshAccessToken: no serverUrl in state, logging out');
      await logout();
      return;
    }

    final secureStorage = ref.read(secureTokenStorageProvider);
    final refreshToken = await secureStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      _logger.warning('refreshAccessToken: no refresh token in secure storage, logging out');
      await logout();
      return;
    }

    final http.Response response;
    try {
      response = await _client.post(
        makeHeadlessUri(serverUrl, HEADLESS_TOKENS_REFRESH_PATH),
        headers: {HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'},
        body: json.encode({'refresh_token': refreshToken}),
      );
    } on Exception catch (e, s) {
      _logger.warning('refreshAccessToken: network error, logging out', e, s);
      await logout();
      return;
    }

    if (response.statusCode != 200) {
      _logger.warning('refreshAccessToken: status ${response.statusCode}, logging out');
      await logout();
      return;
    }

    final String newAccess;
    final String? newRefresh;
    final DateTime? newExp;
    try {
      final body = json.decode(response.body) as Map<String, dynamic>;
      final meta = body['meta'] as Map<String, dynamic>;
      newAccess = meta['access_token'] as String;
      newRefresh = meta['refresh_token'] as String?;
      newExp = jwtExp(decodeJwtPayload(newAccess));
    } catch (e, s) {
      _logger.warning('refreshAccessToken: malformed response body, logging out', e, s);
      await logout();
      return;
    }

    // Persist before mutating state so a crash mid-refresh leaves disk and
    // state consistent: the next auto-login will read what we wrote here.
    final prefs = PreferenceHelper.asyncPref;
    await prefs.setString(PREFS_ACCESS_TOKEN, newAccess);
    if (newExp != null) {
      await prefs.setInt(PREFS_ACCESS_EXPIRES_AT, newExp.millisecondsSinceEpoch);
    } else {
      await prefs.remove(PREFS_ACCESS_EXPIRES_AT);
    }
    if (newRefresh != null) {
      await secureStorage.writeRefreshToken(newRefresh);
    }

    state = AsyncData(current.copyWith(accessToken: newAccess, accessExpiresAt: newExp));
  }

  Future<void> logout() async {
    _logger.fine('logging out');

    // Wipe the local PowerSync cache before we clear the auth state. We only
    // do this if the DB has actually been built; reading the provider here
    // would otherwise force-build it (which needs credentials we're about to
    // remove). On the next login, `_reconnectPowerSyncIfBuilt` picks up the
    // fresh credentials.
    await _wipePowerSyncIfBuilt();

    state = AsyncData(
      AuthState(applicationVersion: _currentOrBlank().applicationVersion),
    );
    final prefs = PreferenceHelper.asyncPref;
    await prefs.remove(PREFS_USER);
    await prefs.remove(PREFS_HAS_EVER_SYNCED);
    // Headless-JWT bundle: both shared preferences and the secure-storage
    // refresh token are wiped, regardless of which auth surface the user
    // was on, so a logout from either flow leaves no credentials behind.
    await prefs.remove(PREFS_ACCESS_TOKEN);
    await prefs.remove(PREFS_ACCESS_EXPIRES_AT);
    await prefs.remove(PREFS_TOKEN_TYPE);
    await prefs.remove(PREFS_SERVER_URL);
    await ref.read(secureTokenStorageProvider).deleteRefreshToken();
  }

  /// Wipes the local PowerSync database if it has already been built.
  /// No-op when PowerSync hasn't been initialised yet (e.g. during the
  /// pre-login reset on app start, before any data widgets have run).
  Future<void> _wipePowerSyncIfBuilt() async {
    if (!ref.exists(powerSyncInstanceProvider)) {
      return;
    }
    try {
      final db = await ref.read(powerSyncInstanceProvider.future);
      await db.disconnectAndClear();
    } catch (e, s) {
      _logger.warning('PowerSync wipe failed', e, s);
    }
  }

  /// Reconnects an already-built PowerSync DB with a fresh connector for the
  /// given [serverUrl]. No-op when PowerSync hasn't been built yet: the next
  /// access will build it with the current (post-login) auth state.
  Future<void> _reconnectPowerSyncIfBuilt(String serverUrl) async {
    if (!ref.exists(powerSyncInstanceProvider)) {
      return;
    }
    try {
      final db = await ref.read(powerSyncInstanceProvider.future);
      connectPowerSync(db, serverUrl);
    } catch (e, s) {
      _logger.warning('PowerSync reconnect failed', e, s);
    }
  }

  /// Refreshes the server version into the state.
  Future<void> setServerVersion() async {
    final current = _currentOrBlank();
    if (current.serverUrl == null) {
      return;
    }
    final v = await _fetchServerVersion(current.serverUrl!);
    state = AsyncData(current.copyWith(serverVersion: v));
  }

  Future<String> _fetchServerVersion(String serverUrl) async {
    final response = await _client.get(makeUri(serverUrl, SERVER_VERSION_URL));
    return json.decode(response.body);
  }

  Future<bool> _applicationUpdateRequired(String serverUrl, String appVersion) async {
    final response = await _client.get(makeUri(serverUrl, MIN_APP_VERSION_URL));
    final current = Version.parse(appVersion);
    final required = Version.parse(jsonDecode(response.body));

    final needUpdate = required > current;
    if (needUpdate) {
      _logger.fine('Application update required: $required > $current');
    }
    return needUpdate;
  }

  /// Loads the last server URL the user successfully logged in with.
  static Future<String> getServerUrlFromPrefs() async {
    final prefs = PreferenceHelper.asyncPref;
    if (!(await prefs.containsKey(PREFS_LAST_SERVER))) {
      return DEFAULT_SERVER_PROD;
    }

    final userData = json.decode((await prefs.getString(PREFS_LAST_SERVER))!);
    return userData['serverUrl'] as String;
  }
}

/// Checks whether the connected server meets the minimum version required
/// by this build of the app.
///
/// Returns false (lenient) when the version cannot be read or parsed, so
/// users aren't locked out on unexpected server configurations.
bool serverUpdateRequired(String? rawVersion) {
  final logger = Logger('AuthNotifier');
  if (rawVersion == null) {
    logger.warning('serverUpdateRequired: serverVersion is null, skipping check');
    return false;
  }

  // Strip common non-semver suffixes emitted by Python/Django backends,
  // e.g. '2.5.0a2' → '2.5.0', '2.3.0 (git-abc1234)' → '2.3.0'.
  final sanitized = rawVersion
      .replaceFirst(RegExp(r'\s.*$'), '')
      .replaceFirst(RegExp(r'[a-zA-Z].*$'), '');

  final Version current;
  try {
    current = Version.parse(sanitized);
  } on FormatException {
    logger.warning(
      'serverUpdateRequired: could not parse server version "$rawVersion" '
      '(sanitized: "$sanitized"), skipping check',
    );
    return false;
  }
  final required = Version.parse(MIN_SERVER_VERSION);
  final needUpdate = current < required;
  if (needUpdate) {
    logger.fine('Server update required: server $current < minimum $required');
  }
  return needUpdate;
}

/// True if [e] is the kind of error we want to treat as "the server can't be
/// reached right now" as opposed to an HTTP response we got but didn't like
/// (e.g. 401 means the token is invalid and the user should be logged out).
///
/// We catch `http.ClientException` (which wraps `SocketException` etc. on most
/// platforms) and the dart:io / dart:async exceptions directly for cases where
/// the http package surfaces them unwrapped.
bool _isNetworkError(Object e) {
  return e is http.ClientException ||
      e is SocketException ||
      e is HandshakeException ||
      e is TimeoutException;
}

/// Headless-JWT credential bundle as read from shared preferences during
/// auto-login. The refresh token is intentionally absent — it lives in
/// secure storage and is only fetched when a refresh actually runs.
class _HeadlessAuthBundle {
  final String accessToken;
  final String serverUrl;
  final DateTime? accessExpiresAt;

  const _HeadlessAuthBundle({
    required this.accessToken,
    required this.serverUrl,
    this.accessExpiresAt,
  });
}

/// User-agent header string identifying the app/version/platform.
String getAppNameHeader(PackageInfo? applicationVersion) {
  String out = '';
  if (applicationVersion != null) {
    out =
        '/${applicationVersion.version} '
        '(${applicationVersion.packageName}; '
        'build: ${applicationVersion.buildNumber}; '
        'platform: ${Platform.operatingSystem})'
        ' - https://github.com/wger-project';
  }
  return 'wger App$out';
}
