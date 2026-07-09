/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
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
import 'package:wger/core/charts.dart';
import 'package:wger/core/consts.dart';
import 'package:wger/core/formatting/formatting.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

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

    return Text(
      '${AppLocalizations.of(context).overallChangeWeight} '
      '$prefix${delta.abs().toStringAsFixed(1)} $_unit',
    );
  }
}

String weightUnit(bool isMetric, BuildContext context) {
  return isMetric ? AppLocalizations.of(context).kg : AppLocalizations.of(context).lb;
}

class MeasurementChartWidgetFl extends StatefulWidget {
  final List<MeasurementChartEntry> _entries;
  final List<MeasurementChartEntry>? avgs;
  final List<MeasurementChartEntry>? trend;
  final String _unit;

  const MeasurementChartWidgetFl(this._entries, this._unit, {this.avgs, this.trend});

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
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (touchedSpot) => Theme.of(context).colorScheme.primaryContainer,
        getTooltipItems: (touchedSpots) {
          final numberFormat = localizedNumberFormat(context);

          return touchedSpots.map((touchedSpot) {
            final msSinceEpoch = touchedSpot.x.toInt();
            final DateTime date = DateTime.fromMillisecondsSinceEpoch(touchedSpot.x.toInt());
            final dateStr = DateFormat.Md(
              Localizations.localeOf(context).languageCode,
            ).format(date);

            // Check if this is an interpolated point (milliseconds ending with 123)
            final bool isInterpolated = msSinceEpoch % 1000 == INTERPOLATION_MARKER;
            final String interpolatedMarker = isInterpolated ? ' (interpolated)' : '';

            return LineTooltipItem(
              '$dateStr: ${numberFormat.format(touchedSpot.y)} ${widget._unit}$interpolatedMarker',
              TextStyle(color: touchedSpot.bar.color),
            );
          }).toList();
        },
      ),
    );
  }

  LineChartData mainData() {
    final numberFormat = localizedNumberFormat(context);

    return LineChartData(
      lineTouchData: tooltipData(),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        // horizontalInterval: 1,
        // verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(color: Theme.of(context).colorScheme.primaryContainer, strokeWidth: 1);
        },
        getDrawingVerticalLine: (value) {
          return FlLine(color: Theme.of(context).colorScheme.primaryContainer, strokeWidth: 1);
        },
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
            getTitlesWidget: (value, meta) {
              // Don't show the first and last entries, to avoid overlap
              // see https://stackoverflow.com/questions/73355777/flutter-fl-chart-how-can-we-avoid-the-overlap-of-the-ordinate
              // this is needlessly aggressive if the titles are "sparse", but we should optimize for more busy data
              if (value == meta.min || value == meta.max) {
                return const Text('');
              }
              final DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
              // if we go across years, show years in the ticks. otherwise leave them out
              if (DateTime.fromMillisecondsSinceEpoch(meta.min.toInt()).year !=
                  DateTime.fromMillisecondsSinceEpoch(meta.max.toInt()).year) {
                return Text(
                  localizedDate(context).format(date),
                );
              }
              return Text(
                DateFormat.Md(Localizations.localeOf(context).languageCode).format(date),
              );
            },
            interval: widget._entries.isNotEmpty
                ? chartGetInterval(
                    widget._entries.last.date,
                    widget._entries.first.date,
                  )
                : CHART_MILLISECOND_FACTOR,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 65,
            getTitlesWidget: (value, meta) {
              // Don't show the first and last entries, to avoid overlap
              // see https://stackoverflow.com/questions/73355777/flutter-fl-chart-how-can-we-avoid-the-overlap-of-the-ordinate
              // this is needlessly aggressive if the titles are "sparse", but we should optimize for more busy data
              if (value == meta.min || value == meta.max) {
                return const Text('');
              }

              return Text('${numberFormat.format(value)} ${widget._unit}');
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
      ),
      lineBarsData: [
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
          color: Theme.of(context).colorScheme.primary,
          barWidth: 0,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: true),
        ),
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
            color: Theme.of(context).colorScheme.tertiary,
            barWidth: 1,
            dotData: const FlDotData(show: false),
          ),
        if (widget.trend != null && widget.trend!.isNotEmpty)
          LineChartBarData(
            spots: widget.trend!
                .map((e) => FlSpot(e.date.millisecondsSinceEpoch.toDouble(), e.value.toDouble()))
                .toList(),
            isCurved: true,
            curveSmoothness: 0.4,
            color: Theme.of(context).colorScheme.secondary,
            barWidth: 3,
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

// for each point, return the average of all the points in the 7 days preceding it
List<MeasurementChartEntry> moving7dAverage(List<MeasurementChartEntry> vals) {
  var start = 0;
  var end = 0;
  final List<MeasurementChartEntry> out = <MeasurementChartEntry>[];

  // first make sure our list is in ascending order
  vals.sort((a, b) => a.date.compareTo(b.date));

  while (end < vals.length) {
    // since users can log measurements several days, or minutes apart,
    // we can't make assumptions.  We have to manually advance 'start'
    // such that it is always the first point within our desired range.
    // posibly start == end (when there is only one point in the range)
    final intervalStart = vals[end].date.subtract(const Duration(days: 7));
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

/// Sums entries per calendar day. Used for metric types where individual
/// samples aren't meaningful on their own (steps, distance, energy, sleep) —
/// see MeasurementMetricType.isSummedPerDay.
List<MeasurementChartEntry> aggregatePerDay(List<MeasurementChartEntry> vals) {
  if (vals.isEmpty) {
    return [];
  }

  // Bucket by the day component only (strip time-of-day).
  final Map<DateTime, num> sums = {};
  for (final e in vals) {
    final day = DateTime(e.date.year, e.date.month, e.date.day);
    sums.update(day, (existing) => existing + e.value, ifAbsent: () => e.value);
  }

  final out = sums.entries.map((e) => MeasurementChartEntry(e.value, e.key)).toList()
    ..sort((a, b) => a.date.compareTo(b.date));
  return out;
}

class MeasurementBarChartWidgetFl extends StatefulWidget {
  final List<MeasurementChartEntry> _entries;
  final String _unit;

  const MeasurementBarChartWidgetFl(this._entries, this._unit);

  @override
  State<MeasurementBarChartWidgetFl> createState() => _MeasurementBarChartWidgetFlState();
}

class _MeasurementBarChartWidgetFlState extends State<MeasurementBarChartWidgetFl> {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.70,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: BarChart(mainData()),
      ),
    );
  }

  BarTouchData tooltipData() {
    return BarTouchData(
      touchTooltipData: BarTouchTooltipData(
        getTooltipColor: (group) => Theme.of(context).colorScheme.primaryContainer,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          final numberFormat = NumberFormat.decimalPattern(
            Localizations.localeOf(context).toString(),
          );
          final DateTime date = DateTime.fromMillisecondsSinceEpoch(group.x);
          final dateStr = DateFormat.Md(Localizations.localeOf(context).languageCode).format(date);

          return BarTooltipItem(
            '$dateStr: ${numberFormat.format(rod.toY)} ${widget._unit}',
            TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
          );
        },
      ),
    );
  }

  BarChartData mainData() {
    final String locale = Localizations.localeOf(context).toString();
    final NumberFormat numberFormat = NumberFormat.decimalPattern(locale);
    return BarChartData(
      barTouchData: tooltipData(),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) {
          return FlLine(color: Theme.of(context).colorScheme.primaryContainer, strokeWidth: 1);
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              // avoid label overlap with the axis edges
              if (value == meta.min || value == meta.max) {
                return const Text('');
              }
              final DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
              return Text(DateFormat.Md(Localizations.localeOf(context).languageCode).format(date));
            },
            interval: widget._entries.isNotEmpty
                ? chartGetInterval(widget._entries.last.date, widget._entries.first.date)
                : CHART_MILLISECOND_FACTOR,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 65,
            getTitlesWidget: (value, meta) {
              if (value == meta.min || value == meta.max) {
                return const Text('');
              }
              return Text('${numberFormat.format(value)} ${widget._unit}');
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
      ),
      barGroups: widget._entries
          .map(
            (e) => BarChartGroupData(
              x: e.date.millisecondsSinceEpoch,
              barRods: [
                BarChartRodData(
                  toY: e.value.toDouble(),
                  color: Theme.of(context).colorScheme.primary,
                  width: 12,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}

/// Produces a smoothed trendline via a Exponential Moving Average (EMA).
/// Produces a smoothed trendline via a Centered Moving Average (CMA).
List<MeasurementChartEntry> smoothedTrendline(
  List<MeasurementChartEntry> vals, {
  // int windowDays = 14,
  int period = 10,
}) {
  if (vals.isEmpty) {
    return [];
  }

  final sorted = [...vals]..sort((a, b) => a.date.compareTo(b.date));
  final List<MeasurementChartEntry> out = [];

  // Seed the initialization layer with the first data point value
  double currentEma = sorted[0].value.toDouble();
  final double smoothing = 2 / (period + 1);

  for (int i = 0; i < sorted.length; i++) {
    final point = sorted[i];

    if (i > 0) {
      // EMA equation: point.weight * smoothing + ema * (1 - smoothing)
      currentEma = (point.value * smoothing) + (currentEma * (1 - smoothing));
    }

    out.add(MeasurementChartEntry(currentEma, point.date));
  }

  return out;
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
