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

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/widgets.dart' show AppLifecycleListener;
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/core/consts.dart';
import 'package:wger/core/error_dialogs.dart';
import 'package:wger/core/exceptions/http_exception.dart';
import 'package:wger/core/exceptions/mfa_required_exception.dart';
import 'package:wger/core/http_overrides.dart';
import 'package:wger/core/network/auth_credentials_storage.dart';
import 'package:wger/core/network/auth_http_client.dart';
import 'package:wger/core/network/auth_state.dart';
import 'package:wger/core/network/headless_auth_api.dart';
import 'package:wger/core/network/jwt.dart';
import 'package:wger/core/network/network_provider.dart';
import 'package:wger/core/network/powersync_session.dart';
import 'package:wger/core/network/server_gating.dart';
import 'package:wger/core/shared_preferences.dart';
import 'package:wger/database/powersync/powersync.dart';
import 'package:wger/features/account/providers/account_notifier.dart';
import 'package:wger/features/account/providers/user_profile_notifier.dart';
import 'package:wger/features/gallery/providers/gallery_notifier.dart';
import 'package:wger/features/nutrition/providers/nutrition_notifier.dart';
import 'package:wger/features/routines/providers/routines_notifier.dart';
import 'package:wger/features/trophies/providers/trophy_notifier.dart';

part 'auth_notifier.g.dart';

