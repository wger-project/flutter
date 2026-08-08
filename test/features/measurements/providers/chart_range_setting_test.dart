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
import 'package:wger/features/measurements/charts/range.dart';
import 'package:wger/features/measurements/providers/chart_range_setting.dart';

void main() {
  group('ChartRangeSetting', () {
    test('starts at the default the screens used to seed themselves with', () {
      final container = ProviderContainer.test();

      expect(container.read(chartRangeSettingProvider), ChartRange.last3Months);
    });

    test('a pick is what every watcher reads afterwards', () {
      final container = ProviderContainer.test();

      container.read(chartRangeSettingProvider.notifier).set(ChartRange.lastWeek);

      expect(container.read(chartRangeSettingProvider), ChartRange.lastWeek);
    });
  });
}
