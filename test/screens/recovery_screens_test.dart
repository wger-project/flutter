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

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
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
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/auth_notifier.dart';
import 'package:wger/screens/powersync_unreachable_screen.dart';
import 'package:wger/screens/server_unreachable_screen.dart';

import 'recovery_screens_test.mocks.dart';

/// Widget tests for the recovery screens.
@GenerateMocks([http.Client])
void main() {
  // Replacement for SharedPreferences.setMockInitialValues() for the
  // async API used by the auth notifier.
  SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();

  late MockClient mockClient;

  const serverUrl = 'https://wger.example';
  const token = 'token-12345';
  const powerSyncUrl = 'https://ps.example/';

  final tProbe = Uri.parse('$serverUrl/api/v2/routine/');
  final tVersion = Uri.parse('$serverUrl/api/v2/version/');
  final tMinAppVersion = Uri.parse('$serverUrl/api/v2/min-app-version/');
  final tPowerSyncToken = Uri.parse('$serverUrl/api/v2/powersync-token');
  final tLiveness = Uri.parse('${powerSyncUrl}probes/liveness');

  Widget wrap(Widget child) {
    return ProviderScope(
      overrides: [authHttpClientProvider.overrideWithValue(mockClient)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        // logout buttons in the recovery screens navigate to '/' after
        // calling the notifier — register both the entry route and a
        // stub for '/' so the navigation succeeds in tests. We can't
        // use `home` here since that conflicts with a routes['/'] entry.
        initialRoute: '/test',
        routes: {
          '/': (_) => const Scaffold(body: Text('AUTH_SCREEN_STUB')),
          // Wrap the screen in a Consumer that watches authProvider, so
          // the lazy provider is actually built and _tryAutoLogin runs.
          // In production this is done by MainApp before routing to the
          // recovery screens.
          '/test': (_) => Consumer(
            builder: (_, ref, _) {
              ref.watch(authProvider);
              return child;
            },
          ),
        },
      ),
    );
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

    // Saved login → autoLogin runs the full probe path.
    await prefs.setString(
      PREFS_USER,
      json.encode({'token': token, 'serverUrl': serverUrl}),
    );

    // Default happy-path mocks. Test groups override one of these to
    // steer the auth notifier into the targeted recovery state.
    when(
      mockClient.head(tProbe, headers: anyNamed('headers')),
    ).thenAnswer((_) async => Response('', 200));
    when(mockClient.get(tVersion)).thenAnswer((_) async => Response('"99.99.99"', 200));
    when(mockClient.get(tMinAppVersion)).thenAnswer((_) async => Response('"0.0.1"', 200));
    when(
      mockClient.get(tPowerSyncToken, headers: anyNamed('headers')),
    ).thenAnswer(
      (_) async => Response(
        json.encode({'token': 'jwt', 'powersync_url': powerSyncUrl}),
        200,
      ),
    );
    when(mockClient.get(tLiveness)).thenAnswer((_) async => Response('OK', 200));
  });

  group('ServerUnreachableScreen', () {
    setUp(() {
      // Drive auth notifier into AuthStatus.serverUnreachable.
      when(mockClient.head(tProbe, headers: anyNamed('headers'))).thenThrow(
        http.ClientException('SocketException: Connection refused'),
      );
    });

    testWidgets('renders title, content, server URL and both action buttons', (tester) async {
      await tester.pumpWidget(wrap(const ServerUnreachableScreen()));
      await tester.pumpAndSettle();

      expect(find.text("Couldn't connect to server"), findsOneWidget);
      expect(find.textContaining('could not connect'), findsOneWidget);
      // Server URL is shown so the user can sanity-check what we're trying.
      expect(find.text(serverUrl), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      expect(find.text('Log out'), findsOneWidget);
    });

    testWidgets('"Try again" re-runs the auto-login probe', (tester) async {
      await tester.pumpWidget(wrap(const ServerUnreachableScreen()));
      await tester.pumpAndSettle();

      // Initial autoLogin already called HEAD once.
      verify(mockClient.head(tProbe, headers: anyNamed('headers'))).called(1);

      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      // Retry triggered another autoLogin → HEAD called again.
      verify(mockClient.head(tProbe, headers: anyNamed('headers'))).called(1);
    });

    testWidgets('"Log out" wipes saved user and navigates to "/"', (tester) async {
      await tester.pumpWidget(wrap(const ServerUnreachableScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();

      // logout() removes both the user blob and the ever-synced flag.
      expect(await PreferenceHelper.asyncPref.containsKey(PREFS_USER), false);
      expect(find.text('AUTH_SCREEN_STUB'), findsOneWidget);
    });
  });

  group('PowerSyncUnreachableScreen', () {
    setUp(() {
      // Drive auth notifier into AuthStatus.powerSyncUnreachable.
      when(mockClient.get(tLiveness)).thenThrow(
        const SocketException('Connection refused'),
      );
    });

    testWidgets('renders title, content and three action buttons', (tester) async {
      await tester.pumpWidget(wrap(const PowerSyncUnreachableScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Sync service unreachable'), findsOneWidget);
      // The body should mention the PowerSync service since that's the
      // most common cause we want to guide users towards.
      expect(find.textContaining('PowerSync'), findsOneWidget);
      expect(find.text('Open documentation'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      expect(find.text('Log out'), findsOneWidget);
    });

    testWidgets('"Try again" re-runs the auto-login probe', (tester) async {
      await tester.pumpWidget(wrap(const PowerSyncUnreachableScreen()));
      await tester.pumpAndSettle();

      // Initial autoLogin probed liveness once.
      verify(mockClient.get(tLiveness)).called(1);

      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      verify(mockClient.get(tLiveness)).called(1);
    });

    testWidgets('"Log out" wipes saved user and navigates to "/"', (tester) async {
      await tester.pumpWidget(wrap(const PowerSyncUnreachableScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();

      expect(await PreferenceHelper.asyncPref.containsKey(PREFS_USER), false);
      expect(find.text('AUTH_SCREEN_STUB'), findsOneWidget);
    });
  });
}