/// Ceiling for the refresh POST. Callers are deduplicated onto one in-flight
/// refresh, so a request that never answers would block them all, PowerSync's
/// credential fetch included.
const tokenRefreshTimeout = Duration(seconds: 15);

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  final _logger = Logger('AuthNotifier');
  late HeadlessAuthApi _api;
  late AuthCredentialsStorage _storage;
  late ServerGating _gating;
  late PowerSyncSession _powerSync;

  /// Holds the in-flight refresh future so concurrent callers share a single
  /// network roundtrip. Cleared in `whenComplete` so the next refresh starts
  /// a fresh request.
  Future<void>? _refreshInFlight;

  /// Completes when the most recent background revalidation has finished.
  /// Exposed so tests can deterministically await the fire-and-forget task.
  @visibleForTesting
  Future<void>? revalidationDone;

  /// Listeners armed by [_scheduleRevalidation], replaced on re-arm: the
  /// provider is keepAlive, so stacked ones would live for good.
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  AppLifecycleListener? _lifecycleListener;

  /// Number of times the user-switch DB wipe has fired since the notifier
  /// was built. Exposed so tests can assert the user-mismatch path ran
  /// without having to instrument PowerSync or the filesystem.
  @visibleForTesting
  int userSwitchWipeCount = 0;

  @override
  Future<AuthState> build() async {
    _api = ref.read(headlessAuthApiProvider);
    _storage = ref.read(authCredentialsStorageProvider);
    _gating = ref.read(serverGatingProvider);
    _powerSync = ref.read(powerSyncSessionProvider);
    ref.onDispose(() {
      _connectivitySub?.cancel();
      _lifecycleListener?.dispose();
    });
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
    final version = await _gateBeforeAuth(serverUrl, appVersion);
    if (version.tooOld) {
      return LoginActions.update;
    }
    final creds = await _api.signup(
      username: username,
      password: password,
      email: email,
      serverUrl: serverUrl,
      appVersion: appVersion,
      locale: locale,
    );
    return _completeLogin(creds, serverUrl, appVersion, serverVersion: version.version);
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
    final version = await _gateBeforeAuth(serverUrl, appVersion);
    if (version.tooOld) {
      return LoginActions.update;
    }
    final creds = await _obtainCredentials(
      username,
      password,
      serverUrl,
      refreshToken,
      appVersion,
    );
    return _completeLogin(creds, serverUrl, appVersion, serverVersion: version.version);
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
    final version = await _gateBeforeAuth(serverUrl, appVersion);
    if (version.tooOld) {
      return LoginActions.update;
    }
    final creds = await _api.authenticateMfa(
      sessionToken: sessionToken,
      code: code,
      serverUrl: serverUrl,
      appVersion: appVersion,
    );
    return _completeLogin(creds, serverUrl, appVersion, serverVersion: version.version);
  }

  /// Checks the server version before authenticating and, when the server is
  /// too old to log into, publishes the server-update state so the router
  /// shows the update screen. Returns the gate result either way; the caller
  /// carries the version into the logged-in state when it proceeds.
  Future<({String? version, bool tooOld})> _gateBeforeAuth(
    String serverUrl,
    PackageInfo appVersion,
  ) async {
    // Narrow the certificate opt-in to the server we are about to talk to. This
    // is the single point every auth entry point passes through, and it runs
    // before the first request to that host.
    WgerHttpOverrides.trustServer(serverUrl);

    final gate = await _gating.serverVersionGate(serverUrl);
    if (gate.tooOld) {
      _logger.info('login blocked: server ${gate.version} below $MIN_SERVER_VERSION');
      state = AsyncData(
        AuthState(
          status: AuthStatus.serverUpdateRequired,
          serverUrl: serverUrl,
          serverVersion: gate.version,
          applicationVersion: appVersion,
        ),
      );
    }
    return gate;
  }

  /// The credentials a login attempt yields: the pasted refresh token when
  /// there is one (rotation invalidates it as part of the exchange), else
  /// username and password.
  Future<FreshCredentials> _obtainCredentials(
    String username,
    String password,
    String serverUrl,
    String? pastedRefreshToken,
    PackageInfo appVersion,
  ) {
    if (pastedRefreshToken != null && pastedRefreshToken.isNotEmpty) {
      return _api.exchangeRefreshToken(
        refreshToken: pastedRefreshToken,
        serverUrl: serverUrl,
        appVersion: appVersion,
      );
    }

    return _api.login(
      username: username,
      password: password,
      serverUrl: serverUrl,
      appVersion: appVersion,
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
    FreshCredentials creds,
    String serverUrl,
    PackageInfo appVersion, {
    String? serverVersion,
  }) async {
    // Compare the durable DB-owner marker against the incoming user. null
    // on the owner side means "no user data on disk" (fresh install, or the
    // DB was wiped), so there is nothing to leak; we only wipe on a
    // confirmed mismatch between two known users.
    final dbOwnerUserId = await _storage.dbOwnerUserId();
    final newUserId = creds.credential.userId;
    final userChanged = dbOwnerUserId != null && newUserId != null && dbOwnerUserId != newUserId;

    await _storage.saveJwt(
      credential: creds.credential,
      refreshToken: creds.refreshToken,
      serverUrl: serverUrl,
    );

    final status = await _gating.resolve(
      credential: creds.credential,
      serverUrl: serverUrl,
      appVersion: appVersion,
    );
    var newState = AuthState(
      status: status,
      credential: creds.credential,
      serverUrl: serverUrl,
      serverVersion: serverVersion,
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
        'different user logging in (was $dbOwnerUserId, now $newUserId), wiping local DB',
      );
      await _wipeOnUserSwitch();
    }

    // Claim DB ownership for the new user. Written AFTER any wipe (and before
    // the state publish) so a crash mid-login can never leave the marker
    // pointing at a user whose data is still on disk under old ownership.
    if (newState.status == AuthStatus.loggedIn && newUserId != null) {
      await _storage.setDbOwnerUserId(newUserId);
    }

    state = AsyncData(newState);

    if (newState.status == AuthStatus.loggedIn) {
      _powerSync.reconnect(
        serverUrl,
        ref.read(authenticatedHttpClientProvider),
        ref.read(syncWatchdogProvider),
      );
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
  /// (`ServerUnreachableScreen`, `PowerSyncUnreachableScreen`) so the user
  /// can retry without restarting the app.
  Future<void> retryAutoLogin() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_tryAutoLogin);
  }

  Future<AuthState> _tryAutoLogin() async {
    await _storage.clearLegacyDrfToken();
    final stored = await _storage.load();
    if (stored == null) {
      _logger.info('autologin failed, no saved session');
      return const AuthState();
    }
    final appVersion = await PackageInfo.fromPlatform();
    return _resolveStoredSession(stored, appVersion);
  }

  /// Auto-login path for a session that has never synced: probe the server,
  /// then run the full gating chain. Wipes the stored credentials on a
  /// definitive 4xx so the user is routed to login.
  Future<AuthState> _autoLoginWith(StoredAuth stored, PackageInfo appVersion) async {
    var session = stored;
    // The probe carries the credential itself and cannot refresh on a 403, so
    // an access token past its lifetime is renewed first.
    if (session.credential.needsRefresh(refreshLeeway)) {
      final refresh = await _refreshBeforeProbe(session, appVersion);
      if (refresh.rejected) {
        return AuthState(applicationVersion: appVersion);
      }
      if (refresh.renewed == null) {
        _logger.info('autologin: access token not renewed, continuing offline');
        return _restoredSessionState(session, appVersion);
      }
      session = refresh.renewed!;
    }

    final response = await _gating.probe(
      credential: session.credential,
      serverUrl: session.serverUrl,
      appVersion: appVersion,
    );
    // Server unreachable at startup. The user already has a saved session, so
    // let them straight in to keep working offline.
    if (response == null) {
      _logger.info('autologin: server unreachable, continuing offline');
      return _restoredSessionState(session, appVersion);
    }

    // The server actively rejected our token: wipe the stored credentials and
    // route to login. A transient 5xx must not log the user out.
    if (_isAuthRejection(response)) {
      _logger.info('autologin failed, token rejected: ${response.statusCode}');
      await _storage.clearCredentials();
      return AuthState(applicationVersion: appVersion);
    }

    // Any other non-200 (5xx etc.) is transient: keep the saved session.
    if (response.statusCode != 200) {
      _logger.warning(
        'autologin: probe returned ${response.statusCode}, keeping saved session',
      );
      return _restoredSessionState(session, appVersion);
    }

    final versionGate = await _gating.serverVersionGate(session.serverUrl);
    final status = versionGate.tooOld
        ? AuthStatus.serverUpdateRequired
        : await _gating.resolve(
            credential: session.credential,
            serverUrl: session.serverUrl,
            appVersion: appVersion,
          );
    final newState = AuthState(
      status: status,
      credential: session.credential,
      serverUrl: session.serverUrl,
      serverVersion: versionGate.version,
      applicationVersion: appVersion,
    );
    if (newState.status == AuthStatus.loggedIn) {
      _logger.info('autologin successful');
    }
    return newState;
  }

  /// Exchanges the stored refresh token for a fresh bundle ahead of the
  /// first-time probe. `renewed` carries the new session; it stays null when
  /// the server could not be reached, answered a transient status or an
  /// unreadable body. `rejected` marks a refused or missing refresh token,
  /// with the credentials already wiped.
  Future<({StoredAuth? renewed, bool rejected})> _refreshBeforeProbe(
    StoredAuth stored,
    PackageInfo appVersion,
  ) async {
    final refreshToken = await _readStoredRefreshToken();
    if (refreshToken == null) {
      _logger.warning('autologin: no usable refresh token, clearing credentials');
      await _storage.clearCredentials();
      return (renewed: null, rejected: true);
    }

    final FreshCredentials creds;
    try {
      creds = await _api
          .exchangeRefreshToken(
            refreshToken: refreshToken,
            serverUrl: stored.serverUrl,
            appVersion: appVersion,
          )
          .timeout(tokenRefreshTimeout);
    } on WgerHttpException catch (e) {
      if (_isRefreshRejection(e.statusCode ?? 0)) {
        _logger.info('autologin failed, refresh token rejected: ${e.statusCode}');
        await _storage.clearCredentials();
        return (renewed: null, rejected: true);
      }
      _logger.warning('autologin: refresh returned ${e.statusCode}, keeping saved session');
      return (renewed: null, rejected: false);
    } on Exception catch (e, s) {
      _logger.warning('autologin: refresh unreachable, keeping saved session', e, s);
      return (renewed: null, rejected: false);
    }

    await _storage.updateJwt(credential: creds.credential, refreshToken: creds.refreshToken);
    return (
      renewed: StoredAuth(credential: creds.credential, serverUrl: stored.serverUrl),
      rejected: false,
    );
  }

  /// The persisted refresh token, or null when there is none or secure storage
  /// cannot read it (e.g. an Android backup restored onto a new device leaves
  /// an undecryptable blob behind). The failure is logged here, callers only
  /// decide what to clear.
  Future<String?> _readStoredRefreshToken() async {
    try {
      final token = await _storage.readRefreshToken();
      return (token == null || token.isEmpty) ? null : token;
    } on Exception catch (e, s) {
      _logger.warning('secure storage read failed', e, s);
      return null;
    }
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

  /// Builds a logged-in [AuthState] for a stored session.
  AuthState _restoredSessionState(StoredAuth stored, PackageInfo appVersion) {
    return AuthState(
      status: AuthStatus.loggedIn,
      credential: stored.credential,
      serverUrl: stored.serverUrl,
      applicationVersion: appVersion,
    );
  }

  /// Whether the probe [response] means the server actively rejected our
  /// token, as opposed to a transient error that must not invalidate the
  /// session. A 403 counts only with the API's `token_not_valid` body, like
  /// in [AuthHttpClient]: a proxy or bot filter answers 403 too.
  bool _isAuthRejection(http.Response response) =>
      response.statusCode == 401 ||
      (response.statusCode == 403 && isTokenNotValidBody(response.body));

  /// Same question for the refresh endpoint, which reports an invalid or
  /// rotated-away refresh token as 400 (allauth's `ErrorResponse`).
  bool _isRefreshRejection(int statusCode) =>
      statusCode == 400 || statusCode == 401 || statusCode == 403;

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

    _connectivitySub?.cancel();
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (online) {
        revalidationDone = _revalidate();
      }
    });

    // A warm resume must also revalidate: the process can stay alive in the
    // background for days, so the tokens may have expired without any cold
    // start noticing. The app is offline-first, so without this a dead
    // session would only surface once some server-backed action happens to
    // run. Gated on needsRefresh so quick app switches stay request-free.
    _lifecycleListener?.dispose();
    _lifecycleListener = AppLifecycleListener(
      onResume: () {
        final credential = state.asData?.value.credential;
        if (credential?.needsRefresh(refreshLeeway) ?? false) {
          _logger.fine('revalidation: app resumed with stale access token');
          revalidationDone = _revalidate();
        }
      },
    );
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
      // clear the session if the refresh token is also dead.
      if (current.credential?.needsRefresh(refreshLeeway) ?? false) {
        _logger.fine('revalidation: access token within leeway, refreshing first');
        await refreshAccessToken();
        current = state.asData?.value;
        if (current == null || current.status != AuthStatus.loggedIn) {
          return;
        }
        // A refresh that failed on the network keeps the stale token. Probing
        // with it can only earn a 403 and a logout, so wait for the next run.
        if (current.credential?.needsRefresh(refreshLeeway) ?? false) {
          _logger.fine('revalidation: refresh did not deliver, skipping the probe');
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
      if (_isAuthRejection(response)) {
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

      final versionGate = await _gating.serverVersionGate(serverUrl);
      if (versionGate.tooOld) {
        _logger.info('revalidation: server update required');
        state = AsyncData(
          current.copyWith(
            status: AuthStatus.serverUpdateRequired,
            serverVersion: versionGate.version,
          ),
        );
        return;
      }
      if (await _gating.applicationUpdateRequired(serverUrl, appVersion.version)) {
        _logger.info('revalidation: app update required');
        state = AsyncData(
          current.copyWith(
            status: AuthStatus.appUpdateRequired,
            serverVersion: versionGate.version,
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
    // Leaf first: the providers below read reachability as they rebuild, and
    // flushing a still-dirty networkStatusProvider from a create during
    // widget build crashes. The re-probe also picks up the new server URL.
    ref.invalidate(networkStatusProvider);
    ref.invalidate(accountProvider);
    ref.invalidate(userProfileProvider);
    ref.invalidate(routinesRiverpodProvider);
    ref.invalidate(nutritionProvider);
    ref.invalidate(trophyStateProvider);
    ref.invalidate(galleryProvider);
  }

  /// Exchanges the persisted refresh token for a fresh access/refresh pair.
  ///
  /// Single-flight: concurrent callers share one HTTP request. When the
  /// server rejects the refresh token (400, 401, 403), or the stored bundle
  /// is unusable (missing refresh token, missing serverUrl, malformed body),
  /// the session is cleared via [clearSessionOnly] so the user can
  /// re-authenticate without losing local data. Network errors and transient
  /// statuses (5xx, 408, 429) keep the session so offline use continues.
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

    final refreshToken = await _readStoredRefreshToken();
    if (refreshToken == null) {
      _logger.warning('refreshAccessToken: no usable refresh token, clearing session');
      await clearSessionOnly();
      showSessionExpiredSnackbar();
      return;
    }

    final appVersion = current.applicationVersion ?? await PackageInfo.fromPlatform();
    final http.Response response;
    try {
      response = await _api
          .postTokenRefresh(
            refreshToken: refreshToken,
            serverUrl: serverUrl,
            appVersion: appVersion,
          )
          .timeout(tokenRefreshTimeout);
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
      // Only a rejection ends the session. allauth answers a dead refresh
      // token with 400; 5xx, 408 or 429 say nothing about the token.
      if (!_isRefreshRejection(response.statusCode)) {
        _logger.warning(
          'refreshAccessToken: status ${response.statusCode}, body: $bodySnippet, '
          'keeping session',
        );
        return;
      }
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
      newExp = jwtExpOnLocalClock(decodeJwtPayload(newAccess));
    } catch (e, s) {
      // Don't log the body: on the success-shaped path it holds the rotated
      // refresh token
      _logger.warning(
        'refreshAccessToken: malformed response body, clearing session. '
        'Status: ${response.statusCode}, body length: ${response.body.length}',
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

    // A logout, user switch or server change while the request was in flight
    // ended the session this result belongs to; persisting it would replant
    // the tokens into the freshly cleared storage and republish the session
    final latest = _currentOrBlank();
    if (latest.serverUrl != serverUrl ||
        latest.credential?.accessToken != current.credential?.accessToken) {
      _logger.warning('refreshAccessToken: session changed while refreshing, discarding result');
      return;
    }

    final newCred = JwtCredential(accessToken: newAccess, expiresAt: newExp);
    await _storage.updateJwt(credential: newCred, refreshToken: newRefresh);
    state = AsyncData(current.copyWith(credential: newCred));
  }

  /// User-driven logout. Always wipes credentials; the local PowerSync data is
  /// kept by default and only wiped when the user opts out
  /// ([AuthCredentialsStorage.keepDataOnLogout]).
  /// Keeping it lets the same user sign back in and resume the sync
  /// incrementally instead of re-downloading everything; the DB-owner marker is
  /// preserved so a *different* user signing in still triggers a wipe.
  ///
  /// Use for the explicit "Logout" buttons in the UI. For an involuntary
  /// session loss (refresh-token expired, repeated 401, etc.) call
  /// [clearSessionOnly] instead, which always keeps the local DB so the user
  /// can re-authenticate without losing queued writes or cached read data.
  Future<void> logout() async {
    final keepData = await _storage.keepDataOnLogout();
    await _resetSession(wipeLocalData: !keepData);
  }

  /// Involuntary session loss: clears credentials but **keeps** the local
  /// PowerSync DB so the user can sign back in without losing queued
  /// writes or cached read data. PowerSync is disconnected, not cleared,
  /// and [PREFS_HAS_EVER_SYNCED] is preserved so the next auto-login
  /// takes the offline-friendly restored-session path.
  ///
  /// Called from refresh-token failures, repeated 401s on the HTTP
  /// client, and revalidation rejections. The UI logout button must use
  /// [logout] instead, which performs a full wipe.
  Future<void> clearSessionOnly() => _resetSession(wipeLocalData: false, sessionExpired: true);

  /// Shared body for [logout] and [clearSessionOnly]. On the wipe path
  /// PowerSync is touched before the state mutation so a reader observing the
  /// post-reset state can never race ahead and re-attach to a DB we're about
  /// to wipe.
  ///
  /// [sessionExpired] marks the reset as involuntary in the published state,
  /// so the login screen can tell the user why they were logged out.
  Future<void> _resetSession({required bool wipeLocalData, bool sessionExpired = false}) async {
    _logger.fine(wipeLocalData ? 'logging out' : 'clearing session, keeping local DB');

    // A failed wipe still logs the user out, but the data is left on disk: the
    // owner marker must then survive so a later different user is detected as a
    // switch and re-wipes, rather than docking onto the leftover data.
    var wiped = true;
    if (wipeLocalData) {
      try {
        await _powerSync.wipe();
      } catch (e, s) {
        _logger.severe('logout wipe failed, keeping owner marker', e, s);
        wiped = false;
      }
    } else {
      // Deliberately not awaited: this path runs inside the single-flight
      // refresh future, and the disconnect can block on a sync fetch that is
      // itself awaiting that future (refresh -> disconnect -> sync fetch ->
      // refresh deadlock). The DB is kept, so there is no wipe to race with.
      unawaited(_powerSync.disconnect());
    }

    state = AsyncData(
      AuthState(
        applicationVersion: _currentOrBlank().applicationVersion,
        sessionExpired: sessionExpired,
      ),
    );
    if (wipeLocalData) {
      await _storage.clearAll();
      // Drop the marker only when the data was actually removed, keeping the
      // "null marker ⟺ no data" invariant. Kept on the credentials-only path
      // so a returning user is recognised.
      if (wiped) {
        await _storage.setDbOwnerUserId(null);
      }
    } else {
      await _storage.clearCredentials();
    }
  }

  /// Wipes the local PowerSync data when a different user logs in.
  Future<void> _wipeOnUserSwitch() async {
    userSwitchWipeCount++;
    await _powerSync.wipe();
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
