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

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/theme/theme.dart';

/// Time range options for chart display
enum ChartTimeRange { week, month, sixMonths, year, all }

class MeasurementOverallChangeWidget extends StatelessWidget {
  final MeasurementChartEntry _first;
  final MeasurementChartEntry _last;
  final String _unit;

  const MeasurementOverallChangeWidget(this._first, this._last, this._unit);

  @override
  Widget build(BuildContext context) {
    final delta = _last.value - _first.value;
    String prefix = '';
    if (delta > 0) {
      prefix = '+';
    } else if (delta < 0) {
      prefix = '-';
    }

    // ignore: prefer_interpolation_to_compose_strings
    return Text(
      '${AppLocalizations.of(context).overallChangeWeight} $prefix${delta.abs().toStringAsFixed(1)} $_unit',
    );
  }
}

String weightUnit(bool isMetric, BuildContext context) {
  return isMetric ? AppLocalizations.of(context).kg : AppLocalizations.of(context).lb;
}

class MeasurementChartWidgetFl extends StatefulWidget {
  final List<MeasurementChartEntry> _entries;
  final List<MeasurementChartEntry>? avgs;
  final String _unit;
  final ChartTimeRange? timeRange;

  const MeasurementChartWidgetFl(this._entries, this._unit, {this.avgs, this.timeRange});

  @override
  State<MeasurementChartWidgetFl> createState() => _MeasurementChartWidgetFlState();
}

