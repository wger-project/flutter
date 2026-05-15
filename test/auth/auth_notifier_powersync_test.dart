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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
  // Replacement for SharedPreferences.setMockInitialValues() for the
  // async API used by the auth notifier.
  SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();

  // The background revalidation observes connectivity to re-probe on
  // reconnect; stub the connectivity platform so no real plugin is needed.
  installFakeConnectivity();

  late MockClient mockClient;
  late MockSecureTokenStorage mockSecureStorage;

  const serverUrl = 'https://wger.example';
  const token = 'token-12345';
  const powerSyncUrl = 'https://ps.example/';

  // makeUri() defaults to a trailing slash; powersync-token is the one
  // endpoint registered without one on the Django side.
  final tProbe = Uri.parse('$serverUrl/api/v2/routine/');
  final tVersion = Uri.parse('$serverUrl/api/v2/version/');
  final tMinAppVersion = Uri.parse('$serverUrl/api/v2/min-app-version/');
  final tPowerSyncToken = Uri.parse('$serverUrl/api/v2/powersync-token');
  final tLiveness = Uri.parse('${powerSyncUrl}probes/liveness');

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
      expect(state.token, token);
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

    test('token rejected (401) → logged out and saved user wiped', () async {
      when(
        mockClient.head(tProbe, headers: anyNamed('headers')),
      ).thenAnswer((_) async => Response('Unauthorized', 401));

      final container = makeContainer();
      await container.read(authProvider.future);

      await container.read(authProvider.notifier).revalidationDone;

      expect(container.read(authProvider).value?.status, AuthStatus.loggedOut);
      expect(await PreferenceHelper.asyncPref.containsKey(PREFS_USER), false);
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
      expect(state.token, token);
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
      expect(state.token, token);
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
      expect(state.token, token);
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

  group('logout', () {
    test('clears PREFS_HAS_EVER_SYNCED so next login re-checks PowerSync', () async {
      await PreferenceHelper.asyncPref.setBool(PREFS_HAS_EVER_SYNCED, true);

      final container = makeContainer();
      // Wait for auto-login to settle so the notifier exists.
      await container.read(authProvider.future);
      // Drain the background revalidation before mutating state.
      await container.read(authProvider.notifier).revalidationDone;

      await container.read(authProvider.notifier).logout();

      expect(await PreferenceHelper.asyncPref.containsKey(PREFS_HAS_EVER_SYNCED), false);
      expect(await PreferenceHelper.asyncPref.containsKey(PREFS_USER), false);
    });

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
      expect(state.tokenType, AuthTokenType.headlessJwt);
      expect(state.accessToken, 'jwt-access');
      expect(state.token, isNull, reason: 'legacy `token` must stay empty on the headless path');

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
      expect(state.tokenType, AuthTokenType.legacyApiToken);
      expect(state.token, token);

      final captured =
          verify(
                mockClient.head(tProbe, headers: captureAnyNamed('headers')),
              ).captured.single
              as Map<String, String>;
      expect(captured[HttpHeaders.authorizationHeader], 'Token $token');
    });
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
            'data': {},
            'meta': {'access_token': newAccess, 'refresh_token': 'new-refresh'},
          }),
          200,
        ),
      );

      final container = makeContainer();
      await container.read(authProvider.future);
      await container.read(authProvider.notifier).refreshAccessToken();

      final state = container.read(authProvider).value!;
      expect(state.accessToken, newAccess);
      expect(state.accessExpiresAt, expectedExp);

      verify(mockSecureStorage.writeRefreshToken('new-refresh')).called(1);
      expect(await PreferenceHelper.asyncPref.getString(PREFS_ACCESS_TOKEN), newAccess);
      expect(
        await PreferenceHelper.asyncPref.getInt(PREFS_ACCESS_EXPIRES_AT),
        expectedExp.millisecondsSinceEpoch,
      );
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
            'data': {},
            'meta': {'access_token': newAccess},
          }),
          200,
        ),
      );

      final container = makeContainer();
      await container.read(authProvider.future);
      await container.read(authProvider.notifier).refreshAccessToken();

      verifyNever(mockSecureStorage.writeRefreshToken(any));
    });

    test('no refresh token in secure storage → logout', () async {
      when(mockSecureStorage.readRefreshToken()).thenAnswer((_) async => null);

      final container = makeContainer();
      await container.read(authProvider.future);
      await container.read(authProvider.notifier).refreshAccessToken();

      expect(container.read(authProvider).value!.status, AuthStatus.loggedOut);
      verifyNever(mockClient.post(tRefresh, headers: anyNamed('headers'), body: anyNamed('body')));
    });

    test('non-200 response → logout', () async {
      when(mockSecureStorage.readRefreshToken()).thenAnswer((_) async => 'old-refresh');
      when(
        mockClient.post(tRefresh, headers: anyNamed('headers'), body: anyNamed('body')),
      ).thenAnswer((_) async => Response('Unauthorized', 401));

      final container = makeContainer();
      await container.read(authProvider.future);
      await container.read(authProvider.notifier).refreshAccessToken();

      expect(container.read(authProvider).value!.status, AuthStatus.loggedOut);
    });

    test('network error → logout', () async {
      when(mockSecureStorage.readRefreshToken()).thenAnswer((_) async => 'old-refresh');
      when(
        mockClient.post(tRefresh, headers: anyNamed('headers'), body: anyNamed('body')),
      ).thenThrow(http.ClientException('SocketException: connection refused'));

      final container = makeContainer();
      await container.read(authProvider.future);
      await container.read(authProvider.notifier).refreshAccessToken();

      expect(container.read(authProvider).value!.status, AuthStatus.loggedOut);
    });

    test('malformed body (no meta) → logout', () async {
      when(mockSecureStorage.readRefreshToken()).thenAnswer((_) async => 'old-refresh');
      when(
        mockClient.post(tRefresh, headers: anyNamed('headers'), body: anyNamed('body')),
      ).thenAnswer((_) async => Response(jsonEncode({'status': 200}), 200));

      final container = makeContainer();
      await container.read(authProvider.future);
      await container.read(authProvider.notifier).refreshAccessToken();

      expect(container.read(authProvider).value!.status, AuthStatus.loggedOut);
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
            'data': {},
            'meta': {'access_token': newAccess, 'refresh_token': 'new-refresh'},
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
