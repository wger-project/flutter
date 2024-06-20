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
import 'package:wger/helpers/charts.dart';

class MeasurementChartWidgetFl extends StatefulWidget {
  final List<MeasurementChartEntry> _entries;
  final String unit;

  const MeasurementChartWidgetFl(this._entries, {this.unit = 'kg'});

  @override
  State<MeasurementChartWidgetFl> createState() => _MeasurementChartWidgetFlState();
}

class _MeasurementChartWidgetFlState extends State<MeasurementChartWidgetFl> {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.70,
      child: Padding(
        padding: const EdgeInsets.only(
          right: 18,
          left: 12,
          top: 24,
          bottom: 12,
        ),
        child: LineChart(mainData()),
      ),
    );
  }

  LineTouchData tooltipData() {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(getTooltipItems: (touchedSpots) {
        return touchedSpots.map((touchedSpot) {
          return LineTooltipItem(
            '${touchedSpot.y} kg',
            const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          );
        }).toList();
      }),
    );
  }

  LineChartData mainData() {
    return LineChartData(
      lineTouchData: tooltipData(),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        //horizontalInterval: 1,
        //verticalInterval: interval,
        getDrawingHorizontalLine: (value) {
          return const FlLine(color: Colors.grey, strokeWidth: 1);
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(color: Colors.grey, strokeWidth: 1);
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
              // Don't show the first and last entries, otherwise they'll overlap with the
              // calculated interval
              if (value == meta.min || value == meta.max) {
                return const Text('');
              }
              final DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
              return Text(
                DateFormat.yMd(Localizations.localeOf(context).languageCode).format(date),
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
              return Text('$value ${widget.unit}');
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: [
            ...widget._entries.map((e) => FlSpot(
                  e.date.millisecondsSinceEpoch.toDouble(),
                  e.value.toDouble(),
                )),
          ],
          isCurved: false,
          color: Theme.of(context).colorScheme.secondary,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: true),
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
