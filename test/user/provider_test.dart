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

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:wger/helpers/consts.dart';
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
      await userProvider.isMetric();

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
      await userProvider.isMetric();

      // assert
      expect(userProvider.profile!.username, 'admin');
      expect(userProvider.profile!.emailVerified, true);
      expect(userProvider.profile!.email, 'me@example.com');
      expect(userProvider.profile!.isTrustworthy, true);
    });

    test('Sending the verify email works', () async {
      // arrange
      await userProvider.isMetric();
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
      await Future.delayed(const Duration(milliseconds: 100));

      // assert
      expect(newProvider.allDashboardWidgets[0], DashboardWidget.trophies);
      expect(newProvider.allDashboardWidgets[1], DashboardWidget.nutrition);
      expect(newProvider.allDashboardWidgets[2], DashboardWidget.routines);
      expect(newProvider.allDashboardWidgets[3], DashboardWidget.weight);

      expect(newProvider.isDashboardWidgetVisible(DashboardWidget.nutrition), true);
      expect(newProvider.isDashboardWidgetVisible(DashboardWidget.routines), false);

      expect(newProvider.isDashboardWidgetVisible(DashboardWidget.weight), true);
      expect(newProvider.isDashboardWidgetVisible(DashboardWidget.trophies), true);
    });
  });

  group('user locale', () {
    test('defaults to null when no override saved', () async {
      // act
      await Future.delayed(const Duration(milliseconds: 50));

      // assert: null means "follow system locale"
      expect(userProvider.userLocale, null);
    });

    test('setUserLocale persists language-only code to prefs', () async {
      // act
      await userProvider.setUserLocale(const Locale('pl'));

      // assert
      expect(userProvider.userLocale, const Locale('pl'));
      final stored = await SharedPreferencesAsync().getString(PREFS_USER_LOCALE);
      expect(stored, 'pl');
    });

    test('setUserLocale persists country-coded locale (pt_BR)', () async {
      // act
      await userProvider.setUserLocale(const Locale('pt', 'BR'));

      // assert
      final stored = await SharedPreferencesAsync().getString(PREFS_USER_LOCALE);
      expect(stored, 'pt_BR');
    });

    test('setUserLocale persists script-coded locale (zh_Hant)', () async {
      // act
      await userProvider.setUserLocale(const Locale.fromSubtags(
        languageCode: 'zh',
        scriptCode: 'Hant',
      ));

      // assert
      final stored = await SharedPreferencesAsync().getString(PREFS_USER_LOCALE);
      expect(stored, 'zh_Hant');
    });

    test('setUserLocale(null) clears the stored override', () async {
      // arrange
      await userProvider.setUserLocale(const Locale('de'));
      expect(await SharedPreferencesAsync().getString(PREFS_USER_LOCALE), 'de');

      // act
      await userProvider.setUserLocale(null);

      // assert
      expect(userProvider.userLocale, null);
      expect(await SharedPreferencesAsync().getString(PREFS_USER_LOCALE), null);
    });

    test('setUserLocale notifies listeners', () async {
      // arrange
      var notifyCount = 0;
      userProvider.addListener(() => notifyCount++);

      // act
      await userProvider.setUserLocale(const Locale('fr'));

      // assert
      expect(notifyCount, greaterThanOrEqualTo(1));
    });

    test('loads previously stored language-only locale on construction', () async {
      // arrange
      final prefs = SharedPreferencesAsync();
      await prefs.setString(PREFS_USER_LOCALE, 'de');

      // act
      final newProvider = UserProvider(mockWgerBaseProvider, prefs: prefs);
      await Future.delayed(const Duration(milliseconds: 50));

      // assert
      expect(newProvider.userLocale, const Locale('de'));
    });

    test('loads previously stored country-coded locale (pt_BR)', () async {
      // arrange
      final prefs = SharedPreferencesAsync();
      await prefs.setString(PREFS_USER_LOCALE, 'pt_BR');

      // act
      final newProvider = UserProvider(mockWgerBaseProvider, prefs: prefs);
      await Future.delayed(const Duration(milliseconds: 50));

      // assert
      expect(newProvider.userLocale?.languageCode, 'pt');
      expect(newProvider.userLocale?.countryCode, 'BR');
    });

    test('loads previously stored script-coded locale (zh_Hant)', () async {
      // arrange
      final prefs = SharedPreferencesAsync();
      await prefs.setString(PREFS_USER_LOCALE, 'zh_Hant');

      // act
      final newProvider = UserProvider(mockWgerBaseProvider, prefs: prefs);
      await Future.delayed(const Duration(milliseconds: 50));

      // assert
      expect(newProvider.userLocale?.languageCode, 'zh');
      expect(newProvider.userLocale?.scriptCode, 'Hant');
    });

    test('falls back to language-only match for unknown country code', () async {
      // arrange: "pl_XX" is not a supported subtag; should fall back to "pl"
      final prefs = SharedPreferencesAsync();
      await prefs.setString(PREFS_USER_LOCALE, 'pl_XX');

      // act
      final newProvider = UserProvider(mockWgerBaseProvider, prefs: prefs);
      await Future.delayed(const Duration(milliseconds: 50));

      // assert
      expect(newProvider.userLocale, const Locale('pl'));
    });

    test('returns null for completely unsupported locale tag', () async {
      // arrange
      final prefs = SharedPreferencesAsync();
      await prefs.setString(PREFS_USER_LOCALE, 'xx_YY');

      // act
      final newProvider = UserProvider(mockWgerBaseProvider, prefs: prefs);
      await Future.delayed(const Duration(milliseconds: 50));

      // assert
      expect(newProvider.userLocale, null);
    });

    test('returns null for empty stored value', () async {
      // arrange
      final prefs = SharedPreferencesAsync();
      await prefs.setString(PREFS_USER_LOCALE, '');

      // act
      final newProvider = UserProvider(mockWgerBaseProvider, prefs: prefs);
      await Future.delayed(const Duration(milliseconds: 50));

      // assert
      expect(newProvider.userLocale, null);
    });

    test('clear() does NOT reset the user locale (preference survives logout)', () async {
      // arrange
      await userProvider.setUserLocale(const Locale('it'));
      expect(userProvider.userLocale, const Locale('it'));

      // act
      userProvider.clear();

      // assert: clear() resets profile but locale preference is intentionally kept
      expect(userProvider.userLocale, const Locale('it'));
    });
  });

}
