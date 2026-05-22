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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/providers/app_settings_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
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
      var items = container.read(appSettingsProvider).requireValue.dashboardItems;
      expect(items.isWidgetVisible(DashboardWidget.routines), false);

      await notifier.setWidgetVisible(DashboardWidget.routines, true);
      items = container.read(appSettingsProvider).requireValue.dashboardItems;
      expect(items.isWidgetVisible(DashboardWidget.routines), true);
    });

    test('reordering updates order', () async {
      await container.read(appSettingsProvider.future);
      final notifier = container.read(appSettingsProvider.notifier);

      final initial = container
          .read(appSettingsProvider)
          .requireValue
          .dashboardItems
          .visibleWidgets;
      final initialFirst = initial[0];
      final initialSecond = initial[1];

      // move first to second position (ReorderableListView semantics)
      await notifier.setDashboardOrder(0, 2);

      final updated = container
          .read(appSettingsProvider)
          .requireValue
          .dashboardItems
          .visibleWidgets;
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
        overrides: [appSettingsPrefsProvider.overrideWithValue(prefs)],
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

  group('user locale', () {
    /// Rebuilds [container] with an explicit prefs instance so the provider
    /// under test and the test assertions share the same storage. Returns
    /// that prefs instance.
    SharedPreferencesAsync freshContainerWithPrefs() {
      SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
      final prefs = SharedPreferencesAsync();

      container.dispose();
      container = ProviderContainer(
        overrides: [appSettingsPrefsProvider.overrideWithValue(prefs)],
      );
      return prefs;
    }

    /// Builds a fresh container whose [appSettingsProvider] loads from a prefs
    /// instance pre-seeded with [stored] under `PREFS_USER_LOCALE`.
    Future<AppSettings> loadWithStoredLocale(String stored) async {
      final prefs = freshContainerWithPrefs();
      await prefs.setString(PREFS_USER_LOCALE, stored);
      return container.read(appSettingsProvider.future);
    }

    test('defaults to null when no override saved', () async {
      final settings = await container.read(appSettingsProvider.future);

      // null means "follow system locale"
      expect(settings.userLocale, null);
    });

    test('setUserLocale persists language-only code to prefs', () async {
      final prefs = freshContainerWithPrefs();
      await container.read(appSettingsProvider.future);
      await container.read(appSettingsProvider.notifier).setUserLocale(const Locale('pl'));

      expect(
        container.read(appSettingsProvider).requireValue.userLocale,
        const Locale('pl'),
      );
      expect(await prefs.getString(PREFS_USER_LOCALE), 'pl');
    });

    test('setUserLocale persists country-coded locale (pt_BR)', () async {
      final prefs = freshContainerWithPrefs();
      await container.read(appSettingsProvider.future);
      await container.read(appSettingsProvider.notifier).setUserLocale(const Locale('pt', 'BR'));

      expect(await prefs.getString(PREFS_USER_LOCALE), 'pt_BR');
    });

    test('setUserLocale persists script-coded locale (zh_Hant)', () async {
      final prefs = freshContainerWithPrefs();
      await container.read(appSettingsProvider.future);
      await container
          .read(appSettingsProvider.notifier)
          .setUserLocale(
            const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
          );

      expect(await prefs.getString(PREFS_USER_LOCALE), 'zh_Hant');
    });

    test('setUserLocale(null) clears the stored override', () async {
      final prefs = freshContainerWithPrefs();
      await container.read(appSettingsProvider.future);
      final notifier = container.read(appSettingsProvider.notifier);

      await notifier.setUserLocale(const Locale('de'));
      expect(await prefs.getString(PREFS_USER_LOCALE), 'de');

      await notifier.setUserLocale(null);

      expect(container.read(appSettingsProvider).requireValue.userLocale, null);
      expect(await prefs.getString(PREFS_USER_LOCALE), null);
    });

    test('loads previously stored language-only locale on build', () async {
      final settings = await loadWithStoredLocale('de');

      expect(settings.userLocale, const Locale('de'));
    });

    test('loads previously stored country-coded locale (pt_BR)', () async {
      final settings = await loadWithStoredLocale('pt_BR');

      expect(settings.userLocale?.languageCode, 'pt');
      expect(settings.userLocale?.countryCode, 'BR');
    });

    test('loads previously stored script-coded locale (zh_Hant)', () async {
      final settings = await loadWithStoredLocale('zh_Hant');

      expect(settings.userLocale?.languageCode, 'zh');
      expect(settings.userLocale?.scriptCode, 'Hant');
    });

    test('falls back to language-only match for unknown country code', () async {
      // "pl_XX" is not a supported subtag; should fall back to "pl"
      final settings = await loadWithStoredLocale('pl_XX');

      expect(settings.userLocale, const Locale('pl'));
    });

    test('returns null for completely unsupported locale tag', () async {
      final settings = await loadWithStoredLocale('xx_YY');

      expect(settings.userLocale, null);
    });

    test('returns null for empty stored value', () async {
      final settings = await loadWithStoredLocale('');

      expect(settings.userLocale, null);
    });
  });
}
