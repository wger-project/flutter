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

/// The fl_chart scaffolding the measurement charts share: axes, grid, border
/// and the tooltip shell, so every chart of the set draws them the same way.
library;

import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';
import 'package:wger/core/formatting/formatting.dart';

/// Number of dates to label on the x axis
const _xLabelCount = 4;

/// Widest a single bar gets, for charts with only a handful of entries
const _maxBarWidth = 12.0;

const hiddenTitles = AxisTitles(sideTitles: SideTitles(showTitles: false));

/// Y-axis tick label that never wraps: a long value+unit combination shrinks
/// to fit the reserved width instead of breaking into overlapping lines.
class _YAxisLabel extends StatelessWidget {
  const _YAxisLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(text, maxLines: 1),
    );
  }
}

/// The value axis, drawn the same way by every chart of the set.
AxisTitles valueTitles(BuildContext context, String unit, double? interval) => AxisTitles(
  sideTitles: SideTitles(
    showTitles: true,
    reservedSize: 65,
    interval: interval,
    getTitlesWidget: (value, meta) {
      // Don't show the first and last entries, to avoid overlap
      // see https://stackoverflow.com/questions/73355777/flutter-fl-chart-how-can-we-avoid-the-overlap-of-the-ordinate
      // this is needlessly aggressive if the titles are "sparse", but we should optimize for more busy data
      if (value == meta.min || value == meta.max) {
        return const Text('');
      }

      return _YAxisLabel(measurementWithUnit(context, value, unit));
    },
  ),
);

/// The date axis of the bar charts, which draw one title per group: their x
/// value is a position in [dates] rather than a timestamp, so thinning the
/// labels out has to happen here.
AxisTitles _dateIndexTitles(BuildContext context, List<DateTime> dates) {
  final labelStep = max(1, (dates.length / _xLabelCount).ceil());
  // keep the labels away from the chart edges
  final labelOffset = labelStep ~/ 2;
  final spansYears = dates.isNotEmpty && dates.first.year != dates.last.year;

  return AxisTitles(
    sideTitles: SideTitles(
      showTitles: true,
      getTitlesWidget: (value, meta) {
        final index = value.toInt();
        if (index < 0 || index >= dates.length) {
          return const Text('');
        }
        if ((index - labelOffset) % labelStep != 0) {
          return const Text('');
        }
        // if we go across years, show years in the ticks. otherwise leave them out
        final date = dates[index];
        if (spansYears) {
          return Text(localizedDate(context).format(date));
        }
        return Text(DateFormat.Md(Localizations.localeOf(context).languageCode).format(date));
      },
    ),
  );
}

/// The axes of the bar charts: value left, one date per group below, the
/// mirroring sides hidden.
FlTitlesData barTitlesData(
  BuildContext context, {
  required List<DateTime> dates,
  required String unit,
  required double? interval,
}) => FlTitlesData(
  show: true,
  rightTitles: hiddenTitles,
  topTitles: hiddenTitles,
  bottomTitles: _dateIndexTitles(context, dates),
  leftTitles: valueTitles(context, unit, interval),
);

/// Bar width in pixels: the bars share the available width and keep a gap
/// between them, but never go below a hairline. Without it a couple of months
/// of readings overlap into a solid block.
double barWidth(int count, double availableWidth) =>
    count == 0 ? _maxBarWidth : (availableWidth / count * 0.7).clamp(1.0, _maxBarWidth);

/// Horizontal lines only: a vertical one per bar would only repeat the bars.
FlGridData barGrid(BuildContext context) => FlGridData(
  show: true,
  drawVerticalLine: false,
  getDrawingHorizontalLine: (value) =>
      FlLine(color: Theme.of(context).colorScheme.primaryContainer, strokeWidth: 1),
);

FlBorderData barBorder(BuildContext context) => FlBorderData(
  show: true,
  border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
);

/// The tooltip shell of the bar charts: kept inside the chart (a tooltip near
/// an edge would otherwise be cut off by it) and guarded against fl_chart
/// handing over an index outside the entries. What a tooltip says comes from
/// [itemFor].
BarTouchData barTooltipData(
  BuildContext context,
  int entryCount,
  BarTooltipItem? Function(int groupIndex, BarChartRodData rod) itemFor,
) => BarTouchData(
  touchTooltipData: BarTouchTooltipData(
    fitInsideHorizontally: true,
    fitInsideVertically: true,
    getTooltipColor: (group) => Theme.of(context).colorScheme.primaryContainer,
    getTooltipItem: (group, groupIndex, rod, rodIndex) =>
        groupIndex < 0 || groupIndex >= entryCount ? null : itemFor(groupIndex, rod),
  ),
);
