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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:wger/models/user/profile.dart';
import 'package:wger/providers/app_settings_notifier.dart';
import 'package:wger/providers/user_profile_notifier.dart';
import 'package:wger/providers/user_profile_repository.dart';

import '../fixtures/fixture_reader.dart';
import 'provider_test.mocks.dart';

@GenerateMocks([UserProfileRepository])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final Profile tProfile = Profile.fromJson(
    jsonDecode(fixture('user/userprofile_response.json')) as Map<String, dynamic>,
  );

  late MockUserProfileRepository mockRepo;
  late ProviderContainer container;

  setUp(() {
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
    mockRepo = MockUserProfileRepository();
    when(mockRepo.fetchProfile()).thenAnswer((_) async => tProfile);

    container = ProviderContainer(
      overrides: [
        userProfileRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('profile', () {
    test('build fetches the profile from the repository', () async {
      final profile = await container.read(userProfileProvider.future);

      expect(profile, isNotNull);
      expect(profile!.username, 'admin');
      expect(profile.emailVerified, true);
      expect(profile.email, 'me@example.com');
      expect(profile.isTrustworthy, true);
      verify(mockRepo.fetchProfile()).called(1);
    });

    test('clear() resets the profile to null', () async {
      await container.read(userProfileProvider.future);
      expect(container.read(userProfileProvider).value, isNotNull);

      container.read(userProfileProvider.notifier).clear();
      expect(container.read(userProfileProvider).value, isNull);
    });

    test('saveProfile delegates to the repository', () async {
      await container.read(userProfileProvider.future);
      when(mockRepo.saveProfile(any)).thenAnswer((_) async {});

      await container.read(userProfileProvider.notifier).saveProfile();

      verify(mockRepo.saveProfile(tProfile)).called(1);
    });

    test('verifyEmail delegates to the repository', () async {
      await container.read(userProfileProvider.future);
      when(mockRepo.verifyEmail()).thenAnswer((_) async {});

      await container.read(userProfileProvider.notifier).verifyEmail();

      verify(mockRepo.verifyEmail()).called(1);
    });
  });

  group('dashboard config', () {
    test('initial config is default (all visible, default order)', () async {
      final settings = await container.read(appSettingsProvider.future);
      final items = settings.dashboardItems;

      expect(items.allWidgets.length, DashboardWidget.values.length);
      expect(
        items.allWidgets,
        orderedEquals([
          DashboardWidget.networkInfo,
          DashboardWidget.trophies,
          DashboardWidget.routines,
          DashboardWidget.nutrition,
          DashboardWidget.weight,
          DashboardWidget.measurements,
          DashboardWidget.calendar,
        ]),
      );
      expect(items.isWidgetVisible(DashboardWidget.routines), true);
    });

    test('toggling visibility updates state', () async {
      await container.read(appSettingsProvider.future);
      final notifier = container.read(appSettingsProvider.notifier);

      await notifier.setWidgetVisible(DashboardWidget.routines, false);
      var items = container.read(appSettingsProvider).value!.dashboardItems;
      expect(items.isWidgetVisible(DashboardWidget.routines), false);

      await notifier.setWidgetVisible(DashboardWidget.routines, true);
      items = container.read(appSettingsProvider).value!.dashboardItems;
      expect(items.isWidgetVisible(DashboardWidget.routines), true);
    });

    test('reordering updates order', () async {
      await container.read(appSettingsProvider.future);
      final notifier = container.read(appSettingsProvider.notifier);

      final initial = container.read(appSettingsProvider).value!.dashboardItems.visibleWidgets;
      final initialFirst = initial[0];
      final initialSecond = initial[1];

      // move first to second position (ReorderableListView semantics)
      await notifier.setDashboardOrder(0, 2);

      final updated = container.read(appSettingsProvider).value!.dashboardItems.visibleWidgets;
      expect(updated[0], initialSecond);
      expect(updated[1], initialFirst);
    });

    test('loads config from prefs when present', () async {
      // Use a dedicated in-memory prefs instance to avoid bleed from other tests.
      SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
      final prefs = SharedPreferencesAsync();
      final customConfig = [
        {'widget': 'nutrition', 'visible': true},
        {'widget': 'routines', 'visible': false},
      ];
      await prefs.setString(PREFS_DASHBOARD_CONFIG, jsonEncode(customConfig));

      // Fresh container so the keepAlive notifier builds with the just-written prefs.
      container.dispose();
      container = ProviderContainer(
        overrides: [
          userProfileRepositoryProvider.overrideWithValue(mockRepo),
          appSettingsPrefsProvider.overrideWithValue(prefs),
        ],
      );

      final settings = await container.read(appSettingsProvider.future);
      final items = settings.dashboardItems;

      // Loaded: [nutrition, routines], then defaults insert around:
      // networkInfo (0) → 0, trophies (1) → 1, weight (4), measurements (5), calendar (6)
      expect(items.allWidgets[0], DashboardWidget.networkInfo);
      expect(items.allWidgets[1], DashboardWidget.trophies);
      expect(items.allWidgets[2], DashboardWidget.nutrition);
      expect(items.allWidgets[3], DashboardWidget.routines);
      expect(items.allWidgets[4], DashboardWidget.weight);

      expect(items.isWidgetVisible(DashboardWidget.nutrition), true);
      expect(items.isWidgetVisible(DashboardWidget.routines), false);

      // Missing items default to visible
      expect(items.isWidgetVisible(DashboardWidget.networkInfo), true);
      expect(items.isWidgetVisible(DashboardWidget.weight), true);
      expect(items.isWidgetVisible(DashboardWidget.trophies), true);
    });
  });
}
