/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 wger Team
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

import 'auth_notifier_powersync_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  // Replacement for SharedPreferences.setMockInitialValues() for the
  // async API used by the auth notifier.
  SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();

  late MockClient mockClient;

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
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  setUp(() async {
    mockClient = MockClient();

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

    // Persist a logged-in user so _tryAutoLogin actually runs the full
    // server + PowerSync probe path.
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

  group('_tryAutoLogin: PowerSync reachability', () {
    test('never-synced + probe succeeds → loggedIn + flag persisted', () async {
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

    test('never-synced + liveness returns 502 → powerSyncUnreachable', () async {
      when(mockClient.get(tLiveness)).thenAnswer((_) async => Response('Bad Gateway', 502));

      final container = makeContainer();
      final state = await container.read(authProvider.future);

      expect(state.status, AuthStatus.powerSyncUnreachable);
      // Saved credentials must be preserved so the recovery screen's
      // "Try again" button can re-run the flow without a re-login.
      expect(state.token, token);
      expect(state.serverUrl, serverUrl);
    });

    test('never-synced + liveness throws SocketException → powerSyncUnreachable', () async {
      when(mockClient.get(tLiveness)).thenThrow(
        const SocketException('Connection refused'),
      );

      final container = makeContainer();
      final state = await container.read(authProvider.future);

      expect(state.status, AuthStatus.powerSyncUnreachable);
    });

    test('never-synced + liveness throws ClientException → powerSyncUnreachable', () async {
      when(mockClient.get(tLiveness)).thenThrow(
        http.ClientException('SocketException: Connection refused'),
      );

      final container = makeContainer();
      final state = await container.read(authProvider.future);

      expect(state.status, AuthStatus.powerSyncUnreachable);
    });

    test(
      'never-synced + token endpoint returns empty powersync_url → powerSyncUnreachable',
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

    test('never-synced + token endpoint returns 500 → powerSyncUnreachable', () async {
      when(
        mockClient.get(tPowerSyncToken, headers: anyNamed('headers')),
      ).thenAnswer((_) async => Response('error', 500));

      final container = makeContainer();
      final state = await container.read(authProvider.future);

      expect(state.status, AuthStatus.powerSyncUnreachable);
      verifyNever(mockClient.get(tLiveness));
    });

    test('ever-synced + probe would fail → loggedIn (probe skipped)', () async {
      // Mark the user as having completed at least one sync in a previous
      // session: the probe should NOT run.
      await PreferenceHelper.asyncPref.setBool(PREFS_HAS_EVER_SYNCED, true);

      // Booby-trap both probe stages to assert they're not called.
      when(mockClient.get(tPowerSyncToken, headers: anyNamed('headers'))).thenThrow(
        const SocketException('would fail if called'),
      );
      when(mockClient.get(tLiveness)).thenThrow(
        const SocketException('would fail if called'),
      );

      final container = makeContainer();
      final state = await container.read(authProvider.future);

      expect(state.status, AuthStatus.loggedIn);
      verifyNever(mockClient.get(tPowerSyncToken, headers: anyNamed('headers')));
      verifyNever(mockClient.get(tLiveness));
    });
  });

  group('_tryAutoLogin: server reachability', () {
    test('Django HEAD throws SocketException → serverUnreachable', () async {
      when(mockClient.head(tProbe, headers: anyNamed('headers'))).thenThrow(
        http.ClientException('SocketException: Connection refused'),
      );

      final container = makeContainer();
      final state = await container.read(authProvider.future);

      expect(state.status, AuthStatus.serverUnreachable);
      // Token must be preserved so the recovery screen can retry.
      expect(state.token, token);
      expect(state.serverUrl, serverUrl);
      // PowerSync probe must NOT run when Django itself is unreachable.
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
  });

  group('logout', () {
    test('clears PREFS_HAS_EVER_SYNCED so next login re-checks PowerSync', () async {
      await PreferenceHelper.asyncPref.setBool(PREFS_HAS_EVER_SYNCED, true);

      final container = makeContainer();
      // Wait for auto-login to settle so the notifier exists.
      await container.read(authProvider.future);

      await container.read(authProvider.notifier).logout();

      expect(await PreferenceHelper.asyncPref.containsKey(PREFS_HAS_EVER_SYNCED), false);
      expect(await PreferenceHelper.asyncPref.containsKey(PREFS_USER), false);
    });
  });
}
