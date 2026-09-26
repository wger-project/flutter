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

/// The spark charts of the overview tiles: value as the hero, chart as
/// context. Painted by hand like the heatmap, not with fl_chart: a spark has
/// no axes, tooltips, bands or legend, only the shape. What they draw is
/// computed in `../../charts/spark.dart`.
library;

import 'dart:math';
import 'dart:ui' show PointMode;

import 'package:material_ui/material_ui.dart';
import 'package:wger/features/measurements/charts/calendar.dart';
import 'package:wger/features/measurements/charts/colors.dart';
import 'package:wger/features/measurements/charts/data.dart';
import 'package:wger/features/measurements/charts/series.dart';
import 'package:wger/features/measurements/charts/spark.dart';
import 'package:wger/features/measurements/widgets/charts/chart_painting.dart';

/// Fraction of the value span kept clear above and below a spark, so the
/// extremes are not glued to the edges.
const _valuePadding = 0.12;

/// Radius of a spark dot.
const _dotRadius = 2.5;

/// A value series as a miniature line, or as bare dots for a sparse category,
/// where a line would claim a continuity a handful of readings does not have.
class SparkLineChart extends StatelessWidget {
  const SparkLineChart(
    this.entries, {
    required this.start,
    required this.days,
    this.dots = false,
    super.key,
  });

  final List<MeasurementChartEntry> entries;

  /// First day of the window; with [days] it fixes the x axis, so the spark
  /// keeps its time scale even when only part of the window was measured.
  final DateTime start;
  final int days;

  final bool dots;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _SparkLinePainter(
        entries: entries,
        start: start,
        days: days,
        dots: dots,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _SparkLinePainter extends CustomPainter {
  _SparkLinePainter({
    required this.entries,
    required this.start,
    required this.days,
    required this.dots,
    required this.color,
  });

  final List<MeasurementChartEntry> entries;
  final DateTime start;
  final int days;
  final bool dots;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty) {
      return;
    }

    final values = entries.map((e) => e.value);
    final low = values.reduce(min);
    final high = values.reduce(max);
    final span = high - low;

    double x(DateTime date) =>
        days <= 1 ? size.width / 2 : daysBetween(start, date) / (days - 1) * size.width;
    // A flat series sits mid-height rather than dividing by a zero span
    double y(num value) => span == 0
        ? size.height / 2
        : size.height * (_valuePadding + (1 - 2 * _valuePadding) * (high - value) / span);

    final points = [for (final e in entries) Offset(x(e.date), y(e.value))];
    final fill = Paint()..color = color;

    if (dots || points.length == 1) {
      for (final point in points) {
        canvas.drawCircle(point, _dotRadius, fill);
      }
      return;
    }

    canvas.drawPoints(
      PointMode.polygon,
      points,
      Paint()
        ..color = color
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );
    // The end dot marks where the series stands today, like the hero value
    canvas.drawCircle(points.last, _dotRadius, fill);
  }

  @override
  bool shouldRepaint(_SparkLinePainter oldDelegate) =>
      oldDelegate.entries != entries ||
      oldDelegate.start != start ||
      oldDelegate.dots != dots ||
      oldDelegate.color != color;
}

/// The bar family as a miniature: plain daily bars, floating bars (blood
/// pressure), stacked bars (sleep stages) and, with `signed`, the weekly
/// change bars around a zero hairline. Which one it is follows from the data,
/// see the `spark*Bars` builders.
class SparkBarChart extends StatelessWidget {
  const SparkBarChart(this.data, {super.key});

  final SparkBarsData data;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _SparkBarPainter(
        data: data,
        // componentColor's palette, so a stacked spark's segments match the
        // full chart of the tile it leads to
        palette: componentPalette(context),
        zeroLine: Theme.of(context).colorScheme.outline,
      ),
    );
  }
}

class _SparkBarPainter extends CustomPainter {
  _SparkBarPainter({required this.data, required this.palette, required this.zeroLine});

