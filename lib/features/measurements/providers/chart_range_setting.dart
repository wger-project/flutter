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

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/features/measurements/charts/range.dart';

part 'chart_range_setting.g.dart';

/// The time range the measurement charts cover, shared by the overview, the
/// category detail screens and the weight screen: a pick follows the user
/// through them instead of every screen starting over at its own default.
///
/// keepAlive on purpose: autoDispose would reset the pick whenever no screen
/// is listening for a moment (a tab switch), which is exactly the surprise
/// this provider removes. It holds for the session; a restart starts over.
@Riverpod(keepAlive: true)
class ChartRangeSetting extends _$ChartRangeSetting {
  @override
  ChartRange build() => ChartRange.last3Months;

  void set(ChartRange range) => state = range;
}
