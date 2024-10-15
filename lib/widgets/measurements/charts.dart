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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:wger/helpers/charts.dart';

class MeasurementOverallChangeWidget extends StatelessWidget {
  final MeasurementChartEntry _first;
  final MeasurementChartEntry _last;
  final String _unit;
  const MeasurementOverallChangeWidget(this._first, this._last, this._unit);

  @override
  Widget build(BuildContext context) {
    final delta = _last.value - _first.value;
    final prefix = delta > 0
        ? '+'
        : delta < 0
            ? '-'
            : '';

    return Text('overall change $prefix ${delta.abs().toStringAsFixed(1)} $_unit');
  }
}

String weightUnit(bool isMetric, BuildContext context) {
  return isMetric ? AppLocalizations.of(context).kg : AppLocalizations.of(context).lb;
}

class MeasurementChartWidgetFl extends StatefulWidget {
  final List<MeasurementChartEntry> _entries;
  final List<MeasurementChartEntry>? avgs;
  final String _unit;

  const MeasurementChartWidgetFl(this._entries, this._unit, {this.avgs});

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
          return touchedSpots.map((touchedSpot) {
            final DateTime date = DateTime.fromMillisecondsSinceEpoch(touchedSpot.x.toInt());
            final dateStr =
                DateFormat.Md(Localizations.localeOf(context).languageCode).format(date);

            return LineTooltipItem(
              '$dateStr: ${touchedSpot.y.toStringAsFixed(1)} ${widget._unit}',
              TextStyle(
                color: touchedSpot.bar.color,
                fontWeight: FontWeight.bold,
              ),
            );
          }).toList();
        },
      ),
    );
  }

  LineChartData mainData() {
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
                  DateFormat.yMd(Localizations.localeOf(context).languageCode).format(date),
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
                : 1000,
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

              return Text('$value ${widget._unit}');
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
              .map((e) => FlSpot(
                    e.date.millisecondsSinceEpoch.toDouble(),
                    e.value.toDouble(),
                  ))
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
                .map((e) => FlSpot(
                      e.date.millisecondsSinceEpoch.toDouble(),
                      e.value.toDouble(),
                    ))
                .toList(),
            isCurved: false,
            color: Theme.of(context).colorScheme.tertiary,
            barWidth: 1,
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

// for each point, return the average of all the points in the 7 days preceeding it
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
