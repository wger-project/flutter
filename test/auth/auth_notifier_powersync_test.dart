/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 - 2026 wger Team
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

import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/shared_preferences.dart';
import 'package:wger/providers/auth_notifier.dart';
import 'package:wger/providers/auth_state.dart';
import 'package:wger/providers/secure_token_storage.dart';

import '../fake_connectivity.dart';
import 'auth_notifier_powersync_test.mocks.dart';

@GenerateMocks([http.Client, SecureTokenStorage])
void main() {
  // Required so showSessionExpiredSnackbar can look up the global keys via
  // WidgetsBinding without throwing in unit tests.
  TestWidgetsFlutterBinding.ensureInitialized();

  // Replacement for SharedPreferences.setMockInitialValues() for the
  // async API used by the auth notifier.
  SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();

  // The background revalidation observes connectivity to re-probe on
  // reconnect; stub the connectivity platform so no real plugin is needed.
  installFakeConnectivity();

  late MockClient mockClient;
  late MockSecureTokenStorage mockSecureStorage;

  // Backing dir for the on-disk PowerSync wipe path (instance never built in
  // these tests). When [failDbPathLookup] is set, the path lookup throws so
  // tests can exercise a failed wipe.
  late Directory tmpDir;
  var failDbPathLookup = false;
  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

  const serverUrl = 'https://wger.example';
  const token = 'token-12345';
  const powerSyncUrl = 'https://ps.example/';

  // makeUri() defaults to a trailing slash; powersync-token,
  // issue-refresh-token are the endpoints registered without one on the
  // Django side.
  final tProbe = Uri.parse('$serverUrl/api/v2/routine/');
  final tVersion = Uri.parse('$serverUrl/api/v2/version/');
  final tMinAppVersion = Uri.parse('$serverUrl/api/v2/min-app-version/');
  final tPowerSyncToken = Uri.parse('$serverUrl/api/v2/powersync-token');
  final tLiveness = Uri.parse('${powerSyncUrl}probes/liveness');
  final tIssueRefresh = Uri.parse('$serverUrl/api/v2/issue-refresh-token');
  final tHeadlessRefresh = Uri.parse('$serverUrl/_allauth/app/v1/tokens/refresh');

  /// Builds a fresh ProviderContainer with the mock HTTP client wired into
  /// the auth notifier. Auto-disposes after the test.
  ProviderContainer makeContainer() {
    final c = ProviderContainer(
      overrides: [
        authHttpClientProvider.overrideWithValue(mockClient),
        secureTokenStorageProvider.overrideWithValue(mockSecureStorage),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  setUp(() async {
    mockClient = MockClient();
    mockSecureStorage = MockSecureTokenStorage();
    when(mockSecureStorage.deleteRefreshToken()).thenAnswer((_) async {});
    when(mockSecureStorage.readRefreshToken()).thenAnswer((_) async => null);
    when(mockSecureStorage.writeRefreshToken(any)).thenAnswer((_) async {});

    SharedPreferences.setMockInitialValues({});
    PackageInfo.setMockInitialValues(
      appName: 'wger',
      packageName: 'com.example.example',
      version: '1.2.3',
      buildNumber: '2',
      buildSignature: 'buildSignature',
    );

    // Point the on-disk wipe path at a real temp dir so a wiping logout
    // succeeds (no file present -> no-op). Set [failDbPathLookup] to make the
    // lookup throw and exercise a failed wipe.
    failDbPathLookup = false;
    tmpDir = Directory.systemTemp.createTempSync('wger_ps_auth');
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(pathProviderChannel, (call) async {
      if (failDbPathLookup) {
        throw PlatformException(code: 'unavailable', message: 'simulated path lookup failure');
      }
      return call.method == 'getApplicationSupportDirectory' ? tmpDir.path : null;
    });
    addTearDown(() {
      messenger.setMockMethodCallHandler(pathProviderChannel, null);
      if (tmpDir.existsSync()) {
        tmpDir.deleteSync(recursive: true);
      }
    });

    // Wipe async prefs between tests (the platform instance is shared).
    final prefs = PreferenceHelper.asyncPref;
    await prefs.clear();

    // Persist a logged-in user so auto-login actually runs.
    await prefs.setString(
      PREFS_USER,
      json.encode({'token': token, 'serverUrl': serverUrl}),
    );

    // Default happy-path mocks. Individual tests override what they need.
    when(
      mockClient.head(tProbe, headers: anyNamed('headers')),
    ).thenAnswer((_) async => Response('', 200));

    when(mockClient.get(tVersion)).thenAnswer((_) async => Response('"99.99.99"', 200));
    when(mockClient.get(tMinAppVersion)).thenAnswer((_) async => Response('"0.0.1"', 200));

    when(
      mockClient.get(tPowerSyncToken, headers: anyNamed('headers')),
    ).thenAnswer(
      (_) async => Response(
        json.encode({'token': 'jwt-token', 'powersync_url': powerSyncUrl}),
        200,
      ),
    );

    when(mockClient.get(tLiveness)).thenAnswer((_) async => Response('OK', 200));

    // Default: the legacy-DRF → JWT migration POST silently fails as
    // "offline" so existing tests that seed PREFS_USER fall through to the
    // legacy code path unchanged. Migration-specific tests override this.
    when(
      mockClient.post(tIssueRefresh, headers: anyNamed('headers')),
    ).thenThrow(http.ClientException('SocketException: stub default'));
  });

  group('restored session (ever-synced)', () {
    setUp(() async {
      // A previous session completed at least one sync, so there is local
      // data and the user can be let in offline-first.
      await PreferenceHelper.asyncPref.setBool(PREFS_HAS_EVER_SYNCED, true);
    });

    test('startup is immediate and makes no network calls', () async {
      final container = makeContainer();
      final state = await container.read(authProvider.future);

      expect(state.status, AuthStatus.loggedIn);
      expect((state.credential as LegacyCredential).token, token);
      expect(state.serverUrl, serverUrl);

      // The startup path must not touch the network at all; every probe
      // happens later, in the background revalidation.
      verifyNever(mockClient.head(tProbe, headers: anyNamed('headers')));
      verifyNever(mockClient.get(tVersion));
      verifyNever(mockClient.get(tMinAppVersion));
      verifyNever(mockClient.get(tPowerSyncToken, headers: anyNamed('headers')));
      verifyNever(mockClient.get(tLiveness));

      // Let the fire-and-forget revalidation settle so the test ends cleanly.
      await container.read(authProvider.notifier).revalidationDone;
    });

    test('PowerSync endpoints are never probed, not even in revalidation', () async {
      // Booby-trap the PowerSync probe stages: a restored session must never
      // hit them, neither at startup nor during the background revalidation.
      when(mockClient.get(tPowerSyncToken, headers: anyNamed('headers'))).thenThrow(
        const SocketException('would fail if called'),
      );
      when(mockClient.get(tLiveness)).thenThrow(
        const SocketException('would fail if called'),
      );

      final container = makeContainer();
      final state = await container.read(authProvider.future);
      expect(state.status, AuthStatus.loggedIn);

      await container.read(authProvider.notifier).revalidationDone;

      expect(container.read(authProvider).value?.status, AuthStatus.loggedIn);
      verifyNever(mockClient.get(tPowerSyncToken, headers: anyNamed('headers')));
      verifyNever(mockClient.get(tLiveness));
    });
  });

  group('background revalidation', () {
    setUp(() async {
      await PreferenceHelper.asyncPref.setBool(PREFS_HAS_EVER_SYNCED, true);
    });

    test('happy path leaves the user logged in', () async {
      final container = makeContainer();
      await container.read(authProvider.future);

      await container.read(authProvider.notifier).revalidationDone;

      expect(container.read(authProvider).value?.status, AuthStatus.loggedIn);
      expect(await PreferenceHelper.asyncPref.containsKey(PREFS_USER), true);
    });

    test('token rejected (401) → session cleared but local DB kept', () async {
      // Server actively rejected the token (e.g. refresh token expired after a
      // long offline period). We clear credentials and surface a snackbar via
      // [showSessionExpiredSnackbar], but the local PowerSync DB stays so the
      // user can re-authenticate without losing queued writes. Pure network
      // failures are covered by the separate 'network error' test below.
      when(
        mockClient.head(tProbe, headers: anyNamed('headers')),
      ).thenAnswer((_) async => Response('Unauthorized', 401));

      final container = makeContainer();
      await container.read(authProvider.future);

      await container.read(authProvider.notifier).revalidationDone;

      expect(container.read(authProvider).value?.status, AuthStatus.loggedOut);
      expect(await PreferenceHelper.asyncPref.containsKey(PREFS_USER), false);
      // PREFS_HAS_EVER_SYNCED stays so the next auto-login takes the offline
      // path and the cached DB stays usable.
      expect(await PreferenceHelper.asyncPref.getBool(PREFS_HAS_EVER_SYNCED), true);
    });

    test('probe returns 500 → stays logged in', () async {
      when(
        mockClient.head(tProbe, headers: anyNamed('headers')),
      ).thenAnswer((_) async => Response('Server Error', 500));

      final container = makeContainer();
      await container.read(authProvider.future);

      await container.read(authProvider.notifier).revalidationDone;

      // Regression (bug #2): a transient 5xx must not invalidate the session.
      expect(container.read(authProvider).value?.status, AuthStatus.loggedIn);
      expect(await PreferenceHelper.asyncPref.containsKey(PREFS_USER), true);
    });

    test('probe returns 502 → stays logged in', () async {
      when(
        mockClient.head(tProbe, headers: anyNamed('headers')),
      ).thenAnswer((_) async => Response('Bad Gateway', 502));

      final container = makeContainer();
      await container.read(authProvider.future);

      await container.read(authProvider.notifier).revalidationDone;

      expect(container.read(authProvider).value?.status, AuthStatus.loggedIn);
      expect(await PreferenceHelper.asyncPref.containsKey(PREFS_USER), true);
    });

    test('network error → stays logged in', () async {
      when(mockClient.head(tProbe, headers: anyNamed('headers'))).thenThrow(
        http.ClientException('SocketException: Connection refused'),
      );

      final container = makeContainer();
      await container.read(authProvider.future);

      await container.read(authProvider.notifier).revalidationDone;

      expect(container.read(authProvider).value?.status, AuthStatus.loggedIn);
      expect(await PreferenceHelper.asyncPref.containsKey(PREFS_USER), true);
    });

    test('server version too old → state moves to serverUpdateRequired', () async {
      // Probe succeeds but the server is older than MIN_SERVER_VERSION. The
      // revalidation must surface the gate so the user sees the recovery
      // screen the next time the route observes auth state.
      when(mockClient.get(tVersion)).thenAnswer((_) async => Response('"1.0.0"', 200));

      final container = makeContainer();
      await container.read(authProvider.future);

      await container.read(authProvider.notifier).revalidationDone;

      expect(container.read(authProvider).value?.status, AuthStatus.serverUpdateRequired);
      expect(container.read(authProvider).value?.serverVersion, '1.0.0');
    });

    test('app version too old → state moves to appUpdateRequired', () async {
      // Server is recent enough but the server's min-app-version is newer
      // than this build (1.2.3 from PackageInfo setUp), so the user must
      // update the app.
      when(mockClient.get(tMinAppVersion)).thenAnswer((_) async => Response('"99.0.0"', 200));

      final container = makeContainer();
      await container.read(authProvider.future);

      await container.read(authProvider.notifier).revalidationDone;

      expect(container.read(authProvider).value?.status, AuthStatus.appUpdateRequired);
    });
  });

  group('background revalidation: connectivity reconnect', () {
    late StreamController<List<ConnectivityResult>> connectivityStream;
    late ConnectivityPlatform originalPlatform;

    setUp(() async {
      // Swap in a controllable stream so we can fire reconnect events.
      originalPlatform = ConnectivityPlatform.instance;
      connectivityStream = StreamController<List<ConnectivityResult>>.broadcast();
      ConnectivityPlatform.instance = _StreamFakeConnectivity(connectivityStream.stream);
      await PreferenceHelper.asyncPref.setBool(PREFS_HAS_EVER_SYNCED, true);
    });

    tearDown(() async {
      await connectivityStream.close();
      ConnectivityPlatform.instance = originalPlatform;
    });

    test('reconnect event triggers a second revalidation probe', () async {
      final container = makeContainer();
      await container.read(authProvider.future);

      // Wait out the initial fire-and-forget revalidation.
      await container.read(authProvider.notifier).revalidationDone;
      verify(mockClient.head(tProbe, headers: anyNamed('headers'))).called(1);

      // Simulate a reconnect (going from offline to wifi).
      connectivityStream.add(const [ConnectivityResult.wifi]);
      await pumpEventQueue();
      await container.read(authProvider.notifier).revalidationDone;

      // The HEAD probe must have run again.
      verify(mockClient.head(tProbe, headers: anyNamed('headers'))).called(1);
    });

    test('offline-only event (none) does not trigger revalidation', () async {
      final container = makeContainer();
      await container.read(authProvider.future);
      await container.read(authProvider.notifier).revalidationDone;
      verify(mockClient.head(tProbe, headers: anyNamed('headers'))).called(1);

      connectivityStream.add(const [ConnectivityResult.none]);
      await pumpEventQueue();

      verifyNever(mockClient.head(tProbe, headers: anyNamed('headers')));
    });
  });

  group('never-synced session: PowerSync reachability', () {
    test('probe succeeds → loggedIn + flag persisted', () async {
      final container = makeContainer();

      final state = await container.read(authProvider.future);

      expect(state.status, AuthStatus.loggedIn);
      verify(mockClient.get(tPowerSyncToken, headers: anyNamed('headers'))).called(1);
      verify(mockClient.get(tLiveness)).called(1);
      // Successful probe must persist PREFS_HAS_EVER_SYNCED so future
      // auto-logins can short-circuit.
      expect(await PreferenceHelper.asyncPref.getBool(PREFS_HAS_EVER_SYNCED), true);
    });

    test('failed probe must NOT set the ever-synced flag', () async {
      when(mockClient.get(tLiveness)).thenAnswer((_) async => Response('Bad Gateway', 502));

      final container = makeContainer();
      await container.read(authProvider.future);

      // Flag must stay unset so the next auto-login re-probes.
      expect(await PreferenceHelper.asyncPref.containsKey(PREFS_HAS_EVER_SYNCED), false);
    });

    test('liveness returns 502 → powerSyncUnreachable', () async {
      when(mockClient.get(tLiveness)).thenAnswer((_) async => Response('Bad Gateway', 502));

      final container = makeContainer();
      final state = await container.read(authProvider.future);

      expect(state.status, AuthStatus.powerSyncUnreachable);
      // Saved credentials must be preserved so the recovery screen's
      // "Try again" button can re-run the flow without a re-login.
      expect((state.credential as LegacyCredential).token, token);
      expect(state.serverUrl, serverUrl);
    });

    test('liveness throws SocketException → powerSyncUnreachable', () async {
      when(mockClient.get(tLiveness)).thenThrow(
        const SocketException('Connection refused'),
      );

      final container = makeContainer();
      final state = await container.read(authProvider.future);

      expect(state.status, AuthStatus.powerSyncUnreachable);
    });

    test('liveness throws ClientException → powerSyncUnreachable', () async {
      when(mockClient.get(tLiveness)).thenThrow(
        http.ClientException('SocketException: Connection refused'),
      );

      final container = makeContainer();
      final state = await container.read(authProvider.future);

      expect(state.status, AuthStatus.powerSyncUnreachable);
    });

    test(
      'token endpoint returns empty powersync_url → powerSyncUnreachable',
      () async {
        when(
          mockClient.get(tPowerSyncToken, headers: anyNamed('headers')),
        ).thenAnswer(
          (_) async => Response(
            json.encode({'token': 'jwt', 'powersync_url': ''}),
            200,
          ),
        );

        final container = makeContainer();
        final state = await container.read(authProvider.future);

        expect(state.status, AuthStatus.powerSyncUnreachable);
        // Probe should never run if we can't resolve the URL.
        verifyNever(mockClient.get(tLiveness));
      },
    );

    test('token endpoint returns 500 → powerSyncUnreachable', () async {
      when(
        mockClient.get(tPowerSyncToken, headers: anyNamed('headers')),
      ).thenAnswer((_) async => Response('error', 500));

      final container = makeContainer();
      final state = await container.read(authProvider.future);

      expect(state.status, AuthStatus.powerSyncUnreachable);
      verifyNever(mockClient.get(tLiveness));
    });
  });

  group('never-synced session: server reachability', () {
    test('Django HEAD throws SocketException → logged in offline', () async {
      when(mockClient.head(tProbe, headers: anyNamed('headers'))).thenThrow(
        http.ClientException('SocketException: Connection refused'),
      );

      final container = makeContainer();
      final state = await container.read(authProvider.future);

      // A saved session must carry the user straight into the app instead of
      // stalling on a recovery screen.
      expect(state.status, AuthStatus.loggedIn);
      expect((state.credential as LegacyCredential).token, token);
      expect(state.serverUrl, serverUrl);
      // No further server calls when Django itself is unreachable.
      verifyNever(mockClient.get(tPowerSyncToken, headers: anyNamed('headers')));
    });

    test('Django HEAD returns 401 → loggedOut and saved user wiped', () async {
      when(
        mockClient.head(tProbe, headers: anyNamed('headers')),
      ).thenAnswer((_) async => Response('Unauthorized', 401));

      final container = makeContainer();
      final state = await container.read(authProvider.future);

      expect(state.status, AuthStatus.loggedOut);
      expect(await PreferenceHelper.asyncPref.containsKey(PREFS_USER), false);
    });

    test('Django HEAD returns 500 → stays logged in, session kept', () async {
      when(
        mockClient.head(tProbe, headers: anyNamed('headers')),
      ).thenAnswer((_) async => Response('Server Error', 500));

      final container = makeContainer();
      final state = await container.read(authProvider.future);

      // Regression (bug #2): a transient 5xx must not log the user out.
      expect(state.status, AuthStatus.loggedIn);
      expect((state.credential as LegacyCredential).token, token);
      expect(await PreferenceHelper.asyncPref.containsKey(PREFS_USER), true);
      // A broken server means the rest of the gating chain is skipped.
      verifyNever(mockClient.get(tPowerSyncToken, headers: anyNamed('headers')));
    });

    test('Django HEAD returns 503 → stays logged in, session kept', () async {
      when(
        mockClient.head(tProbe, headers: anyNamed('headers')),
      ).thenAnswer((_) async => Response('Service Unavailable', 503));

      final container = makeContainer();
      final state = await container.read(authProvider.future);

      expect(state.status, AuthStatus.loggedIn);
      expect(await PreferenceHelper.asyncPref.containsKey(PREFS_USER), true);
    });
  });

  group('never-synced session: version gates', () {
    test('server version too old → serverUpdateRequired', () async {
      // Never-synced path runs the full gating chain. A server below
      // MIN_SERVER_VERSION must route the user to the update screen
      // instead of completing the login.
      when(mockClient.get(tVersion)).thenAnswer((_) async => Response('"1.0.0"', 200));

      final container = makeContainer();
      final state = await container.read(authProvider.future);

      expect(state.status, AuthStatus.serverUpdateRequired);
      expect(state.serverVersion, '1.0.0');
      // PowerSync probe is gated behind the version checks.
      verifyNever(mockClient.get(tPowerSyncToken, headers: anyNamed('headers')));
    });

    test('app version too old → appUpdateRequired', () async {
      // Server is fine, but the server's min-app-version exceeds this
      // build (1.2.3 from PackageInfo setUp).
      when(mockClient.get(tMinAppVersion)).thenAnswer((_) async => Response('"99.0.0"', 200));

      final container = makeContainer();
      final state = await container.read(authProvider.future);

      expect(state.status, AuthStatus.appUpdateRequired);
      verifyNever(mockClient.get(tPowerSyncToken, headers: anyNamed('headers')));
    });
  });

  group('logout', () {
    test(
      'a wiping logout clears PREFS_HAS_EVER_SYNCED so next login re-checks PowerSync',
      () async {
        await PreferenceHelper.asyncPref.setBool(PREFS_HAS_EVER_SYNCED, true);
        // Logout keeps the local DB by default; opt out to exercise the wipe.
        await PreferenceHelper.asyncPref.setBool(PREFS_KEEP_DATA_ON_LOGOUT, false);

        final container = makeContainer();
        // Wait for auto-login to settle so the notifier exists.
        await container.read(authProvider.future);
        // Drain the background revalidation before mutating state.
        await container.read(authProvider.notifier).revalidationDone;

        await container.read(authProvider.notifier).logout();

        expect(await PreferenceHelper.asyncPref.containsKey(PREFS_HAS_EVER_SYNCED), false);
        expect(await PreferenceHelper.asyncPref.containsKey(PREFS_USER), false);
      },
    );

    test('wipes the headless-JWT prefs bundle and the secure-storage refresh token', () async {
      // Seed both formats so we can assert each gets removed.
      final prefs = PreferenceHelper.asyncPref;
      await prefs.setString(PREFS_ACCESS_TOKEN, 'jwt-access');
      await prefs.setInt(PREFS_ACCESS_EXPIRES_AT, 1700000000);
      await prefs.setString(PREFS_TOKEN_TYPE, AuthTokenType.headlessJwt.name);
      await prefs.setString(PREFS_SERVER_URL, serverUrl);

      final container = makeContainer();
      await container.read(authProvider.future);

      await container.read(authProvider.notifier).logout();

      expect(await prefs.containsKey(PREFS_ACCESS_TOKEN), false);
      expect(await prefs.containsKey(PREFS_ACCESS_EXPIRES_AT), false);
      expect(await prefs.containsKey(PREFS_TOKEN_TYPE), false);
      expect(await prefs.containsKey(PREFS_SERVER_URL), false);
      verify(mockSecureStorage.deleteRefreshToken()).called(1);
    });

    test('deletes the on-disk DB even when PowerSync was never built', () async {
      // Regression: in the cold-start case (instance not yet built, e.g. a
      // logout from the PowerSync-unreachable screen) the wipe must remove the
      // on-disk file, otherwise the owner marker is reset to null while the
      // previous user's data lingers -> the next different user docks onto it.
      final tmpDir = Directory.systemTemp.createTempSync('wger_ps_logout');
      const channel = MethodChannel('plugins.flutter.io/path_provider');
      final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(
        channel,
        (call) async => call.method == 'getApplicationSupportDirectory' ? tmpDir.path : null,
      );
      addTearDown(() {
        messenger.setMockMethodCallHandler(channel, null);
        if (tmpDir.existsSync()) {
          tmpDir.deleteSync(recursive: true);
        }
      });

      final dbFile = File('${tmpDir.path}/powersync-wger.db')..writeAsStringSync('user-7-data');
      final prefs = PreferenceHelper.asyncPref;
      await prefs.setString(PREFS_DB_OWNER_USER_ID, '7');
      // Logout keeps the local DB by default; opt out so the file is wiped.
      await prefs.setBool(PREFS_KEEP_DATA_ON_LOGOUT, false);

      final container = makeContainer();
      await container.read(authProvider.future);
      await container.read(authProvider.notifier).logout();

      expect(dbFile.existsSync(), false, reason: 'on-disk DB must be wiped on logout');
      expect(await prefs.containsKey(PREFS_DB_OWNER_USER_ID), false);
    });

    test('a failed wipe keeps the owner marker so a different user still wipes', () async {
      // If the wipe fails the data is still on disk under the old owner, so the
      // marker must NOT be reset to null: otherwise a different user signing in
      // later would dock onto the previous user's data instead of wiping it.
      final prefs = PreferenceHelper.asyncPref;
      await prefs.setString(PREFS_DB_OWNER_USER_ID, '7');
      // Logout keeps the local DB by default; opt out so the wipe is attempted.
      await prefs.setBool(PREFS_KEEP_DATA_ON_LOGOUT, false);

      final container = makeContainer();
      await container.read(authProvider.future);
      await container.read(authProvider.notifier).revalidationDone;

      // Make the on-disk wipe fail.
      failDbPathLookup = true;
      await container.read(authProvider.notifier).logout();

      // Credentials are still cleared (the user logged out), but the marker
      // survives because the data was not actually removed.
      expect(container.read(authProvider).value?.status, AuthStatus.loggedOut);
      expect(await prefs.containsKey(PREFS_USER), false);
      expect(await prefs.getString(PREFS_DB_OWNER_USER_ID), '7');
    });
  });

  group('logout: keep-data-on-logout setting', () {
    test('on (default) keeps the DB owner marker and the ever-synced flag', () async {
      final prefs = PreferenceHelper.asyncPref;
      await prefs.setString(PREFS_DB_OWNER_USER_ID, '7');
      await prefs.setBool(PREFS_HAS_EVER_SYNCED, true);

      final container = makeContainer();
      await container.read(authProvider.future);
      await container.read(authProvider.notifier).revalidationDone;
      await container.read(authProvider.notifier).logout();

      // Credentials are gone, but the local DB (its owner marker and the
      // ever-synced flag) survives so the same user resumes incrementally.
      expect(await prefs.getString(PREFS_DB_OWNER_USER_ID), '7');
      expect(await prefs.getBool(PREFS_HAS_EVER_SYNCED), true);
      expect(await prefs.containsKey(PREFS_USER), false);
    });

    test('off wipes the DB owner marker and the ever-synced flag', () async {
      final prefs = PreferenceHelper.asyncPref;
      await prefs.setBool(PREFS_KEEP_DATA_ON_LOGOUT, false);
      await prefs.setString(PREFS_DB_OWNER_USER_ID, '7');
      await prefs.setBool(PREFS_HAS_EVER_SYNCED, true);

      final container = makeContainer();
      await container.read(authProvider.future);
      await container.read(authProvider.notifier).revalidationDone;
      await container.read(authProvider.notifier).logout();

      expect(await prefs.containsKey(PREFS_DB_OWNER_USER_ID), false);
      expect(await prefs.containsKey(PREFS_HAS_EVER_SYNCED), false);
    });
  });

  group('_tryAutoLogin: headless-JWT migration', () {
    /// Replaces the legacy seed from setUp with the headless-JWT bundle.
    Future<void> seedHeadlessBundle({String accessToken = 'jwt-access'}) async {
      final prefs = PreferenceHelper.asyncPref;
      await prefs.remove(PREFS_USER);
      await prefs.setString(PREFS_ACCESS_TOKEN, accessToken);
      // Far in the future so we don't trip on expiry, refresh isn't wired yet.
      await prefs.setInt(
        PREFS_ACCESS_EXPIRES_AT,
        DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch,
      );
      await prefs.setString(PREFS_TOKEN_TYPE, AuthTokenType.headlessJwt.name);
      await prefs.setString(PREFS_SERVER_URL, serverUrl);
    }

    test('prefers the headless bundle over PREFS_USER and probes with Bearer', () async {
      // Both formats present, headless must win.
      await seedHeadlessBundle(accessToken: 'jwt-access');
      await PreferenceHelper.asyncPref.setString(
        PREFS_USER,
        json.encode({'token': 'legacy-token', 'serverUrl': serverUrl}),
      );

      final container = makeContainer();
      final state = await container.read(authProvider.future);

      expect(state.status, AuthStatus.loggedIn);
      expect(state.credential, isA<JwtCredential>());
      expect((state.credential as JwtCredential).accessToken, 'jwt-access');

      final captured =
          verify(
                mockClient.head(tProbe, headers: captureAnyNamed('headers')),
              ).captured.single
              as Map<String, String>;
      expect(captured[HttpHeaders.authorizationHeader], 'Bearer jwt-access');
    });

    test('headless 401 wipes the new prefs keys and the secure-storage refresh token', () async {
      await seedHeadlessBundle();
      when(
        mockClient.head(tProbe, headers: anyNamed('headers')),
      ).thenAnswer((_) async => Response('Unauthorized', 401));

      final container = makeContainer();
      final state = await container.read(authProvider.future);

      expect(state.status, AuthStatus.loggedOut);
      final prefs = PreferenceHelper.asyncPref;
      expect(await prefs.containsKey(PREFS_ACCESS_TOKEN), false);
      expect(await prefs.containsKey(PREFS_ACCESS_EXPIRES_AT), false);
      expect(await prefs.containsKey(PREFS_TOKEN_TYPE), false);
      expect(await prefs.containsKey(PREFS_SERVER_URL), false);
      verify(mockSecureStorage.deleteRefreshToken()).called(1);
    });

    test('missing required headless keys fall through to the legacy PREFS_USER path', () async {
      // PREFS_TOKEN_TYPE set, but PREFS_ACCESS_TOKEN missing → fall through.
      final prefs = PreferenceHelper.asyncPref;
      await prefs.setString(PREFS_TOKEN_TYPE, AuthTokenType.headlessJwt.name);
      // PREFS_USER seeded by setUp.

      final container = makeContainer();
      final state = await container.read(authProvider.future);

      expect(state.status, AuthStatus.loggedIn);
      expect(state.credential, isA<LegacyCredential>());
      expect((state.credential as LegacyCredential).token, token);

      final captured =
          verify(
                mockClient.head(tProbe, headers: captureAnyNamed('headers')),
              ).captured.single
              as Map<String, String>;
      expect(captured[HttpHeaders.authorizationHeader], 'Token $token');
    });
  });

  group('_tryAutoLogin: legacy-to-JWT migration', () {
    String makeJwt(Map<String, dynamic> payload) {
      String enc(Map<String, dynamic> m) =>
          base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
      return '${enc({'alg': 'HS256', 'typ': 'JWT'})}.${enc(payload)}.signature';
    }

    /// Stubs the two-step migration: issue-refresh-token returns
    /// [mintedRefresh], tokens/refresh returns [accessJwt] / [rotatedRefresh].
    void stubMigrationSuccess({
      required String mintedRefresh,
      required String accessJwt,
      String rotatedRefresh = 'rotated-refresh',
    }) {
      when(
        mockClient.post(tIssueRefresh, headers: anyNamed('headers')),
      ).thenAnswer(
        (_) async => Response(jsonEncode({'refresh_token': mintedRefresh}), 200),
      );
      when(
        mockClient.post(
          tHeadlessRefresh,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer(
        (_) async => Response(
          jsonEncode({
            'status': 200,
            'data': {'access_token': accessJwt, 'refresh_token': rotatedRefresh},
            'meta': {'is_authenticated': true},
          }),
          200,
        ),
      );
    }

    test('happy path: DRF token swapped for JWT bundle, PREFS_USER wiped', () async {
      // Legacy blob is already seeded in the outer setUp. The migration
      // round-trip must replace it with the headless-JWT bundle and the
      // refresh token must land in secure storage.
      final accessJwt = makeJwt({'sub': '42', 'exp': 1900000000});
      stubMigrationSuccess(
        mintedRefresh: 'minted-refresh',
        accessJwt: accessJwt,
        rotatedRefresh: 'rotated-refresh',
      );

      final container = makeContainer();
      await container.read(authProvider.future);

      final state = container.read(authProvider).value!;
      expect(state.status, AuthStatus.loggedIn);
      expect(state.credential, isA<JwtCredential>());
      expect((state.credential as JwtCredential).accessToken, accessJwt);

      final prefs = PreferenceHelper.asyncPref;
      expect(await prefs.containsKey(PREFS_USER), false);
      expect(await prefs.getString(PREFS_ACCESS_TOKEN), accessJwt);
      // The migrated user claims DB ownership so a later different-user login
      // still triggers a wipe.
      expect(await prefs.getString(PREFS_DB_OWNER_USER_ID), '42');
      verify(mockSecureStorage.writeRefreshToken('rotated-refresh')).called(1);

      // The migration POST must have been authenticated with the legacy
      // header — otherwise the backend can't identify the user.
      final captured =
          verify(
                mockClient.post(tIssueRefresh, headers: captureAnyNamed('headers')),
              ).captured.single
              as Map<String, String>;
      expect(captured[HttpHeaders.authorizationHeader], 'Token $token');
    });

    test('network error keeps the legacy DRF token in place for the next start', () async {
      // The outer setUp's default stub already throws ClientException.
      // The user must end up logged in via the legacy code path so the
      // app stays usable offline; PREFS_USER stays so the next start
      // retries the migration.
      final container = makeContainer();
      await container.read(authProvider.future);

      final state = container.read(authProvider).value!;
      expect(state.status, AuthStatus.loggedIn);
      expect(state.credential, isA<LegacyCredential>());
      expect(await PreferenceHelper.asyncPref.containsKey(PREFS_USER), true);
      // No headless prefs must have been written.
      verifyNever(mockSecureStorage.writeRefreshToken(any));
    });

    test('401 on the exchange endpoint wipes the legacy blob (token revoked)', () async {
      // A 401 here is the unambiguous "this DRF token is no longer valid"
      // signal: server-side revoked or user deleted. We wipe the blob so
      // the next start drops to the login screen instead of looping.
      when(
        mockClient.post(tIssueRefresh, headers: anyNamed('headers')),
      ).thenAnswer((_) async => Response('Unauthorized', 401));

      final container = makeContainer();
      final state = await container.read(authProvider.future);

      expect(state.status, AuthStatus.loggedOut);
      expect(await PreferenceHelper.asyncPref.containsKey(PREFS_USER), false);
      // tokens/refresh must not have been called: we never got a refresh
      // token to exchange.
      verifyNever(
        mockClient.post(
          tHeadlessRefresh,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      );
    });

    test('5xx on the exchange endpoint keeps the legacy blob for retry', () async {
      // Transient server issue: must not invalidate the local session.
      // The user keeps working with the DRF token; the next start retries.
      when(
        mockClient.post(tIssueRefresh, headers: anyNamed('headers')),
      ).thenAnswer((_) async => Response('Service Unavailable', 503));

      final container = makeContainer();
      final state = await container.read(authProvider.future);

      expect(state.status, AuthStatus.loggedIn);
      expect(state.credential, isA<LegacyCredential>());
      expect(await PreferenceHelper.asyncPref.containsKey(PREFS_USER), true);
    });

    test('malformed exchange response keeps the legacy blob for retry', () async {
      // 200 but no refresh_token in the body. Treated like a transient
      // failure: keep using the DRF token, retry next start.
      when(
        mockClient.post(tIssueRefresh, headers: anyNamed('headers')),
      ).thenAnswer((_) async => Response('{}', 200));

      final container = makeContainer();
      final state = await container.read(authProvider.future);

      expect(state.status, AuthStatus.loggedIn);
      expect(state.credential, isA<LegacyCredential>());
      expect(await PreferenceHelper.asyncPref.containsKey(PREFS_USER), true);
    });

    test('refresh-exchange failure leaves the legacy blob intact', () async {
      // issue-refresh-token succeeds, but the follow-up call to the
      // headless tokens/refresh endpoint returns 5xx. We don't commit a
      // half-migrated state: PREFS_USER stays, the user continues with
      // DRF, the next start retries from step 1.
      when(
        mockClient.post(tIssueRefresh, headers: anyNamed('headers')),
      ).thenAnswer(
        (_) async => Response(jsonEncode({'refresh_token': 'minted'}), 200),
      );
      when(
        mockClient.post(
          tHeadlessRefresh,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => Response('upstream error', 502));

      final container = makeContainer();
      final state = await container.read(authProvider.future);

      expect(state.credential, isA<LegacyCredential>());
      expect(await PreferenceHelper.asyncPref.containsKey(PREFS_USER), true);
      verifyNever(mockSecureStorage.writeRefreshToken(any));
    });

    test('no legacy blob → migration is a no-op', () async {
      // Existing headless-JWT user (or fresh install): the helper must
      // not touch the network at all.
      final prefs = PreferenceHelper.asyncPref;
      await prefs.remove(PREFS_USER);
      await prefs.setString(PREFS_ACCESS_TOKEN, 'existing-jwt');
      await prefs.setInt(
        PREFS_ACCESS_EXPIRES_AT,
        DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch,
      );
      await prefs.setString(PREFS_TOKEN_TYPE, AuthTokenType.headlessJwt.name);
      await prefs.setString(PREFS_SERVER_URL, serverUrl);
      await prefs.setBool(PREFS_HAS_EVER_SYNCED, true);

      final container = makeContainer();
      await container.read(authProvider.future);

      verifyNever(mockClient.post(tIssueRefresh, headers: anyNamed('headers')));
    });
  });

  group('background revalidation: headless pre-emptive refresh', () {
    final tRefresh = Uri.parse('$serverUrl/_allauth/app/v1/tokens/refresh');

    String makeJwt(Map<String, dynamic> payload) {
      String enc(Map<String, dynamic> m) =>
          base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
      return '${enc({'alg': 'HS256', 'typ': 'JWT'})}.${enc(payload)}.signature';
    }

    test(
      'expired access token + valid refresh token → refresh runs first, probe succeeds, '
      'session kept',
      () async {
        // Replace the legacy PREFS_USER seed with an expired headless bundle.
        // This is the exact scenario the pre-emptive refresh was added for:
        // the app was offline longer than the access-token TTL, comes back
        // online, and the connectivity-triggered revalidation must refresh
        // first instead of wasting the still-valid refresh token on a 401.
        final prefs = PreferenceHelper.asyncPref;
        await prefs.remove(PREFS_USER);
        await prefs.setString(PREFS_ACCESS_TOKEN, 'expired-access');
        await prefs.setInt(
          PREFS_ACCESS_EXPIRES_AT,
          DateTime.now().subtract(const Duration(hours: 1)).millisecondsSinceEpoch,
        );
        await prefs.setString(PREFS_TOKEN_TYPE, AuthTokenType.headlessJwt.name);
        await prefs.setString(PREFS_SERVER_URL, serverUrl);
        await prefs.setBool(PREFS_HAS_EVER_SYNCED, true);

        when(mockSecureStorage.readRefreshToken()).thenAnswer((_) async => 'good-refresh');

        final newAccess = makeJwt({
          'sub': '42',
          'exp': DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000,
        });
        when(
          mockClient.post(tRefresh, headers: anyNamed('headers'), body: anyNamed('body')),
        ).thenAnswer(
          (_) async => Response(
            jsonEncode({
              'status': 200,
              'data': {'access_token': newAccess, 'refresh_token': 'new-refresh'},
              'meta': {'is_authenticated': true},
            }),
            200,
          ),
        );

        final container = makeContainer();
        await container.read(authProvider.future);
        await container.read(authProvider.notifier).revalidationDone;

        // Refresh must have run and rotated the bundle.
        verify(
          mockClient.post(tRefresh, headers: anyNamed('headers'), body: anyNamed('body')),
        ).called(1);
        verify(mockSecureStorage.writeRefreshToken('new-refresh')).called(1);

        // No logout: session stays valid.
        final state = container.read(authProvider).value!;
        expect(state.status, AuthStatus.loggedIn);
        expect((state.credential as JwtCredential).accessToken, newAccess);
      },
    );
  });

  group('refreshAccessToken', () {
    final tRefresh = Uri.parse('$serverUrl/_allauth/app/v1/tokens/refresh');

    /// Builds a JWT-shaped string with the given payload (signature is a sham,
    /// we only ever decode the middle segment).
    String makeJwt(Map<String, dynamic> payload) {
      String enc(Map<String, dynamic> m) =>
          base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
      return '${enc({'alg': 'HS256', 'typ': 'JWT'})}.${enc(payload)}.signature';
    }

    Future<void> seedHeadlessBundle() async {
      final prefs = PreferenceHelper.asyncPref;
      await prefs.remove(PREFS_USER);
      await prefs.setString(PREFS_ACCESS_TOKEN, 'old-access');
      await prefs.setInt(
        PREFS_ACCESS_EXPIRES_AT,
        DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch,
      );
      await prefs.setString(PREFS_TOKEN_TYPE, AuthTokenType.headlessJwt.name);
      await prefs.setString(PREFS_SERVER_URL, serverUrl);
    }

    test('happy path: persists rotated refresh + updates state with new access/exp', () async {
      await seedHeadlessBundle();
      when(mockSecureStorage.readRefreshToken()).thenAnswer((_) async => 'old-refresh');

      const expSeconds = 1900000000;
      final expectedExp = DateTime.fromMillisecondsSinceEpoch(expSeconds * 1000, isUtc: true);
      final newAccess = makeJwt({'sub': '42', 'exp': expSeconds});
      when(
        mockClient.post(tRefresh, headers: anyNamed('headers'), body: anyNamed('body')),
      ).thenAnswer(
        (_) async => Response(
          jsonEncode({
            'status': 200,
            'data': {'access_token': newAccess, 'refresh_token': 'new-refresh'},
            'meta': {'is_authenticated': true},
          }),
          200,
        ),
      );

      final container = makeContainer();
      await container.read(authProvider.future);
      await container.read(authProvider.notifier).refreshAccessToken();

      final cred = container.read(authProvider).value!.credential as JwtCredential;
      expect(cred.accessToken, newAccess);
      expect(cred.expiresAt, expectedExp);

      verify(mockSecureStorage.writeRefreshToken('new-refresh')).called(1);
      expect(await PreferenceHelper.asyncPref.getString(PREFS_ACCESS_TOKEN), newAccess);
      expect(
        await PreferenceHelper.asyncPref.getInt(PREFS_ACCESS_EXPIRES_AT),
        expectedExp.millisecondsSinceEpoch,
      );
    });

    test('clearSessionOnly keeps the DB-owner marker (the local DB is preserved)', () async {
      // An involuntary clear keeps the local DB on disk, so its owner marker
      // must survive too: it is what lets a *different* user signing in later
      // still trigger a wipe, and the same user skip it.
      await seedHeadlessBundle();
      await PreferenceHelper.asyncPref.setString(PREFS_DB_OWNER_USER_ID, '42');

      final container = makeContainer();
      await container.read(authProvider.future);
      await container.read(authProvider.notifier).clearSessionOnly();

      expect(await PreferenceHelper.asyncPref.getString(PREFS_DB_OWNER_USER_ID), '42');
    });

    test('parses access_token from data', () async {
      await seedHeadlessBundle();
      when(mockSecureStorage.readRefreshToken()).thenAnswer((_) async => 'old-refresh');

      final newAccess = makeJwt({'exp': 1900000000});
      when(
        mockClient.post(tRefresh, headers: anyNamed('headers'), body: anyNamed('body')),
      ).thenAnswer(
        (_) async => Response(
          jsonEncode({
            'status': 200,
            'data': {'access_token': newAccess, 'refresh_token': 'rotated-refresh'},
            'meta': {'is_authenticated': true},
          }),
          200,
        ),
      );

      final container = makeContainer();
      await container.read(authProvider.future);
      await container.read(authProvider.notifier).refreshAccessToken();

      expect(
        (container.read(authProvider).value!.credential as JwtCredential).accessToken,
        newAccess,
      );
      verify(mockSecureStorage.writeRefreshToken('rotated-refresh')).called(1);
    });

    test('response without rotated refresh leaves the stored refresh token alone', () async {
      await seedHeadlessBundle();
      when(mockSecureStorage.readRefreshToken()).thenAnswer((_) async => 'old-refresh');

      final newAccess = makeJwt({'exp': 1900000000});
      when(
        mockClient.post(tRefresh, headers: anyNamed('headers'), body: anyNamed('body')),
      ).thenAnswer(
        (_) async => Response(
          jsonEncode({
            'status': 200,
            'data': {'access_token': newAccess},
            'meta': {'is_authenticated': true},
          }),
          200,
        ),
      );

      final container = makeContainer();
      await container.read(authProvider.future);
      await container.read(authProvider.notifier).refreshAccessToken();

      verifyNever(mockSecureStorage.writeRefreshToken(any));
    });

    test('no refresh token in secure storage → clears session, keeps DB', () async {
      // PREFS_HAS_EVER_SYNCED is the signal that the next auto-login should
      // take the offline-friendly restored-session path; it must survive an
      // involuntary session clear so the cached DB stays usable on re-login.
      await PreferenceHelper.asyncPref.setBool(PREFS_HAS_EVER_SYNCED, true);
      when(mockSecureStorage.readRefreshToken()).thenAnswer((_) async => null);

      final container = makeContainer();
      await container.read(authProvider.future);
      await container.read(authProvider.notifier).refreshAccessToken();

      expect(container.read(authProvider).value!.status, AuthStatus.loggedOut);
      expect(await PreferenceHelper.asyncPref.getBool(PREFS_HAS_EVER_SYNCED), true);
      verifyNever(mockClient.post(tRefresh, headers: anyNamed('headers'), body: anyNamed('body')));
    });

    test(
      'secure storage read throws (post-restore Keystore loss) → clears session, no throw',
      () async {
        // Android backup/restore onto a new device restores the encrypted refresh
        // token but not the Keystore key it was sealed with, so the read throws.
        // Must clear the session, not let the exception escape and loop into a
        // fatal dialog on every refresh attempt.
        await PreferenceHelper.asyncPref.setBool(PREFS_HAS_EVER_SYNCED, true);
        when(
          mockSecureStorage.readRefreshToken(),
        ).thenThrow(PlatformException(code: 'BadPaddingException'));

        final container = makeContainer();
        await container.read(authProvider.future);

        // Must complete normally; before the fix the exception escaped here.
        await container.read(authProvider.notifier).refreshAccessToken();

        expect(container.read(authProvider).value!.status, AuthStatus.loggedOut);
        expect(await PreferenceHelper.asyncPref.getBool(PREFS_HAS_EVER_SYNCED), true);
        verifyNever(
          mockClient.post(tRefresh, headers: anyNamed('headers'), body: anyNamed('body')),
        );
      },
    );

    test('non-200 response → clears session, keeps DB', () async {
      // Server reachable + non-200 means the refresh token is genuinely
      // rejected (typical for a refresh token that expired server-side after
      // a long offline period). We clear credentials + show a snackbar, but
      // the local DB stays so the user can re-authenticate without losing
      // queued writes.
      await PreferenceHelper.asyncPref.setBool(PREFS_HAS_EVER_SYNCED, true);
      when(mockSecureStorage.readRefreshToken()).thenAnswer((_) async => 'old-refresh');
      when(
        mockClient.post(tRefresh, headers: anyNamed('headers'), body: anyNamed('body')),
      ).thenAnswer((_) async => Response('Unauthorized', 401));

      final container = makeContainer();
      await container.read(authProvider.future);
      await container.read(authProvider.notifier).refreshAccessToken();

      expect(container.read(authProvider).value!.status, AuthStatus.loggedOut);
      expect(await PreferenceHelper.asyncPref.getBool(PREFS_HAS_EVER_SYNCED), true);
    });

    test('network error → stays logged in', () async {
      // Pure offline case: we cannot conclude anything about the validity of
      // the refresh token, so keep the session intact and let the user keep
      // accessing local data.
      when(mockSecureStorage.readRefreshToken()).thenAnswer((_) async => 'old-refresh');
      when(
        mockClient.post(tRefresh, headers: anyNamed('headers'), body: anyNamed('body')),
      ).thenThrow(http.ClientException('SocketException: connection refused'));

      final container = makeContainer();
      await container.read(authProvider.future);
      await container.read(authProvider.notifier).refreshAccessToken();

      expect(container.read(authProvider).value!.status, AuthStatus.loggedIn);
    });

    test('malformed body (no tokens) → clears session, keeps DB', () async {
      await PreferenceHelper.asyncPref.setBool(PREFS_HAS_EVER_SYNCED, true);
      when(mockSecureStorage.readRefreshToken()).thenAnswer((_) async => 'old-refresh');
      when(
        mockClient.post(tRefresh, headers: anyNamed('headers'), body: anyNamed('body')),
      ).thenAnswer((_) async => Response(jsonEncode({'status': 200}), 200));

      final container = makeContainer();
      await container.read(authProvider.future);
      await container.read(authProvider.notifier).refreshAccessToken();

      expect(container.read(authProvider).value!.status, AuthStatus.loggedOut);
      expect(await PreferenceHelper.asyncPref.getBool(PREFS_HAS_EVER_SYNCED), true);
    });

    test('single-flight: concurrent callers share one HTTP request', () async {
      await seedHeadlessBundle();
      when(mockSecureStorage.readRefreshToken()).thenAnswer((_) async => 'old-refresh');

      // Hold the response so both calls overlap.
      final completer = Completer<Response>();
      when(
        mockClient.post(tRefresh, headers: anyNamed('headers'), body: anyNamed('body')),
      ).thenAnswer((_) => completer.future);

      final container = makeContainer();
      await container.read(authProvider.future);
      final notifier = container.read(authProvider.notifier);

      final f1 = notifier.refreshAccessToken();
      final f2 = notifier.refreshAccessToken();

      final newAccess = makeJwt({'exp': 1900000000});
      completer.complete(
        Response(
          jsonEncode({
            'status': 200,
            'data': {'access_token': newAccess, 'refresh_token': 'new-refresh'},
            'meta': {'is_authenticated': true},
          }),
          200,
        ),
      );
      await Future.wait([f1, f2]);

      verify(
        mockClient.post(tRefresh, headers: anyNamed('headers'), body: anyNamed('body')),
      ).called(1);
    });
  });
}

/// Connectivity stub backed by a caller-controlled stream so reconnect events
/// can be driven from inside a test.
class _StreamFakeConnectivity extends ConnectivityPlatform with MockPlatformInterfaceMixin {
  _StreamFakeConnectivity(this._stream);

  final Stream<List<ConnectivityResult>> _stream;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => const [ConnectivityResult.wifi];

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => _stream;
}
