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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:wger/core/app_settings_notifier.dart';
import 'package:wger/core/consts.dart';
import 'package:wger/features/measurements/charts/range.dart';
import 'package:wger/features/measurements/providers/chart_range_setting.dart';

void main() {
  late SharedPreferencesAsync prefs;
  late ProviderContainer container;

  setUp(() {
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
    prefs = SharedPreferencesAsync();
    container = ProviderContainer.test(
      overrides: [appSettingsPrefsProvider.overrideWithValue(prefs)],
    );
  });

  group('ChartRangeSetting', () {
    test('starts at the default while nothing is stored', () async {
      expect(container.read(chartRangeSettingProvider), defaultChartRange);

      await pumpEventQueue();
      expect(container.read(chartRangeSettingProvider), defaultChartRange);
    });

    test('a pick is what every watcher reads afterwards, and it is persisted', () async {
      container.read(chartRangeSettingProvider.notifier).set(ChartRange.lastWeek);

      expect(container.read(chartRangeSettingProvider), ChartRange.lastWeek);
      await pumpEventQueue();
      expect(await prefs.getString(PREFS_CHART_RANGE), 'lastWeek');
    });

    test('the stored pick survives a restart', () async {
      // Deliberately not the default, or the test would pass without loading
      await prefs.setString(PREFS_CHART_RANGE, 'lastYear');

      // A fresh container stands in for the next app run
      final restarted = ProviderContainer.test(
        overrides: [appSettingsPrefsProvider.overrideWithValue(prefs)],
      );
      restarted.listen(chartRangeSettingProvider, (_, _) {});
      await pumpEventQueue();

      expect(restarted.read(chartRangeSettingProvider), ChartRange.lastYear);
    });

    test('a value this release does not know leaves the default', () async {
      await prefs.setString(PREFS_CHART_RANGE, 'lastDecade');

      final restarted = ProviderContainer.test(
        overrides: [appSettingsPrefsProvider.overrideWithValue(prefs)],
      );
      restarted.listen(chartRangeSettingProvider, (_, _) {});
      await pumpEventQueue();

      expect(restarted.read(chartRangeSettingProvider), defaultChartRange);
    });

    test('a pick made before the stored value arrives is not overwritten', () async {
      await prefs.setString(PREFS_CHART_RANGE, 'lastYear');

      final restarted = ProviderContainer.test(
        overrides: [appSettingsPrefsProvider.overrideWithValue(prefs)],
      );
      // Picked in the very first frame, before the async load lands
      restarted.read(chartRangeSettingProvider.notifier).set(ChartRange.all);
      await pumpEventQueue();

      expect(restarted.read(chartRangeSettingProvider), ChartRange.all);
    });
  });
}
