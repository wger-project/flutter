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
import 'package:wger/core/error_dialogs.dart';
import 'package:wger/core/exceptions/http_exception.dart';
import 'package:wger/core/exceptions/mfa_required_exception.dart';
import 'package:wger/database/powersync/powersync.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/errors.dart';
import 'package:wger/helpers/jwt.dart';
import 'package:wger/helpers/shared_preferences.dart';
import 'package:wger/providers/auth_credentials_storage.dart';
import 'package:wger/providers/auth_http_client.dart';
import 'package:wger/providers/auth_state.dart';
import 'package:wger/providers/gallery_notifier.dart';
import 'package:wger/providers/helpers.dart';
import 'package:wger/providers/network_provider.dart';
import 'package:wger/providers/nutrition_notifier.dart';
import 'package:wger/providers/routines_notifier.dart';
import 'package:wger/providers/server_gating.dart';
import 'package:wger/providers/trophy_notifier.dart';
import 'package:wger/providers/user_profile_notifier.dart';

part 'auth_notifier.g.dart';

/// `allauth.headless` `app` client endpoints, relative to the
/// `/_allauth/app/v1/` base.
const HEADLESS_TOKENS_REFRESH_PATH = 'tokens/refresh';
const HEADLESS_AUTH_LOGIN_PATH = 'auth/login';
const HEADLESS_AUTH_SIGNUP_PATH = 'auth/signup';
const HEADLESS_AUTH_MFA_AUTHENTICATE_PATH = 'auth/2fa/authenticate';

/// `/api/v2/<this>` endpoint that mints a headless-JWT refresh token for the
/// authenticated user. Used by the one-shot legacy-DRF → JWT migration on
/// app start. See `plan-remove-legacy-drf-token.prompt.md` for the matching
/// removal plan once enough users have migrated.
const ISSUE_REFRESH_TOKEN_PATH = 'issue-refresh-token';

/// Header that carries the short-lived `session_token` returned by
/// `auth/login` when a follow-up step (currently only 2FA) is still pending.
const HEADLESS_SESSION_TOKEN_HEADER = 'X-Session-Token';

