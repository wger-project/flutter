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
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wger/core/formatting/formatting.dart';
import 'package:wger/features/measurements/charts/colors.dart';
import 'package:wger/features/measurements/charts/series.dart';
import 'package:wger/features/measurements/widgets/charts/fl_axes.dart';

/// Stacked bar chart for a group whose components are parts of one whole, e.g.
/// the sleep stages of a night.
///
/// One bar per day, split into a segment per component in the components' own
/// order, so the bar's height is the night and its segments are how it was
/// spent. Colours come from [componentColor] by position, which is what ties a
/// segment to its legend entry.
class MeasurementStackedBarChartWidgetFl extends StatelessWidget {
  final List<MeasurementStackedEntry> _entries;
  final List<String> _labels;
  final String _unit;

  const MeasurementStackedBarChartWidgetFl(this._entries, this._labels, this._unit, {super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.70,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: LayoutBuilder(
          builder: (context, constraints) => BarChart(mainData(context, constraints.maxWidth)),
        ),
      ),
    );
  }

  /// The whole bar with its parts, since a single segment says little without
  /// the night it belongs to.
  BarTouchData tooltipData(BuildContext context) {
    return barTooltipData(context, _entries.length, (groupIndex, rod) {
      final entry = _entries[groupIndex];
      final dateStr = DateFormat.Md(
        Localizations.localeOf(context).languageCode,
      ).format(entry.date);
      final parts = [
        for (final (index, value) in entry.values.indexed)
          if (value != null) '${_labels[index]}: ${measurementValue(context, value, _unit)}',
      ];

      return BarTooltipItem(
        '$dateStr: ${measurementWithUnit(context, entry.total, _unit)}'
        '${parts.isEmpty ? '' : '\n${parts.join('\n')}'}',
        TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
      );
    });
  }

  BarChartData mainData(BuildContext context, double availableWidth) {
    // The bar is as tall as its segments together, so that is what the axis
    // has to cover
    final yAxis = valueAxis(_unit, 0, _entries.map((e) => e.total).fold<num>(0, max));
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
      barGroups: _entries.asMap().entries.map((e) {
        // fl_chart stacks by absolute offsets rather than by segment heights,
        // so each part is placed on top of what came before it
        var offset = 0.0;
        final stack = <BarChartRodStackItem>[];
        for (final (index, value) in e.value.values.indexed) {
          if (value == null || value <= 0) {
            continue;
          }
          stack.add(
            BarChartRodStackItem(offset, offset + value.toDouble(), componentColor(context, index)),
          );
          offset += value.toDouble();
        }

        return BarChartGroupData(
          x: e.key,
          barRods: [
            BarChartRodData(
              toY: offset,
              width: width,
              rodStackItems: stack,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
            ),
          ],
        );
      }).toList(),
    );
  }
}
