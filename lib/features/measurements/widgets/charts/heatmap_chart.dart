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
import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wger/core/formatting/formatting.dart';
import 'package:wger/features/measurements/widgets/charts/chart_series.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

/// A calendar heatmap laid out as a grid of week columns and weekday rows,
/// with the values it draws.
///
/// Days are addressed by their position in the grid, so nothing downstream has
/// to do calendar arithmetic: column 0 row 0 is [start], which is always a
/// Monday.
class MeasurementHeatmapGrid {
  /// Monday of the first (oldest) week column.
  final DateTime start;

  /// Number of week columns.
  final int weeks;

  /// Value of each day the grid shows that has one, keyed by the day at
  /// midnight. Days outside the window are not part of this chart and are left
  /// out, see [buildHeatmapGrid].
  final Map<DateTime, num> values;

  /// Largest value in [values], the top of the colour scale. Zero for an empty
  /// grid, and for a history that holds nothing but zeroes.
  final num maxValue;

  const MeasurementHeatmapGrid({
    required this.start,
    required this.weeks,
    required this.values,
    required this.maxValue,
  });

  /// The day in column [week], row [weekday] (0 = Monday).
  DateTime dayAt(int week, int weekday) =>
      DateTime(start.year, start.month, start.day + week * 7 + weekday);

  /// The value of that day, null when nothing was measured on it. That is the
  /// distinction the chart exists for, so it is kept apart from a zero.
  num? valueAt(int week, int weekday) => values[dayAt(week, weekday)];
}

/// Widest a heatmap gets, in week columns.
///
/// A year is where the grid stops being readable: 53 columns already put the
/// cells at a few pixels each, and a history of several years would be a wall
/// rather than a chart. The range selector above the chart can go further
/// (all-time), so the heatmap caps itself here; the month labels along the top
/// say which span is actually drawn.
const heatmapMaxWeeks = 53;

/// Lays [days] out as a calendar grid, newest week last.
///
/// Expects one entry per calendar day (see [aggregatePerDay] and
/// [averagePerDay]). The grid ends with the current week, so a stretch without
/// measurements at the end stays visible as empty cells; only a history that
/// ended longer ago than the grid is wide is anchored at its own last day
/// instead, since an empty grid shows nothing at all.
MeasurementHeatmapGrid buildHeatmapGrid(
  List<MeasurementChartEntry> days, {
  int maxWeeks = heatmapMaxWeeks,
  DateTime? today,
}) {
  // Calendar arithmetic, not Duration: a DST day is 23 or 25 hours long
  DateTime dayOf(DateTime date) => DateTime(date.year, date.month, date.day);
  DateTime shift(DateTime day, int days) => DateTime(day.year, day.month, day.day + days);
  DateTime mondayOf(DateTime date) => shift(date, -(date.weekday - 1));
  int daysBetween(DateTime from, DateTime to) => DateTime.utc(
    to.year,
    to.month,
    to.day,
  ).difference(DateTime.utc(from.year, from.month, from.day)).inDays;

  final values = {for (final day in days) dayOf(day.date): day.value};
  final now = dayOf(today ?? DateTime.now());

  if (values.isEmpty) {
    return MeasurementHeatmapGrid(
      start: shift(mondayOf(now), -7 * (maxWeeks - 1)),
      weeks: maxWeeks,
      values: const {},
      maxValue: 0,
    );
  }

  final first = values.keys.reduce((a, b) => a.isBefore(b) ? a : b);
  final last = values.keys.reduce((a, b) => a.isAfter(b) ? a : b);
  final oldestVisible = shift(mondayOf(now), -7 * (maxWeeks - 1));
  final end = mondayOf(last).isBefore(oldestVisible) ? last : now;

  final endMonday = mondayOf(end);
  final weeks = min(maxWeeks, daysBetween(mondayOf(first), endMonday) ~/ 7 + 1);
  final start = shift(endMonday, -7 * (weeks - 1));
  final lastDay = shift(start, 7 * weeks - 1);

  // Only the days the grid actually shows. A history longer than the grid is
  // wide keeps its older days out of the window, and a spike among them would
  // otherwise set the top of the colour scale without being visible itself,
  // washing out every cell that is
  final visible = {
    for (final MapEntry(key: day, value: value) in values.entries)
      if (!day.isBefore(start) && !day.isAfter(lastDay)) day: value,
  };

  return MeasurementHeatmapGrid(
    start: start,
    weeks: weeks,
    values: visible,
    maxValue: visible.isEmpty ? 0 : visible.values.max,
  );
}