  final SparkBarsData data;
  final List<Color> palette;
  final Color zeroLine;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) {
      return;
    }

    final low = data.minValue;
    final high = data.maxValue;
    final span = high - low;

    double y(num value) => span == 0
        ? size.height / 2
        : size.height * (_valuePadding + (1 - 2 * _valuePadding) * (high - value) / span);

    final slotWidth = size.width / data.slotCount;
    final barWidth = (slotWidth * 0.6).clamp(2.0, 12.0);

    if (data.signed) {
      canvas.drawLine(
        Offset(0, y(0)),
        Offset(size.width, y(0)),
        Paint()
          ..color = zeroLine
          ..strokeWidth = 1,
      );
    }

    final paint = Paint()..style = PaintingStyle.fill;
    for (final bar in data.bars) {
      final left = bar.slot * slotWidth + (slotWidth - barWidth) / 2;
      for (final segment in bar.segments) {
        final top = y(max(segment.from, segment.to));
        // Never thinner than a hairline, or a small value disappears
        final bottom = max(y(min(segment.from, segment.to)), top + 1);
        paint.color = palette[segment.colorIndex % palette.length];
        canvas.drawRRect(
          RRect.fromLTRBR(left, top, left + barWidth, bottom, _radiusOf(bar, segment, barWidth)),
          paint,
        );
      }
    }
  }

  /// A lone segment is a small pill; the segments of a stack stay square so
  /// they meet without seams.
  Radius _radiusOf(SparkBar bar, SparkSegment segment, double barWidth) =>
      bar.segments.length == 1 ? Radius.circular(barWidth / 3) : Radius.zero;

  @override
  bool shouldRepaint(_SparkBarPainter oldDelegate) =>
      oldDelegate.data != data || oldDelegate.palette != palette;
}

/// A calendar strip laid out like the full heatmap (weeks as columns,
/// weekdays as rows), without the labels or the tap readout: the width
/// carries the time axis, the filter says which stretch it is.
class SparkHeatmap extends StatelessWidget {
  const SparkHeatmap(this.days, {required this.weeks, this.today, super.key});

  /// One entry per calendar day, see `aggregatePerDay` / `averagePerDay`.
  final List<MeasurementChartEntry> days;

  /// Week columns to lay out, see `sparkWindowFor`.
  final int weeks;

  /// Injectable for tests; the widgets leave it at the current day.
  final DateTime? today;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return CustomPaint(
      size: Size.infinite,
      painter: _SparkHeatmapPainter(
        grid: buildHeatmapGrid(days, maxWeeks: weeks, today: today),
        today: today ?? DateTime.now(),
        filled: scheme.primary,
        empty: scheme.surfaceContainerHighest,
      ),
    );
  }
}

class _SparkHeatmapPainter extends CustomPainter {
  _SparkHeatmapPainter({
    required this.grid,
    required this.today,
    required this.filled,
    required this.empty,
  });

  final MeasurementHeatmapGrid grid;
  final DateTime today;
  final Color filled;
  final Color empty;

  @override
  void paint(Canvas canvas, Size size) {
    // Square cells centered in the box, week columns and weekday rows
    final step = min(size.width / grid.weeks, size.height / DateTime.daysPerWeek);
    final cell = step - heatmapCellGap(step);
    final left = (size.width - step * grid.weeks) / 2;
    final top = (size.height - step * DateTime.daysPerWeek) / 2;
    final endOfToday = DateTime(today.year, today.month, today.day);

    final paint = Paint()..style = PaintingStyle.fill;
    for (var week = 0; week < grid.weeks; week++) {
      for (var weekday = 0; weekday < DateTime.daysPerWeek; weekday++) {
        // Days of the current week that have not happened yet stay blank
        if (grid.dayAt(week, weekday).isAfter(endOfToday)) {
          continue;
        }

        paint.color = heatmapCellColor(
          grid.valueAt(week, weekday),
          maxValue: grid.maxValue,
          filled: filled,
          empty: empty,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Offset(left + week * step, top + weekday * step) & Size(cell, cell),
            heatmapCellRadius(cell),
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_SparkHeatmapPainter oldDelegate) =>
      oldDelegate.grid != grid || oldDelegate.filled != filled;
}