/// HTTP client used by the auth notifier. Override in tests.
final authHttpClientProvider = Provider<http.Client>((ref) => http.Client());

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  final _logger = Logger('AuthNotifier');
  late http.Client _client;
  late AuthCredentialsStorage _storage;
  late ServerGating _gating;

  /// Holds the in-flight refresh future so concurrent callers share a single
  /// network roundtrip. Cleared in `whenComplete` so the next refresh starts
  /// a fresh request.
  Future<void>? _refreshInFlight;

  /// Completes when the most recent background revalidation has finished.
  /// Exposed so tests can deterministically await the fire-and-forget task.
  @visibleForTesting
  Future<void>? revalidationDone;

  /// Number of times the user-switch DB wipe has fired since the notifier
  /// was built. Exposed so tests can assert the user-mismatch path ran
  /// without having to instrument PowerSync or the filesystem.
  @visibleForTesting
  int userSwitchWipeCount = 0;

  @override
  Future<AuthState> build() async {
    _client = ref.read(authHttpClientProvider);
    _storage = ref.read(authCredentialsStorageProvider);
    _gating = ref.read(serverGatingProvider);
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
  ///    the rotated bundle is persisted as a [JwtCredential].
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
    return (
      credential: JwtCredential(
        accessToken: accessToken,
        expiresAt: jwtExp(decodeJwtPayload(accessToken)),
      ),
      refreshToken: (meta?['refresh_token'] ?? data?['refresh_token']) as String?,
    );
  }

  /// Shared post-credentials path: persist the new bundle, run the gating
  /// chain, swap PowerSync's connector if it was already up, invalidate the
  /// data providers so they refetch with the new auth.
  ///
  /// When the incoming JWT belongs to a different user than the one whose
  /// data sits in the local PowerSync DB, the DB is wiped before
  /// reconnecting. Otherwise queued CRUD ops from the previous user would
  /// be uploaded under the new user's credentials, which is both a leak
  /// and would corrupt data ownership server-side.
  Future<LoginActions> _completeLogin(
    _FreshCredentials creds,
    String serverUrl,
    PackageInfo appVersion,
  ) async {
    // Capture the previous user-id BEFORE saving overwrites it. null on
    // the previous side means "no prior session" (fresh install,
    // post-logout); we only wipe on a confirmed mismatch.
    final prevUserId = await _storage.previousUserId();
    final newUserId = creds.credential.userId;
    final userChanged = prevUserId != null && newUserId != null && prevUserId != newUserId;

    await _storage.saveJwt(
      credential: creds.credential,
      refreshToken: creds.refreshToken,
      serverUrl: serverUrl,
    );

    final gating = await _gating.resolve(
      credential: creds.credential,
      serverUrl: serverUrl,
      appVersion: appVersion,
    );
    var newState = AuthState(
      status: gating.status,
      credential: creds.credential,
      serverUrl: serverUrl,
      serverVersion: gating.serverVersion,
      applicationVersion: appVersion,
    );

    if (newState.status == AuthStatus.loggedIn &&
        !await _gating.serverConfigSane(serverUrl: serverUrl, credential: creds.credential)) {
      newState = newState.copyWith(serverConfigWarning: true);
    }

    // Wipe the previous user's local DB BEFORE publishing the logged-in state,
    // so no listener can react to the new identity while the old user's data
    // and queued CRUD ops are still on disk (and uploadable under the new
    // credentials). Mirrors the wipe-before-publish order of _resetSession.
    if (newState.status == AuthStatus.loggedIn && userChanged) {
      _logger.info(
        'different user logging in (was $prevUserId, now $newUserId), wiping local DB',
      );
      await _wipeOnUserSwitch();
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

  /// Clears the server config warning flag, called from the auth screen after
  /// the corresponding warning dialog has been shown to the user, so it doesn't
  /// re-appear on the next state read.
  void clearServerConfigWarning() {
    final current = state.asData?.value;
    if (current != null && current.serverConfigWarning) {
      state = AsyncData(current.copyWith(serverConfigWarning: false));
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
    // One-shot migration: if a legacy DRF token is still on disk, swap it
    // for a JWT bundle now so the rest of the auto-login can take the
    // JWT happy path. On any failure the legacy blob is left alone and the
    // user falls back to the still-supported legacy code path; the next
    // start will try again.
    await _maybeMigrateLegacyToJwt();
    final stored = await _storage.load();
    if (stored == null) {
      _logger.info('autologin failed, no saved session');
      return const AuthState();
    }
    final appVersion = await PackageInfo.fromPlatform();
    return _resolveStoredSession(stored, appVersion);
  }

  /// Exchanges a legacy DRF API token for a headless-JWT bundle and
  /// persists the result. No-op when no legacy blob is present.
  ///
  /// Sequence:
  /// 1. POST to [ISSUE_REFRESH_TOKEN_PATH] authenticated with the legacy
  ///    `Token <key>` header. The server mints a long-lived refresh token
  ///    backed by a fresh Django session.
  /// 2. Exchange that refresh token at the standard headless
  ///    `tokens/refresh` endpoint for the full access bundle (reuses
  ///    [_exchangePastedRefreshToken]).
  /// 3. Persist the bundle. [AuthCredentialsStorage.saveJwt] wipes the
  ///    legacy `PREFS_USER` blob as a side effect, so the next load sees
  ///    the JWT path.
  ///
  /// Failure handling — all branches log and return without touching
  /// state, so a re-attempt happens on the next app start:
  /// - Network error: keep the DRF token, the user continues working
  ///   against the legacy code path until connectivity returns.
  /// - 401 / 403: the DRF token has been revoked server-side. Wipe the
  ///   legacy blob so the user is routed to login (they have no usable
  ///   credential left).
  /// - 5xx / malformed body / refresh exchange failure: keep the legacy
  ///   blob and retry on the next start. The server-side session row
  ///   minted in step 1 stays orphaned but is harmless.
  Future<void> _maybeMigrateLegacyToJwt() async {
    final stored = await _storage.load();
    if (stored == null || stored.credential is! LegacyCredential) {
      return;
    }
    final legacyCred = stored.credential as LegacyCredential;
    final serverUrl = stored.serverUrl;
    final appVersion = await PackageInfo.fromPlatform();

    _logger.info('Legacy DRF token present, attempting JWT migration');

    final http.Response response;
    try {
      response = await _client.post(
        makeUri(serverUrl, ISSUE_REFRESH_TOKEN_PATH, trailingSlash: false),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.userAgentHeader: getAppNameHeader(appVersion),
          HttpHeaders.authorizationHeader: legacyCred.authHeaderValue,
        },
      );
    } on Exception catch (e, s) {
      if (isNetworkError(e)) {
        _logger.info('Legacy migration: server unreachable, keeping DRF token');
        return;
      }
      _logger.warning('Legacy migration: exchange POST threw', e, s);
      return;
    }

    if (_isAuthRejection(response.statusCode)) {
      _logger.warning(
        'Legacy migration: DRF token rejected (${response.statusCode}), wiping legacy blob',
      );
      await _storage.clearLegacy();
      return;
    }
    if (response.statusCode != 200) {
      _logger.warning(
        'Legacy migration: unexpected status ${response.statusCode}, will retry next start',
      );
      return;
    }

    final String refreshToken;
    try {
      final body = json.decode(response.body) as Map<String, dynamic>;
      refreshToken = body['refresh_token'] as String;
    } catch (e, s) {
      _logger.warning('Legacy migration: malformed response body', e, s);
      return;
    }
    if (refreshToken.isEmpty) {
      _logger.warning('Legacy migration: empty refresh_token in response');
      return;
    }

    final _FreshCredentials freshCreds;
    try {
      freshCreds = await _exchangePastedRefreshToken(refreshToken, serverUrl, appVersion);
    } on Exception catch (e, s) {
      _logger.warning('Legacy migration: refresh token exchange failed', e, s);
      return;
    }

    await _storage.saveJwt(
      credential: freshCreds.credential,
      refreshToken: freshCreds.refreshToken,
      serverUrl: serverUrl,
    );
    _logger.info('Legacy migration: successful, DRF token replaced with JWT');
  }

  /// Common path for both the headless-JWT and the legacy auto-login flows:
  /// probe the server, then run the full gating chain. Wipes the matching
  /// stored credentials on a definitive 4xx so the user is routed to login.
  Future<AuthState> _autoLoginWith(StoredAuth stored, PackageInfo appVersion) async {
    final response = await _gating.probe(
      credential: stored.credential,
      serverUrl: stored.serverUrl,
      appVersion: appVersion,
    );
    // Server unreachable at startup. The user already has a saved session, so
    // let them straight in to keep working offline.
    if (response == null) {
      _logger.info('autologin: server unreachable, continuing offline');
      return _restoredSessionState(stored, appVersion);
    }

    // The server actively rejected our token: wipe the matching credential
    // bundle and route to login. Only 401/403 count, a transient 5xx must not
    // log the user out.
    if (_isAuthRejection(response.statusCode)) {
      _logger.info('autologin failed, token rejected: ${response.statusCode}');
      await _clearStoredCredential(stored.credential);
      return AuthState(applicationVersion: appVersion);
    }

    // Any other non-200 (5xx etc.) is transient: keep the saved session.
    if (response.statusCode != 200) {
      _logger.warning(
        'autologin: probe returned ${response.statusCode}, keeping saved session',
      );
      return _restoredSessionState(stored, appVersion);
    }

    final gating = await _gating.resolve(
      credential: stored.credential,
      serverUrl: stored.serverUrl,
      appVersion: appVersion,
    );
    final newState = AuthState(
      status: gating.status,
      credential: stored.credential,
      serverUrl: stored.serverUrl,
      serverVersion: gating.serverVersion,
      applicationVersion: appVersion,
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
  Future<AuthState> _resolveStoredSession(StoredAuth stored, PackageInfo appVersion) async {
    if (!await _storage.hasEverSynced()) {
      return _autoLoginWith(stored, appVersion);
    }

    _logger.info('autologin: session restored, revalidating in background');
    _scheduleRevalidation();
    return _restoredSessionState(stored, appVersion);
  }

  /// Builds a logged-in [AuthState] for a stored session. Polymorphism in
  /// [AuthCredential] keeps this branch-free across credential variants.
  AuthState _restoredSessionState(StoredAuth stored, PackageInfo appVersion) {
    return AuthState(
      status: AuthStatus.loggedIn,
      credential: stored.credential,
      serverUrl: stored.serverUrl,
      applicationVersion: appVersion,
    );
  }

  /// Whether [statusCode] means the server actively rejected our token, as
  /// opposed to a transient error that must not invalidate the session.
  bool _isAuthRejection(int statusCode) => statusCode == 401 || statusCode == 403;

  /// Clears only the storage rows that back the given credential. Used on a
  /// definitive auth-rejection by the server so the next start routes the
  /// user to the login screen without touching the *other* credential
  /// shape (which a parallel user on the same device might still rely on).
  Future<void> _clearStoredCredential(AuthCredential credential) => switch (credential) {
    LegacyCredential() => _storage.clearLegacy(),
    JwtCredential() => _storage.clearJwt(),
  };

  /// Schedules a non-blocking revalidation of the restored session.
  ///
  /// The first run is deferred to a fresh event-loop task so [build] has
  /// completed first. It then re-runs whenever connectivity is regained, so a
  /// session restored while offline still gets validated without an app
  /// restart. Connectivity is observed directly rather than through
  /// networkStatusProvider: the revalidation only needs a "connection returned"
  /// trigger, and auth invalidates networkStatusProvider after login (see
  /// [_invalidatePostLoginProviders]), so it deliberately doesn't depend on it.
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
      var current = state.asData?.value;
      if (current == null || current.status != AuthStatus.loggedIn) {
        return;
      }

      // If the access token has expired (typical after a longer offline
      // period) refresh first, so a still-valid refresh token isn't wasted
      // by a 401 on the probe below. The refresh's own failure paths will
      // clear the session if the refresh token is also dead. Legacy
      // credentials are no-op here ([AuthCredential.needsRefresh] returns
      // false for them).
      if (current.credential?.needsRefresh(refreshLeeway) ?? false) {
        _logger.fine('revalidation: access token within leeway, refreshing first');
        await refreshAccessToken();
        current = state.asData?.value;
        if (current == null || current.status != AuthStatus.loggedIn) {
          return;
        }
      }

      final credential = current.credential;
      final serverUrl = current.serverUrl;
      if (credential == null || serverUrl == null) {
        return;
      }
      final appVersion = current.applicationVersion ?? await PackageInfo.fromPlatform();

      final response = await _gating.probe(
        credential: credential,
        serverUrl: serverUrl,
        appVersion: appVersion,
      );
      if (response == null) {
        _logger.fine('revalidation: server unreachable, keeping session');
        return;
      }
      if (_isAuthRejection(response.statusCode)) {
        _logger.info(
          'revalidation: token rejected (${response.statusCode}), clearing session',
        );
        await clearSessionOnly();
        showSessionExpiredSnackbar();
        return;
      }
      if (response.statusCode != 200) {
        _logger.warning(
          'revalidation: probe returned ${response.statusCode}, keeping session',
        );
        return;
      }

      final serverVersion = await _gating.fetchServerVersion(serverUrl);
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
      if (await _gating.applicationUpdateRequired(serverUrl, appVersion.version)) {
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
    // Re-probe reachability against the new server. NetworkStatus relies on
    // this invalidation to pick up the post-login server URL immediately.
    ref.invalidate(networkStatusProvider);
  }

  /// Exchanges the persisted refresh token for a fresh access/refresh pair.
  ///
  /// Single-flight: concurrent callers share one HTTP request. On any
  /// failure (missing refresh token, missing serverUrl, network error,
  /// non-200 response, malformed body) the session is cleared via
  /// [clearSessionOnly] so the user can re-authenticate without losing
  /// local data. Pure network errors keep the session intact so offline
  /// use continues to work.
  ///
  /// On success: `state.credential` is updated to the new JWT, the rotated
  /// refresh token (when present) is written to secure storage, and the
  /// new access token + its expiry are written to shared preferences.
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
      _logger.warning('refreshAccessToken: no serverUrl in state, clearing session');
      await clearSessionOnly();
      return;
    }

    final refreshToken = await _storage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      _logger.warning('refreshAccessToken: no refresh token in secure storage, clearing session');
      await clearSessionOnly();
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
      _logger.warning(
        'refreshAccessToken: network error, keeping session so local data stays accessible',
        e,
        s,
      );
      return;
    }

    if (response.statusCode != 200) {
      final bodySnippet = response.body.length > 200
          ? '${response.body.substring(0, 200)}...'
          : response.body;
      _logger.warning(
        'refreshAccessToken: status ${response.statusCode}, body: $bodySnippet, clearing session',
      );
      await clearSessionOnly();
      showSessionExpiredSnackbar();
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
        'refreshAccessToken: malformed response body, clearing session. Body: $bodySnippet',
        e,
        s,
      );
      await clearSessionOnly();
      showSessionExpiredSnackbar();
      return;
    }
    _logger.fine(
      'refreshAccessToken: success, new expiry $newExp, '
      'rotated refresh token: ${newRefresh != null}',
    );

    final newCred = JwtCredential(accessToken: newAccess, expiresAt: newExp);
    await _storage.updateJwt(credential: newCred, refreshToken: newRefresh);
    state = AsyncData(current.copyWith(credential: newCred));
  }

  /// User-driven logout: wipes credentials AND the local PowerSync data.
  /// Use for the explicit "Logout" buttons in the UI. For an involuntary
  /// session loss (refresh-token expired, repeated 401, etc.) call
  /// [clearSessionOnly] instead, which keeps the local DB so the user can
  /// re-authenticate without losing queued writes or cached read data.
  Future<void> logout() => _resetSession(wipeLocalData: true);

  /// Involuntary session loss: clears credentials but **keeps** the local
  /// PowerSync DB so the user can sign back in without losing queued
  /// writes or cached read data. PowerSync is disconnected, not cleared,
  /// and [PREFS_HAS_EVER_SYNCED] is preserved so the next auto-login
  /// takes the offline-friendly restored-session path.
  ///
  /// Called from refresh-token failures, repeated 401s on the HTTP
  /// client, and revalidation rejections. The UI logout button must use
  /// [logout] instead, which performs a full wipe.
  Future<void> clearSessionOnly() => _resetSession(wipeLocalData: false);

  /// Shared body for [logout] and [clearSessionOnly]. PowerSync is touched
  /// before the state mutation so a reader observing the post-reset state
  /// can never race ahead and re-attach to a DB we're about to wipe.
  Future<void> _resetSession({required bool wipeLocalData}) async {
    _logger.fine(wipeLocalData ? 'logging out' : 'clearing session, keeping local DB');
    await (wipeLocalData ? _wipePowerSyncIfBuilt() : _disconnectPowerSyncIfBuilt());
    state = AsyncData(AuthState(applicationVersion: _currentOrBlank().applicationVersion));
    await (wipeLocalData ? _storage.clearAll() : _storage.clearCredentials());
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

  /// Disconnects an already-built PowerSync DB but keeps its data on
  /// disk so a subsequent login can re-attach to the same database.
  /// No-op when PowerSync hasn't been built yet.
  Future<void> _disconnectPowerSyncIfBuilt() async {
    final db = builtPowerSyncInstance;
    if (db == null) {
      return;
    }
    try {
      await db.disconnect();
    } catch (e, s) {
      _logger.warning('PowerSync disconnect failed', e, s);
    }
  }

  /// Wipes the local PowerSync data when a different user logs in. If the
  /// DB instance already exists we use PowerSync's own [disconnectAndClear];
  /// otherwise (cold-start login as a different user) we remove the on-disk
  /// files directly so the next build starts with an empty DB.
  Future<void> _wipeOnUserSwitch() async {
    userSwitchWipeCount++;
    final db = builtPowerSyncInstance;
    if (db != null) {
      try {
        await db.disconnectAndClear();
      } catch (e, s) {
        _logger.warning('user-switch DB wipe via disconnectAndClear failed', e, s);
      }
      return;
    }
    try {
      await deletePowerSyncDatabaseFile();
    } catch (e, s) {
      _logger.warning('user-switch DB wipe via file delete failed', e, s);
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
    final v = await _gating.fetchServerVersion(current.serverUrl!);
    state = AsyncData(current.copyWith(serverVersion: v));
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

/// In-memory bundle returned by the login / signup flows. Always carries a
/// [JwtCredential] (fresh logins go through `allauth.headless`); the refresh
/// token is the one the caller still needs to write to secure storage.
typedef _FreshCredentials = ({JwtCredential credential, String? refreshToken});

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
