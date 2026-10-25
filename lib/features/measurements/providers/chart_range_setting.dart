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

import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/core/app_settings_notifier.dart';
import 'package:wger/core/consts.dart';
import 'package:wger/features/measurements/charts/range.dart';

part 'chart_range_setting.g.dart';

/// The time range the measurement charts cover, shared by the overview, the
/// category detail screens and the weight screen: a pick follows the user
/// through them instead of every screen starting over at its own default,
/// and it is persisted
///
/// keepAlive on purpose: autoDispose would reset the pick whenever no screen
/// is listening for a moment (a tab switch), which is exactly the surprise
/// this provider removes.
@Riverpod(keepAlive: true)
class ChartRangeSetting extends _$ChartRangeSetting {
  /// Whether the user picked a range this session: their pick wins over the
  /// stored one arriving late.
  bool _picked = false;

  @override
  ChartRange build() {
    unawaited(_load());
    return defaultChartRange;
  }

  /// The stored pick, applied once it is read; a value this release does not
  /// know (or none) leaves the default.
  Future<void> _load() async {
    // Read the accessor before the first await: the provider may be disposed
    // by the time the value arrives (widget tests tear the container down)
    final prefs = ref.read(appSettingsPrefsProvider);
    final stored = await prefs.getString(PREFS_CHART_RANGE);
    final range = ChartRange.values.firstWhereOrNull((r) => r.name == stored);
    if (ref.mounted && range != null && !_picked) {
      state = range;
    }
  }

  void set(ChartRange range) {
    _picked = true;
    state = range;
    // Fire and forget: the pick applies immediately, nothing waits on disk
    unawaited(ref.read(appSettingsPrefsProvider).setString(PREFS_CHART_RANGE, range.name));
  }
}
