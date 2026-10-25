/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
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

import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wger/core/formatting/formatting.dart';
import 'package:wger/features/measurements/charts/colors.dart';
import 'package:wger/features/measurements/charts/series.dart';
import 'package:wger/features/measurements/widgets/charts/fl_axes.dart';

/// Bar chart for entries that are discrete events rather than a continuous
/// series: daily totals, and the readings of a multi-value group.
///
/// Entries carrying a range (see [MeasurementChartEntry.hasRange]) are drawn
/// as a bar spanning it, so a blood pressure reading appears as one bar from
/// diastolic to systolic. That keeps the pair together as the single event it
/// is, and claims nothing about the time between two readings.
class MeasurementBarChartWidgetFl extends StatelessWidget {
  final List<MeasurementChartEntry> _entries;
  final String _unit;

  /// Whether the values are changes rather than amounts: their bars hang off a
  /// marked zero line and are coloured by their direction.
  final bool _signed;

  const MeasurementBarChartWidgetFl(this._entries, this._unit, {bool signed = false, super.key})
    : _signed = signed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: LayoutBuilder(
        builder: (context, constraints) => BarChart(mainData(context, constraints.maxWidth)),
      ),
    );
  }

  BarTouchData tooltipData(BuildContext context) {
    return barTooltipData(context, _entries.length, (groupIndex, rod) {
      final entry = _entries[groupIndex];
      final dateStr = DateFormat.Md(
        Localizations.localeOf(context).languageCode,
      ).format(entry.date);
      // A range is quoted as high over low, the way a blood pressure
      // reading is written. A change carries its sign, and the plus has to
      // be added: only the minus comes out of the number format
      final value = entry.hasRange
          ? '${measurementValue(context, entry.max!, _unit)}'
                '/${measurementValue(context, entry.min!, _unit)}'
          : '${_signed && rod.toY > 0 ? '+' : ''}'
                '${measurementValue(context, rod.toY, _unit)}';

      return BarTooltipItem(
        '$dateStr: ${unitSuffixed(value, _unit)}',
        TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
      );
    });
  }

  BarChartData mainData(BuildContext context, double availableWidth) {
    // A range bar spans from its lower to its upper bound, so both decide the
    // axis; a plain bar grows from zero
    final drawn = <num>[
      0,
      for (final entry in _entries) ...[
        entry.value,
        if (entry.min != null) entry.min!,
        if (entry.max != null) entry.max!,
      ],
    ];
    final yAxis = valueAxis(_unit, drawn.reduce(min), drawn.reduce(max));
    final width = barWidth(_entries.length, availableWidth);

    return BarChartData(
      minY: yAxis?.min,
      maxY: yAxis?.max,
      barTouchData: tooltipData(context),
      gridData: barGrid(context),
      titlesData: barTitlesData(
        context,
        dates: [for (final entry in _entries) entry.date],
        unit: _unit,
        interval: yAxis?.interval,
      ),
      borderData: barBorder(context),
      // The line the change bars hang off. Without it a chart of only
      // decreases reads as a normal bar chart pointing the wrong way
      extraLinesData: ExtraLinesData(
        horizontalLines: [
          if (_signed)
            HorizontalLine(y: 0, color: Theme.of(context).colorScheme.outline, strokeWidth: 1),
        ],
      ),
      barGroups: _entries
          .asMap()
          .entries
          .map(
            (e) => BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  // A range spans its bounds, a plain value grows from zero
                  fromY: e.value.hasRange ? e.value.min!.toDouble() : 0,
                  toY: e.value.hasRange ? e.value.max!.toDouble() : e.value.value.toDouble(),
                  color: _signed
                      ? deltaColor(context, e.value.value)
                      : Theme.of(context).colorScheme.primary,
                  width: width,
                  borderRadius: e.value.hasRange
                      ? BorderRadius.circular(2)
                      // The rounded end is the one away from the baseline, so
                      // a bar pointing down is capped at the bottom
                      : BorderRadius.vertical(
                          top: e.value.value < 0 ? Radius.zero : const Radius.circular(2),
                          bottom: e.value.value < 0 ? const Radius.circular(2) : Radius.zero,
                        ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}
