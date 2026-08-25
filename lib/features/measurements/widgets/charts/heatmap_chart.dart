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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wger/core/formatting/formatting.dart';
import 'package:wger/features/measurements/charts/data.dart';
import 'package:wger/features/measurements/charts/series.dart';
import 'package:wger/features/measurements/widgets/charts/chart_painting.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

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
    final gap = heatmapCellGap(step);

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

  Color _cellColor(num? value) =>
      heatmapCellColor(value, maxValue: grid.maxValue, filled: filled, empty: empty);

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
          heatmapCellRadius(layout.cell),
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
    final painter = singleLineLabel(text, labelStyle, maxWidth: maxWidth);
    painter.paint(canvas, centered ? at.translate(0, -painter.height / 2) : at);
  }

  @override
  bool shouldRepaint(_HeatmapPainter oldDelegate) =>
      oldDelegate.selected != selected || oldDelegate.grid != grid;
}
