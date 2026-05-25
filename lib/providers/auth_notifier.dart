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

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter_riverpod/flutter_riverpod.dart' show Provider;
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:version/version.dart';
import 'package:wger/core/error_dialogs.dart';
import 'package:wger/core/exceptions/http_exception.dart';
import 'package:wger/core/exceptions/mfa_required_exception.dart';
import 'package:wger/database/powersync/powersync.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/jwt.dart';
import 'package:wger/helpers/shared_preferences.dart';
import 'package:wger/providers/auth_http_client.dart';
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

/// `allauth.headless` `app` client endpoints, relative to the
/// `/_allauth/app/v1/` base.
const HEADLESS_TOKENS_REFRESH_PATH = 'tokens/refresh';
const HEADLESS_AUTH_LOGIN_PATH = 'auth/login';
const HEADLESS_AUTH_SIGNUP_PATH = 'auth/signup';
const HEADLESS_AUTH_MFA_AUTHENTICATE_PATH = 'auth/2fa/authenticate';

/// Header that carries the short-lived `session_token` returned by
/// `auth/login` when a follow-up step (currently only 2FA) is still pending.
const HEADLESS_SESSION_TOKEN_HEADER = 'X-Session-Token';

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

  /// Completes when the most recent background revalidation has finished.
  /// Exposed so tests can deterministically await the fire-and-forget task.
  @visibleForTesting
  Future<void>? revalidationDone;

  @override
  Future<AuthState> build() async {
    _client = ref.read(authHttpClientProvider);
    return _tryAutoLogin();
  }

  /// Registers a new user and logs in via the `allauth.headless` signup
  /// endpoint. The response already carries the access + refresh tokens,
  /// so no separate login call is needed.
  Future<LoginActions> register({
    required String username,
    required String password,
    required String email,
    required String serverUrl,
    String locale = 'en',
  }) async {
    final appVersion = _currentOrBlank().applicationVersion ?? await PackageInfo.fromPlatform();
    final body = <String, String>{'username': username, 'password': password};
    if (email.isNotEmpty) {
      body['email'] = email;
    }

    final response = await _client.post(
      makeHeadlessUri(serverUrl, HEADLESS_AUTH_SIGNUP_PATH),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.userAgentHeader: getAppNameHeader(appVersion),
        HttpHeaders.acceptLanguageHeader: locale,
      },
      body: json.encode(body),
    );
    final creds = _consumeHeadlessAuthResponse(response);
    return _completeLogin(creds, serverUrl, appVersion);
  }

  /// Authenticates a user.
  ///
  /// Two modes:
  /// 1. [refreshToken] is non-empty → treated as a refresh token the user
  ///    minted on the wger website. Exchanged immediately for a fresh
  ///    access token via the `allauth.headless` `tokens/refresh` endpoint;
  ///    the rotated bundle is persisted as [AuthTokenType.headlessJwt].
  ///    Useful when the server sits behind an auth proxy that breaks the
  ///    interactive login flow.
  /// 2. Otherwise the `auth/login` endpoint is used with username +
  ///    password. A pending second-factor flow surfaces as
  ///    [MfaRequiredException] for the caller to route to the 2FA
  ///    challenge screen.
  Future<LoginActions> login(
    String username,
    String password,
    String serverUrl,
    String? refreshToken,
  ) async {
    final appVersion = _currentOrBlank().applicationVersion ?? await PackageInfo.fromPlatform();
    final creds = await _obtainCredentials(
      username,
      password,
      serverUrl,
      refreshToken,
      appVersion,
    );
    return _completeLogin(creds, serverUrl, appVersion);
  }

  /// Completes a pending second-factor challenge started by [login].
  ///
  /// Sends [code] (a TOTP code or a recovery code) plus the [sessionToken]
  /// returned by the prior 401 to `auth/2fa/authenticate`. On success the
  /// server issues the access + refresh tokens and the rest of the login
  /// flow (persist, gating chain, PowerSync reconnect) runs unchanged.
  ///
  /// The caller is expected to have an active [AuthState.serverUrl] from
  /// the preceding login attempt; pass it explicitly so the call works
  /// even before any state has been written.
  Future<LoginActions> completeMfa({
    required String sessionToken,
    required String code,
    required String serverUrl,
  }) async {
    final appVersion = _currentOrBlank().applicationVersion ?? await PackageInfo.fromPlatform();
    final response = await _client.post(
      makeHeadlessUri(serverUrl, HEADLESS_AUTH_MFA_AUTHENTICATE_PATH),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
        HttpHeaders.userAgentHeader: getAppNameHeader(appVersion),
        HEADLESS_SESSION_TOKEN_HEADER: sessionToken,
      },
      body: json.encode({'code': code}),
    );
    final creds = _consumeHeadlessAuthResponse(response);
    return _completeLogin(creds, serverUrl, appVersion);
  }

  Future<_FreshCredentials> _obtainCredentials(
    String username,
    String password,
    String serverUrl,
    String? pastedRefreshToken,
    PackageInfo appVersion,
  ) async {
    if (pastedRefreshToken != null && pastedRefreshToken.isNotEmpty) {
      return _exchangePastedRefreshToken(pastedRefreshToken, serverUrl, appVersion);
    }

    final response = await _client.post(
      makeHeadlessUri(serverUrl, HEADLESS_AUTH_LOGIN_PATH),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
        HttpHeaders.userAgentHeader: getAppNameHeader(appVersion),
      },
      body: json.encode({'username': username, 'password': password}),
    );
    return _consumeHeadlessAuthResponse(response);
  }

  /// Exchanges a manually-pasted refresh token for a fresh access + refresh
  /// bundle. Rotation is on by default server-side, so the pasted token is
  /// invalidated as part of this call and the new refresh token is what
  /// ends up persisted in secure storage. Throws [WgerHttpException] when
  /// the server rejects the pasted token.
  Future<_FreshCredentials> _exchangePastedRefreshToken(
    String refreshToken,
    String serverUrl,
    PackageInfo appVersion,
  ) async {
    final response = await _client.post(
      makeHeadlessUri(serverUrl, HEADLESS_TOKENS_REFRESH_PATH),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
        HttpHeaders.userAgentHeader: getAppNameHeader(appVersion),
      },
      body: json.encode({'refresh_token': refreshToken}),
    );
    return _consumeHeadlessAuthResponse(response);
  }

  /// Parses the standard `allauth.headless` auth response envelope.
  ///
  /// Returns a populated [_FreshCredentials] on 200 (tokens carried in
  /// `meta`).
  ///
  /// Throws:
  /// - [MfaRequiredException] on a 401 that carries `meta.session_token`,
  ///   signalling that the user must complete a second factor before tokens
  ///   are issued.
  /// - [WgerHttpException] for any other status, or for malformed / partial
  ///   bodies on otherwise-successful responses.
  _FreshCredentials _consumeHeadlessAuthResponse(http.Response response) {
    final Map<String, dynamic> body;
    try {
      body = json.decode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw WgerHttpException(response);
    }

    if (response.statusCode == 401) {
      final meta = body['meta'] as Map<String, dynamic>?;
      final sessionToken = meta?['session_token'] as String?;
      if (sessionToken != null && sessionToken.isNotEmpty) {
        final flows = (body['data'] as Map<String, dynamic>?)?['flows'] as List<dynamic>?;
        final factors =
            flows
                ?.whereType<Map<String, dynamic>>()
                .where(
                  (f) => f['id'] == 'mfa_authenticate' && (f['is_pending'] as bool? ?? false),
                )
                .expand((f) => (f['types'] as List<dynamic>?)?.cast<String>() ?? const <String>[])
                .toList() ??
            const <String>[];
        throw MfaRequiredException(sessionToken: sessionToken, availableFactors: factors);
      }
      throw WgerHttpException(response);
    }

    if (response.statusCode != 200) {
      throw WgerHttpException(response);
    }

    // auth/login and auth/signup return the tokens under `meta`, while
    // tokens/refresh returns them under `data` (see allauth.headless source:
    // base/response.py vs tokens/response.py). Read both so this parser
    // works for either response shape.
    final meta = body['meta'] as Map<String, dynamic>?;
    final data = body['data'] as Map<String, dynamic>?;
    final accessToken = (meta?['access_token'] ?? data?['access_token']) as String?;
    if (accessToken == null || accessToken.isEmpty) {
      // 200 without tokens, likely a still-pending flow we don't know how
      // to drive. Surface as an HTTP error so the caller renders something.
      throw WgerHttpException(response);
    }
    return _FreshCredentials(
      token: accessToken,
      tokenType: AuthTokenType.headlessJwt,
      refreshToken: (meta?['refresh_token'] ?? data?['refresh_token']) as String?,
      accessExpiresAt: jwtExp(decodeJwtPayload(accessToken)),
    );
  }

  /// Shared post-credentials path: persist the new bundle, run the gating
  /// chain, swap PowerSync's connector if it was already up, invalidate the
  /// data providers so they refetch with the new auth.
  Future<LoginActions> _completeLogin(
    _FreshCredentials creds,
    String serverUrl,
    PackageInfo appVersion,
  ) async {
    await _persistCredentials(creds, serverUrl);

    var newState = await _resolveAuthState(
      token: creds.token,
      tokenType: creds.tokenType,
      serverUrl: serverUrl,
      appVersion: appVersion,
      accessExpiresAt: creds.accessExpiresAt,
    );

    if (newState.status == AuthStatus.loggedIn &&
        !await _serverConfigSane(serverUrl, creds.token, creds.tokenType)) {
      newState = newState.copyWith(serverConfigWarning: true);
    }

    state = AsyncData(newState);

    if (newState.status == AuthStatus.loggedIn) {
      await _reconnectPowerSyncIfBuilt(serverUrl);
      _invalidatePostLoginProviders();
    }

    return switch (newState.status) {
      AuthStatus.serverUpdateRequired || AuthStatus.appUpdateRequired => LoginActions.update,
      _ => LoginActions.proceed,
    };
  }

  /// Writes a fresh credential bundle to disk and wipes the *other* token
  /// format, so a re-login under a different mode (e.g. headless → API key)
  /// does not leave stale credentials behind.
  Future<void> _persistCredentials(_FreshCredentials creds, String serverUrl) async {
    final prefs = PreferenceHelper.asyncPref;
    await prefs.setString(PREFS_LAST_SERVER, json.encode({'serverUrl': serverUrl}));

    switch (creds.tokenType) {
      case AuthTokenType.legacyApiToken:
        await prefs.setString(
          PREFS_USER,
          json.encode({'token': creds.token, 'serverUrl': serverUrl}),
        );
        await _wipeStoredCredentials(AuthTokenType.headlessJwt);
      case AuthTokenType.headlessJwt:
        await prefs.setString(PREFS_ACCESS_TOKEN, creds.token);
        if (creds.accessExpiresAt != null) {
          await prefs.setInt(
            PREFS_ACCESS_EXPIRES_AT,
            creds.accessExpiresAt!.millisecondsSinceEpoch,
          );
        } else {
          await prefs.remove(PREFS_ACCESS_EXPIRES_AT);
        }
        await prefs.setString(PREFS_TOKEN_TYPE, AuthTokenType.headlessJwt.name);
        await prefs.setString(PREFS_SERVER_URL, serverUrl);
        if (creds.refreshToken != null) {
          await ref.read(secureTokenStorageProvider).writeRefreshToken(creds.refreshToken!);
        }
        await _wipeStoredCredentials(AuthTokenType.legacyApiToken);
    }
  }

  /// Clears the server config warning flag, called from the auth screen after
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
      return _resolveStoredSession(
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

    return _resolveStoredSession(
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
    // Server unreachable at startup. The user already has a saved session, so
    // let them straight in to keep working offline.
    if (response == null) {
      _logger.info('autologin: server unreachable, continuing offline');
      return _restoredSessionState(
        token: token,
        tokenType: tokenType,
        serverUrl: serverUrl,
        appVersion: appVersion,
        accessExpiresAt: accessExpiresAt,
      );
    }

    // The server actively rejected our token: wipe the matching credential
    // bundle and route to login. Only 401/403 count, a transient 5xx must not
    // log the user out.
    if (_isAuthRejection(response.statusCode)) {
      _logger.info('autologin failed, token rejected: ${response.statusCode}');
      await _wipeStoredCredentials(tokenType);
      return AuthState(applicationVersion: appVersion);
    }

    // Any other non-200 (5xx etc.) is transient: keep the saved session.
    if (response.statusCode != 200) {
      _logger.warning(
        'autologin: probe returned ${response.statusCode}, keeping saved session',
      );
      return _restoredSessionState(
        token: token,
        tokenType: tokenType,
        serverUrl: serverUrl,
        appVersion: appVersion,
        accessExpiresAt: accessExpiresAt,
      );
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

  /// Decides how a stored session enters the app. A previously synced session
  /// goes straight in (offline-capable) and is revalidated in the background;
  /// a never-synced session has no local data yet, so the server must be
  /// reached first through the blocking [_autoLoginWith] path.
  Future<AuthState> _resolveStoredSession({
    required String token,
    required AuthTokenType tokenType,
    required String serverUrl,
    required PackageInfo appVersion,
    DateTime? accessExpiresAt,
  }) async {
    final everSynced = (await PreferenceHelper.asyncPref.getBool(PREFS_HAS_EVER_SYNCED)) ?? false;
    if (!everSynced) {
      return _autoLoginWith(
        token: token,
        tokenType: tokenType,
        serverUrl: serverUrl,
        appVersion: appVersion,
        accessExpiresAt: accessExpiresAt,
      );
    }

    _logger.info('autologin: session restored, revalidating in background');
    _scheduleRevalidation();
    return _restoredSessionState(
      token: token,
      tokenType: tokenType,
      serverUrl: serverUrl,
      appVersion: appVersion,
      accessExpiresAt: accessExpiresAt,
    );
  }

  /// Builds a logged-in [AuthState] for a stored session, placing the
  /// credential in the field that matches [tokenType].
  AuthState _restoredSessionState({
    required String token,
    required AuthTokenType tokenType,
    required String serverUrl,
    required PackageInfo appVersion,
    DateTime? accessExpiresAt,
  }) {
    return switch (tokenType) {
      AuthTokenType.legacyApiToken => AuthState(
        status: AuthStatus.loggedIn,
        token: token,
        tokenType: tokenType,
        serverUrl: serverUrl,
        applicationVersion: appVersion,
      ),
      AuthTokenType.headlessJwt => AuthState(
        status: AuthStatus.loggedIn,
        accessToken: token,
        accessExpiresAt: accessExpiresAt,
        tokenType: tokenType,
        serverUrl: serverUrl,
        applicationVersion: appVersion,
      ),
    };
  }

  /// Whether [statusCode] means the server actively rejected our token, as
  /// opposed to a transient error that must not invalidate the session.
  bool _isAuthRejection(int statusCode) => statusCode == 401 || statusCode == 403;

  /// Schedules a non-blocking revalidation of the restored session.
  ///
  /// The first run is deferred to a fresh event-loop task so [build] has
  /// completed first. It then re-runs whenever connectivity is regained, so a
  /// session restored while offline still gets validated without an app
  /// restart. Connectivity is observed directly (not via networkStatusProvider)
  /// to avoid a dependency cycle (auth -> networkStatus -> wgerBase -> auth).
  void _scheduleRevalidation() {
    revalidationDone = Future(_revalidate);

    final sub = Connectivity().onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (online) {
        revalidationDone = _revalidate();
      }
    });
    ref.onDispose(sub.cancel);
  }

  /// Revalidates the restored session against the server. Fire-and-forget: it
  /// never throws and only changes the state on a genuine problem (a revoked
  /// token, or an outdated app/server). Transient failures (offline, 5xx,
  /// network errors) leave the user logged in.
  Future<void> _revalidate() async {
    try {
      final current = state.asData?.value;
      if (current == null || current.status != AuthStatus.loggedIn) {
        return;
      }

      final tokenType = current.tokenType ?? AuthTokenType.legacyApiToken;
      final token = current.accessToken ?? current.token;
      final serverUrl = current.serverUrl;
      if (token == null || serverUrl == null) {
        return;
      }
      final appVersion = current.applicationVersion ?? await PackageInfo.fromPlatform();

      final response = await _probeWgerServer(serverUrl, token, tokenType, appVersion);
      if (response == null) {
        _logger.fine('revalidation: server unreachable, keeping session');
        return;
      }
      if (_isAuthRejection(response.statusCode)) {
        _logger.info('revalidation: token rejected (${response.statusCode}), logging out');
        await logout();
        showSessionExpiredSnackbar();
        return;
      }
      if (response.statusCode != 200) {
        _logger.warning(
          'revalidation: probe returned ${response.statusCode}, keeping session',
        );
        return;
      }

      final serverVersion = await _fetchServerVersion(serverUrl);
      if (serverUpdateRequired(serverVersion)) {
        _logger.info('revalidation: server update required');
        state = AsyncData(
          current.copyWith(
            status: AuthStatus.serverUpdateRequired,
            serverVersion: serverVersion,
          ),
        );
        return;
      }
      if (await _applicationUpdateRequired(serverUrl, appVersion.version)) {
        _logger.info('revalidation: app update required');
        state = AsyncData(
          current.copyWith(
            status: AuthStatus.appUpdateRequired,
            serverVersion: serverVersion,
          ),
        );
        return;
      }

      _logger.fine('revalidation: session still valid');
    } catch (e, s) {
      _logger.warning('revalidation failed', e, s);
    }
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
      return withStatus(AuthStatus.appUpdateRequired, serverVersion);
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
  /// non-200 response, malformed body) the user is logged out. There is
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
    _logger.fine('refreshAccessToken: starting');
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
      final bodySnippet = response.body.length > 200
          ? '${response.body.substring(0, 200)}...'
          : response.body;
      _logger.warning(
        'refreshAccessToken: status ${response.statusCode}, body: $bodySnippet, logging out',
      );
      await logout();
      return;
    }

    final String newAccess;
    final String? newRefresh;
    final DateTime? newExp;
    try {
      final body = json.decode(response.body) as Map<String, dynamic>;
      // tokens/refresh returns the new tokens under `data` (see
      // allauth.headless.tokens.response.RefreshTokenResponse); auth/login
      // returns them under `meta`. Read whichever is present so this code
      // keeps working if either response shape changes.
      final data = body['data'] as Map<String, dynamic>?;
      final meta = body['meta'] as Map<String, dynamic>?;
      newAccess = (data?['access_token'] ?? meta?['access_token']) as String;
      newRefresh = (data?['refresh_token'] ?? meta?['refresh_token']) as String?;
      newExp = jwtExp(decodeJwtPayload(newAccess));
    } catch (e, s) {
      final bodySnippet = response.body.length > 500
          ? '${response.body.substring(0, 500)}...'
          : response.body;
      _logger.warning(
        'refreshAccessToken: malformed response body, logging out. Body: $bodySnippet',
        e,
        s,
      );
      await logout();
      return;
    }
    _logger.fine(
      'refreshAccessToken: success, new expiry $newExp, '
      'rotated refresh token: ${newRefresh != null}',
    );

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
    final db = builtPowerSyncInstance;
    if (db == null) {
      return;
    }
    try {
      await db.disconnectAndClear();
    } catch (e, s) {
      _logger.warning('PowerSync wipe failed', e, s);
    }
  }

  /// Reconnects an already-built PowerSync DB with a fresh connector for the
  /// given [serverUrl]. No-op when PowerSync hasn't been built yet: the next
  /// access will build it with the current (post-login) auth state.
  Future<void> _reconnectPowerSyncIfBuilt(String serverUrl) async {
    final db = builtPowerSyncInstance;
    if (db == null) {
      return;
    }
    try {
      connectPowerSync(db, serverUrl, ref.read(authenticatedHttpClientProvider));
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

/// In-memory credential bundle returned by the login / signup flows. The
/// `refreshToken` and `accessExpiresAt` fields are only populated for the
/// headless JWT path; the legacy DRF token path leaves them null.
class _FreshCredentials {
  final String token;
  final AuthTokenType tokenType;
  final String? refreshToken;
  final DateTime? accessExpiresAt;

  const _FreshCredentials({
    required this.token,
    required this.tokenType,
    this.refreshToken,
    this.accessExpiresAt,
  });
}

/// Headless-JWT credential bundle as read from shared preferences during
/// auto-login. The refresh token is intentionally absent (it lives in
/// secure storage and is only fetched when a refresh actually runs).
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