/// Calendar heatmap: one cell per day, coloured by that day's value.
///
/// Where a line or a bar answers how much, this answers how regularly, which
/// for steps or sleep is often the more interesting question. It is also the
/// only chart of the set where a gap is visible: a day without a measurement
/// is an empty cell instead of a line segment that silently spans it.
///
/// Takes one entry per calendar day; how a day's readings became that value
/// (summed, averaged) is decided by the caller, see [aggregatePerDay] and
/// [averagePerDay].
class MeasurementHeatmapWidgetFl extends StatefulWidget {
  /// One entry per calendar day, see [aggregatePerDay] and [averagePerDay].
  final List<MeasurementChartEntry> days;
  final String unit;

  const MeasurementHeatmapWidgetFl(this.days, this.unit, {super.key});

  @override
  State<MeasurementHeatmapWidgetFl> createState() => _MeasurementHeatmapWidgetFlState();
}

class _MeasurementHeatmapWidgetFlState extends State<MeasurementHeatmapWidgetFl> {
  /// Day the user tapped, read out above the grid. A heatmap has no axis to
  /// read a value off, so this is what the tooltip is on the other charts.
  DateTime? _selected;

  @override
  Widget build(BuildContext context) {
    final grid = buildHeatmapGrid(widget.days);
    final theme = Theme.of(context);

    return Column(
      children: [
        SizedBox(
          height: 20,
          child: Text(
            _readout(grid),
            style: theme.textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final layout = _HeatmapLayout(constraints.biggest, grid.weeks);

              return GestureDetector(
                onTapDown: (details) {
                  final day = layout.dayAt(details.localPosition, grid);
                  setState(() => _selected = day == _selected ? null : day);
                },
                child: CustomPaint(
                  size: constraints.biggest,
                  painter: _HeatmapPainter(
                    grid: grid,
                    layout: layout,
                    selected: _selected,
                    filled: theme.colorScheme.primary,
                    empty: theme.colorScheme.surfaceContainerHighest,
                    outline: theme.colorScheme.outline,
                    labelStyle:
                        theme.textTheme.bodySmall?.copyWith(fontSize: 9) ??
                        const TextStyle(fontSize: 9),
                    locale: Localizations.localeOf(context).toString(),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// The line above the grid: the tapped day, or the span the grid covers
  /// while nothing is selected.
  String _readout(MeasurementHeatmapGrid grid) {
    final dateFormat = localizedDate(context);
    final selected = _selected;
    if (selected == null) {
      // The grid is whole weeks and its last one usually runs past today, so
      // the span it covers ends today rather than on that Sunday
      final today = DateTime.now();
      final last = grid.dayAt(grid.weeks - 1, DateTime.daysPerWeek - 1);
      final end = last.isAfter(today) ? today : last;
      return '${dateFormat.format(grid.start)} - ${dateFormat.format(end)}';
    }

    final value = grid.values[selected];
    if (value == null) {
      return '${dateFormat.format(selected)}: ${AppLocalizations.of(context).noDataAvailable}';
    }

    return '${dateFormat.format(selected)}: '
        '${measurementWithUnit(context, value, widget.unit)}';
  }
}

/// Where the cells of a heatmap sit, shared by the painter and the hit test so
/// a tap lands on the cell it looks like it lands on.
class _HeatmapLayout {
  /// Room for the weekday labels on the left and the month labels on top.
  static const weekdayLabelWidth = 22.0;
  static const monthLabelHeight = 12.0;

  /// Smallest a cell and its gap may get before the grid is unreadable rather
  /// than merely dense.
  static const minCell = 4.0;

  final double step;
  final double cell;
  final double left;
  final double top;

  factory _HeatmapLayout(Size size, int weeks) {
    final available = Size(
      size.width - weekdayLabelWidth,
      size.height - monthLabelHeight,
    );
    // Square cells, so the grid keeps the calendar's proportions whatever box
    // it is given. A year of columns is limited by the width, a quarter by the
    // height
    final step = max(
      minCell,
      min(available.width / max(weeks, 1), available.height / DateTime.daysPerWeek),
    );
    // The gap follows the cell size: a fixed one is a hairline on a wide grid
    // and half the cell on a year of columns, where it turns the squares into
    // scattered dots
    final gap = (step * 0.18).clamp(1.0, 3.0);

    return _HeatmapLayout._(
      step: step,
      cell: step - gap,
      left: weekdayLabelWidth,
      // A year of columns is wider than it is tall, so it would otherwise sit
      // against the top edge with the rest of the box empty below it
      top: monthLabelHeight + max(0.0, available.height - step * DateTime.daysPerWeek) / 2,
    );
  }

  const _HeatmapLayout._({
    required this.step,
    required this.cell,
    required this.left,
    required this.top,
  });

  Offset originOf(int week, int weekday) => Offset(left + week * step, top + weekday * step);

  /// The day at [position], null when the tap missed the grid.
  DateTime? dayAt(Offset position, MeasurementHeatmapGrid grid) {
    final week = ((position.dx - left) / step).floor();
    final weekday = ((position.dy - top) / step).floor();
    if (week < 0 || week >= grid.weeks || weekday < 0 || weekday >= DateTime.daysPerWeek) {
      return null;
    }
    return grid.dayAt(week, weekday);
  }
}

class _HeatmapPainter extends CustomPainter {
  final MeasurementHeatmapGrid grid;
  final _HeatmapLayout layout;
  final DateTime? selected;
  final Color filled;
  final Color empty;
  final Color outline;
  final TextStyle labelStyle;
  final String locale;

  _HeatmapPainter({
    required this.grid,
    required this.layout,
    required this.selected,
    required this.filled,
    required this.empty,
    required this.outline,
    required this.labelStyle,
    required this.locale,
  });

  /// Colour of a cell holding [value].
  ///
  /// A day without a measurement is neutral, everything else is tinted by how
  /// large its value is within the grid. The scale is continuous and starts
  /// well above transparent: a day that was measured has to read as measured
  /// even when its value is the smallest one.
  Color _cellColor(num? value) {
    if (value == null) {
      return empty;
    }
    final share = grid.maxValue <= 0 ? 1.0 : (value / grid.maxValue).clamp(0.0, 1.0);
    return Color.lerp(filled.withValues(alpha: 0.3), filled, share)!;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final today = DateTime.now();
    final endOfToday = DateTime(today.year, today.month, today.day);

    for (var week = 0; week < grid.weeks; week++) {
      for (var weekday = 0; weekday < DateTime.daysPerWeek; weekday++) {
        final day = grid.dayAt(week, weekday);
        // The grid is whole weeks, so the last one runs past today. Those days
        // have not happened yet and are left blank rather than drawn as a gap
        if (day.isAfter(endOfToday)) {
          continue;
        }

        final rect = RRect.fromRectAndRadius(
          layout.originOf(week, weekday) & Size(layout.cell, layout.cell),
          // Rounded, but never so much that a small cell becomes a dot
          Radius.circular(min(2, layout.cell / 4)),
        );
        canvas.drawRRect(rect, paint..color = _cellColor(grid.valueAt(week, weekday)));

        if (day == selected) {
          canvas.drawRRect(
            rect,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5
              ..color = outline,
          );
        }
      }
    }

    _paintWeekdayLabels(canvas);
    _paintMonthLabels(canvas);
  }

  /// Every other weekday, the way a calendar heatmap is usually labelled:
  /// naming all seven needs more room than the rows have.
  void _paintWeekdayLabels(Canvas canvas) {
    final format = DateFormat.E(locale);
    for (var weekday = 0; weekday < DateTime.daysPerWeek; weekday += 2) {
      final origin = layout.originOf(0, weekday);
      _paintText(
        canvas,
        format.format(grid.dayAt(0, weekday)),
        Offset(0, origin.dy + layout.cell / 2),
        maxWidth: _HeatmapLayout.weekdayLabelWidth - 2,
        centered: true,
      );
    }
  }

  /// The month above the column it starts in, which is what says where in the
  /// year the grid is without a date axis.
  void _paintMonthLabels(Canvas canvas) {
    final format = DateFormat.MMM(locale);
    var previous = -1;
    for (var week = 0; week < grid.weeks; week++) {
      final month = grid.dayAt(week, 0).month;
      if (month == previous) {
        continue;
      }
      previous = month;
      _paintText(
        canvas,
        format.format(grid.dayAt(week, 0)),
        // Sits right above the first column of the month
        Offset(
          layout.originOf(week, 0).dx,
          layout.top - _HeatmapLayout.monthLabelHeight,
        ),
        maxWidth: layout.step * 4,
      );
    }
  }

  /// Draws [text] at [at], which is its top left corner or, with [centered],
  /// the middle of its left edge.
  void _paintText(
    Canvas canvas,
    String text,
    Offset at, {
    required double maxWidth,
    bool centered = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: labelStyle),
      textDirection: ui.TextDirection.ltr,
      maxLines: 1,
      ellipsis: '',
    )..layout(maxWidth: maxWidth);
    painter.paint(canvas, centered ? at.translate(0, -painter.height / 2) : at);
  }

  @override
  bool shouldRepaint(_HeatmapPainter oldDelegate) =>
      oldDelegate.selected != selected || oldDelegate.grid != grid;
}
