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

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

/// Time range the user can pick to limit how far back the charts go.
///
/// The default is the shortest one: a chart is only readable if the span it
/// covers is, and the recent values are what tracking progress is about.
enum ChartRange {
  all(null),
  lastYear(365),
  last3Months(90),
  lastMonth(30);

  const ChartRange(this._days);

  final int? _days;

  /// Oldest date still shown, null for the full history.
  DateTime? get cutoff => _days == null ? null : DateTime.now().subtract(Duration(days: _days));

  /// Days read beyond [cutoff], so the moving average of the first days in
  /// range averages the days before them instead of starting over at the
  /// cutoff. The largest window a category can be set to, rather than its own,
  /// so changing that setting does not invalidate the provider.
  static final _averageLeadDays = ChartSettings.averageWindows.max;

  /// Oldest entry to read from the database, null for the full history.
  ///
  /// Rounded down to midnight, and deliberately so: this identifies a provider
  /// and has to stay the same across rebuilds, which a bound derived from the
  /// current instant would not.
  DateTime? get readCutoff {
    final from = cutoff;
    if (from == null) {
      return null;
    }

    final lead = from.subtract(Duration(days: _averageLeadDays));

    return DateTime(lead.year, lead.month, lead.day);
  }

  /// Label for the selector, counted rather than one string per range, so a
  /// range added here needs no new translation.
  String label(AppLocalizations i18n) => switch (this) {
    ChartRange.all => i18n.chartRangeAll,
    ChartRange.lastYear => i18n.chartRangeYears(1),
    ChartRange.last3Months => i18n.chartRangeMonths(3),
    ChartRange.lastMonth => i18n.chartRangeMonths(1),
  };

  /// Title for a chart of [name] over this range.
  String chartTitle(AppLocalizations i18n, String name) => switch (this) {
    ChartRange.all => i18n.chartAllTimeTitle(name),
    ChartRange.lastYear => i18n.chartLastYearTitle(name),
    ChartRange.last3Months => i18n.chartLast3MonthsTitle(name),
    ChartRange.lastMonth => i18n.chart30DaysTitle(name),
  };
}

/// Segmented buttons to pick the [ChartRange] the charts below cover.
class ChartRangeSelector extends StatelessWidget {
  final ChartRange value;
  final ValueChanged<ChartRange> onChanged;

  const ChartRangeSelector({required this.value, required this.onChanged, super.key});

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SegmentedButton<ChartRange>(
          showSelectedIcon: false,
          segments: [
            for (final range in ChartRange.values)
              ButtonSegment(value: range, label: Text(range.label(i18n))),
          ],
          selected: {value},
          onSelectionChanged: (selection) => onChanged(selection.first),
        ),
      ),
    );
  }
}