class _MeasurementChartWidgetFlState extends State<MeasurementChartWidgetFl> {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.70,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: LineChart(mainData()),
      ),
    );
  }

  LineTouchData tooltipData() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        tooltipBorderRadius: BorderRadius.circular(12),
        tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        getTooltipColor: (touchedSpot) => isDarkMode ? Colors.grey.shade800 : Colors.white,
        tooltipBorder: BorderSide(
          color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
          width: 1,
        ),
        getTooltipItems: (touchedSpots) {
          final numberFormat = NumberFormat.decimalPattern(
            Localizations.localeOf(context).toString(),
          );

          return touchedSpots.map((touchedSpot) {
            final msSinceEpoch = touchedSpot.x.toInt();
            final DateTime date = DateTime.fromMillisecondsSinceEpoch(touchedSpot.x.toInt());
            final dateStr = DateFormat.yMd(
              Localizations.localeOf(context).languageCode,
            ).format(date);

            // Check if this is an interpolated point (milliseconds ending with 123)
            final bool isInterpolated = msSinceEpoch % 1000 == INTERPOLATION_MARKER;
            final String interpolatedMarker = isInterpolated ? ' (est.)' : '';

            // Use the bar's color for the tooltip text
            // barIndex 0 = main data line (wgerAccentColor)
            // barIndex 1 = average trend line (orange)
            final isAverageLine = touchedSpot.barIndex == 1;
            final lineColor = isAverageLine ? const Color(0xFFFF8C00) : wgerAccentColor;

            return LineTooltipItem(
              '${numberFormat.format(touchedSpot.y)} ${widget._unit}$interpolatedMarker\n',
              TextStyle(
                color: lineColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              children: [
                TextSpan(
                  text: dateStr,
                  style: TextStyle(
                    color: context.wgerLightGrey,
                    fontWeight: FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ],
            );
          }).toList();
        },
      ),
      handleBuiltInTouches: true,
      getTouchedSpotIndicator: (barData, spotIndexes) {
        return spotIndexes.map((spotIndex) {
          return TouchedSpotIndicatorData(
            const FlLine(color: Colors.transparent),
            FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 6,
                  color: wgerAccentColor,
                  strokeWidth: 3,
                  strokeColor: Theme.of(context).brightness == Brightness.light
                      ? Colors.white
                      : Theme.of(context).cardColor,
                );
              },
            ),
          );
        }).toList();
      },
    );
  }

  /// Get the fixed min/max x-axis bounds based on the time range
  (double, double) _getFixedXAxisBounds() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (widget.timeRange) {
      case ChartTimeRange.week:
        final startOfWeek = today.subtract(const Duration(days: 6));
        return (
          startOfWeek.millisecondsSinceEpoch.toDouble(),
          today.add(const Duration(hours: 23, minutes: 59)).millisecondsSinceEpoch.toDouble(),
        );
      case ChartTimeRange.month:
        final startDate = today.subtract(const Duration(days: 30));
        return (
          startDate.millisecondsSinceEpoch.toDouble(),
          today.add(const Duration(hours: 23, minutes: 59)).millisecondsSinceEpoch.toDouble(),
        );
      case ChartTimeRange.sixMonths:
        final startDate = DateTime(now.year, now.month - 5, 1);
        final endDate = DateTime(now.year, now.month + 1, 0);
        return (
          startDate.millisecondsSinceEpoch.toDouble(),
          endDate.millisecondsSinceEpoch.toDouble(),
        );
      case ChartTimeRange.year:
        final startDate = DateTime(now.year, now.month - 11, 1);
        final endDate = DateTime(now.year, now.month + 1, 0);
        return (
          startDate.millisecondsSinceEpoch.toDouble(),
          endDate.millisecondsSinceEpoch.toDouble(),
        );
      case ChartTimeRange.all:
      case null:
        // Fall back to data-based bounds
        if (widget._entries.isEmpty) {
          return (
            today.subtract(const Duration(days: 7)).millisecondsSinceEpoch.toDouble(),
            today.millisecondsSinceEpoch.toDouble(),
          );
        }
        return (
          widget._entries
              .map((e) => e.date.millisecondsSinceEpoch)
              .reduce((a, b) => a < b ? a : b)
              .toDouble(),
          widget._entries
              .map((e) => e.date.millisecondsSinceEpoch)
              .reduce((a, b) => a > b ? a : b)
              .toDouble(),
        );
    }
  }

  /// Get the vertical line positions for the grid based on time range
  List<double> _getVerticalLinePositions() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final positions = <double>[];

    switch (widget.timeRange) {
      case ChartTimeRange.week:
        // One line per day for the last 7 days
        for (int i = 6; i >= 0; i--) {
          final day = today.subtract(Duration(days: i));
          positions.add(day.millisecondsSinceEpoch.toDouble());
        }
        break;
      case ChartTimeRange.month:
        // Lines for each Monday in the last 30 days
        for (int i = 30; i >= 0; i--) {
          final day = today.subtract(Duration(days: i));
          if (day.weekday == DateTime.monday) {
            positions.add(day.millisecondsSinceEpoch.toDouble());
          }
        }
        break;
      case ChartTimeRange.sixMonths:
        // One line per month for the last 6 months
        for (int i = 5; i >= 0; i--) {
          final monthStart = DateTime(now.year, now.month - i, 1);
          positions.add(monthStart.millisecondsSinceEpoch.toDouble());
        }
        break;
      case ChartTimeRange.year:
        // One line per month for the last 12 months
        for (int i = 11; i >= 0; i--) {
          final monthStart = DateTime(now.year, now.month - i, 1);
          positions.add(monthStart.millisecondsSinceEpoch.toDouble());
        }
        break;
      case ChartTimeRange.all:
      case null:
        // No fixed positions, use default grid behavior
        break;
    }

    return positions;
  }

  /// Get the x-axis interval for labels
  double _getXAxisInterval() {
    switch (widget.timeRange) {
      case ChartTimeRange.week:
        return const Duration(days: 1).inMilliseconds.toDouble();
      case ChartTimeRange.month:
        return const Duration(days: 7).inMilliseconds.toDouble();
      case ChartTimeRange.sixMonths:
      case ChartTimeRange.year:
        // Approximate month interval
        return const Duration(days: 30).inMilliseconds.toDouble();
      case ChartTimeRange.all:
      case null:
        if (widget._entries.isEmpty) {
          return CHART_MILLISECOND_FACTOR;
        }
        final first = widget._entries.map((e) => e.date).reduce((a, b) => a.isBefore(b) ? a : b);
        final last = widget._entries.map((e) => e.date).reduce((a, b) => a.isAfter(b) ? a : b);
        final diff = last.difference(first).inMilliseconds;
        return diff == 0 ? CHART_MILLISECOND_FACTOR : diff / 3;
    }
  }

  /// Get the vertical grid interval - use small interval so checkToShowVerticalLine can filter
  double _getVerticalInterval() {
    switch (widget.timeRange) {
      case ChartTimeRange.week:
        return const Duration(days: 1).inMilliseconds.toDouble();
      case ChartTimeRange.month:
        // Check each day so we can filter to show only Mondays
        return const Duration(days: 1).inMilliseconds.toDouble();
      case ChartTimeRange.sixMonths:
      case ChartTimeRange.year:
        // Check each day so we can filter to show only month starts
        return const Duration(days: 1).inMilliseconds.toDouble();
      case ChartTimeRange.all:
      case null:
        return const Duration(days: 7).inMilliseconds.toDouble();
    }
  }

  /// Get the label for a given x value based on time range
  String _getXAxisLabel(double value) {
    final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
    final locale = Localizations.localeOf(context).languageCode;

    switch (widget.timeRange) {
      case ChartTimeRange.week:
        // Weekday name (Mon, Tue, etc.)
        return DateFormat.E(locale).format(date);
      case ChartTimeRange.month:
        // Date (e.g., "12/5" or "5.12")
        return DateFormat.Md(locale).format(date);
      case ChartTimeRange.sixMonths:
        // Month name (Jan, Feb, etc.)
        return DateFormat.MMM(locale).format(date);
      case ChartTimeRange.year:
        // Month number (01, 02, ..., 12)
        return date.month.toString().padLeft(2, '0');
      case ChartTimeRange.all:
      case null:
        // Default behavior
        return DateFormat.Md(locale).format(date);
    }
  }

  LineChartData mainData() {
    final numberFormat = NumberFormat.decimalPattern(Localizations.localeOf(context).toString());
    final gridColor = Theme.of(context).brightness == Brightness.light
        ? wgerChartGridColor
        : wgerChartGridColorDark;

    final (minX, maxX) = _getFixedXAxisBounds();
    final verticalLinePositions = _getVerticalLinePositions();

    return LineChartData(
      minX: minX,
      maxX: maxX,
      lineTouchData: tooltipData(),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(color: gridColor, strokeWidth: 1);
        },
        getDrawingVerticalLine: (value) {
          return FlLine(color: gridColor, strokeWidth: 1, dashArray: [5, 5]);
        },
        checkToShowVerticalLine: (value) {
          // When using fixed time range, only show lines at specific positions
          if (widget.timeRange != null && verticalLinePositions.isNotEmpty) {
            return verticalLinePositions.any(
              (pos) => (value - pos).abs() < const Duration(hours: 12).inMilliseconds,
            );
          }
          return true;
        },
        verticalInterval: widget.timeRange != null ? _getVerticalInterval() : null,
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              // Don't show labels at the exact min/max to avoid overlap
              if (value == meta.min || value == meta.max) {
                return const SizedBox.shrink();
              }

              if (widget.timeRange != null) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _getXAxisLabel(value),
                    style: const TextStyle(fontSize: 11),
                  ),
                );
              }

              // Default behavior for no time range
              final DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
              if (DateTime.fromMillisecondsSinceEpoch(meta.min.toInt()).year !=
                  DateTime.fromMillisecondsSinceEpoch(meta.max.toInt()).year) {
                return Text(
                  DateFormat.yMd(Localizations.localeOf(context).languageCode).format(date),
                );
              }
              return Text(
                DateFormat.Md(Localizations.localeOf(context).languageCode).format(date),
              );
            },
            interval: _getXAxisInterval(),
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 45,
            getTitlesWidget: (value, meta) {
              // Don't show the first and last entries, to avoid overlap
              if (value == meta.min || value == meta.max) {
                return const Text('');
              }

              return Text(
                '${numberFormat.format(value)} ${widget._unit}',
                style: const TextStyle(fontSize: 11),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: gridColor),
      ),
      lineBarsData: [
        // Main data line (drawn first so gradient is behind the trend line)
        LineChartBarData(
          spots: widget._entries
              .map(
                (e) => FlSpot(
                  e.date.millisecondsSinceEpoch.toDouble(),
                  e.value.toDouble(),
                ),
              )
              .toList(),
          isCurved: false,
          color: wgerAccentColor,
          barWidth: 3,
          isStrokeCapRound: true,
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                wgerAccentColor.withValues(alpha: 0.3),
                wgerAccentColor.withValues(alpha: 0.0),
              ],
            ),
          ),
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.white
                    : Theme.of(context).cardColor,
                strokeWidth: 2.5,
                strokeColor: wgerAccentColor,
              );
            },
          ),
        ),
        // Average trend line (drawn on top)
        if (widget.avgs != null)
          LineChartBarData(
            spots: widget.avgs!
                .map(
                  (e) => FlSpot(
                    e.date.millisecondsSinceEpoch.toDouble(),
                    e.value.toDouble(),
                  ),
                )
                .toList(),
            isCurved: false,
            color: const Color(0xFFFF8C00),
            barWidth: 2,
            isStrokeCapRound: true,
            dashArray: [6, 4],
            dotData: const FlDotData(show: false),
          ),
      ],
    );
  }
}

