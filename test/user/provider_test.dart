/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2026 wger Team
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

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:wger/providers/base_provider.dart';
import 'package:wger/providers/user.dart';

import '../fixtures/fixture_reader.dart';
import 'provider_test.mocks.dart';

@GenerateMocks([WgerBaseProvider])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late UserProvider userProvider;
  late MockWgerBaseProvider mockWgerBaseProvider;

  const String profileUrl = 'userprofile';
  final Map<String, dynamic> tUserProfileMap = jsonDecode(
    fixture('user/userprofile_response.json'),
  );
  final Uri tProfileUri = Uri(
    scheme: 'http',
    host: 'localhost',
    path: 'api/v2/$profileUrl/',
  );
  final Uri tEmailVerifyUri = Uri(
    scheme: 'http',
    host: 'localhost',
    path: 'api/v2/$profileUrl/verify-email',
  );

  setUp(() {
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
    mockWgerBaseProvider = MockWgerBaseProvider();
    userProvider = UserProvider(mockWgerBaseProvider, prefs: SharedPreferencesAsync());

    when(mockWgerBaseProvider.makeUrl(any)).thenReturn(tProfileUri);
    when(
      mockWgerBaseProvider.makeUrl(any, objectMethod: 'verify-email'),
    ).thenReturn(tEmailVerifyUri);
    when(
      mockWgerBaseProvider.fetch(any),
    ).thenAnswer((realInvocation) => Future.value(tUserProfileMap));
  });

  group('house keeping', () {
    test('should clear the profile list with clear()', () async {
      // arrange
      await userProvider.fetchAndSetProfile();

      // assert
      expect(userProvider.profile, isNot(null));
      expect(userProvider.profile!.username, 'admin');

      // act
      userProvider.clear();

      // assert
      expect(userProvider.profile, null);
    });
  });

  group('profile', () {
    test('Loading the profile from the server works', () async {
      // arrange
      await userProvider.fetchAndSetProfile();

      // assert
      expect(userProvider.profile!.username, 'admin');
      expect(userProvider.profile!.emailVerified, true);
      expect(userProvider.profile!.email, 'me@example.com');
      expect(userProvider.profile!.isTrustworthy, true);
    });

    test('Sending the verify email works', () async {
      // arrange
      await userProvider.fetchAndSetProfile();
      await userProvider.verifyEmail();

      // assert
      verify(userProvider.baseProvider.fetch(tEmailVerifyUri));
    });
  });

  group('dashboard config', () {
    test('initial config should be default (all visible, default order)', () {
      expect(userProvider.dashboardWidgets.length, 6);

      expect(
        userProvider.allDashboardWidgets,
        orderedEquals([
          DashboardWidget.trophies,
          DashboardWidget.routines,
          DashboardWidget.nutrition,
          DashboardWidget.weight,
          DashboardWidget.measurements,
          DashboardWidget.calendar,
        ]),
      );
      expect(userProvider.isDashboardWidgetVisible(DashboardWidget.routines), true);
    });

    test('toggling visibility should update state', () async {
      // act
      await userProvider.setDashboardWidgetVisible(DashboardWidget.routines, false);

      // assert
      expect(userProvider.isDashboardWidgetVisible(DashboardWidget.routines), false);

      // re-enable
      await userProvider.setDashboardWidgetVisible(DashboardWidget.routines, true);
      expect(userProvider.isDashboardWidgetVisible(DashboardWidget.routines), true);
    });

    test('reordering should update order', () async {
      // arrange
      final initialFirst = userProvider.dashboardWidgets[0];
      final initialSecond = userProvider.dashboardWidgets[1];

      // act: move first to second position
      // oldIndex: 0, newIndex: 2 (because insert is before index)
      await userProvider.setDashboardOrder(0, 2);

      // assert
      expect(userProvider.dashboardWidgets[0], initialSecond);
      expect(userProvider.dashboardWidgets[1], initialFirst);
    });

    test('should load config from prefs', () async {
      // arrange
      final prefs = SharedPreferencesAsync();
      final customConfig = [
        {'widget': 'nutrition', 'visible': true},
        {'widget': 'routines', 'visible': false},
      ];
      await prefs.setString(
        UserProvider.PREFS_DASHBOARD_CONFIG,
        jsonEncode(customConfig),
      );

      // act
      final newProvider = UserProvider(mockWgerBaseProvider, prefs: prefs);
      await Future.delayed(const Duration(milliseconds: 100)); // wait for async prefs load

      // assert
      // Loaded: [nutrition, routines]
      // Missing: trophies (0), weight (3), measurements (4), calendar (5)
      // 1. trophies (index 0) inserted at 0 -> [trophies, nutrition, routines]
      // 2. weight (index 3) inserted at 3 -> [trophies, nutrition, routines, weight]
      expect(newProvider.allDashboardWidgets[0], DashboardWidget.trophies);
      expect(newProvider.allDashboardWidgets[1], DashboardWidget.nutrition);
      expect(newProvider.allDashboardWidgets[2], DashboardWidget.routines);
      expect(newProvider.allDashboardWidgets[3], DashboardWidget.weight);

      // Check visibility
      expect(newProvider.isDashboardWidgetVisible(DashboardWidget.nutrition), true);
      expect(newProvider.isDashboardWidgetVisible(DashboardWidget.routines), false);

      // Missing items should be visible by default
      expect(newProvider.isDashboardWidgetVisible(DashboardWidget.weight), true);
      expect(newProvider.isDashboardWidgetVisible(DashboardWidget.trophies), true);
    });
  });
}