class MeasurementChartEntry {
  num value;
  DateTime date;

  MeasurementChartEntry(this.value, this.date);
}

/// Returns the moving average window in days for each time range
int? getAverageDaysForTimeRange(ChartTimeRange? timeRange) {
  switch (timeRange) {
    case ChartTimeRange.week:
      return null; // No average for week view
    case ChartTimeRange.month:
      return 7;
    case ChartTimeRange.sixMonths:
      return 14;
    case ChartTimeRange.year:
      return 30;
    case ChartTimeRange.all:
      return 7; // Use 7-day average for all-time view
    case null:
      return 7; // Default to 7-day average
  }
}

/// For each point, return the average of all points in the preceding [days] window.
/// Returns null if [days] is null (no averaging).
List<MeasurementChartEntry>? movingAverage(List<MeasurementChartEntry> vals, int? days) {
  if (days == null) {
    return null;
  }

  var start = 0;
  var end = 0;
  final List<MeasurementChartEntry> out = <MeasurementChartEntry>[];

  // first make sure our list is in ascending order
  vals.sort((a, b) => a.date.compareTo(b.date));

  while (end < vals.length) {
    // since users can log measurements several days, or minutes apart,
    // we can't make assumptions.  We have to manually advance 'start'
    // such that it is always the first point within our desired range.
    // possibly start == end (when there is only one point in the range)
    final intervalStart = vals[end].date.subtract(Duration(days: days));
    while (start < end && vals[start].date.isBefore(intervalStart)) {
      start++;
    }

    final sub = vals.sublist(start, end + 1).map((e) => e.value);
    final sum = sub.reduce((val, el) => val + el);
    out.add(MeasurementChartEntry(sum / sub.length, vals[end].date));

    end++;
  }
  return out;
}

// Keep for backwards compatibility
List<MeasurementChartEntry> moving7dAverage(List<MeasurementChartEntry> vals) {
  return movingAverage(vals, 7) ?? [];
}

class Indicator extends StatelessWidget {
  const Indicator({
    super.key,
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 16,
    this.marginRight = 15,
    this.textColor,
  });

  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final double marginRight;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: textColor)),
        SizedBox(width: marginRight),
      ],
    );
  }
}
