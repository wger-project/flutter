/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/widgets.dart';

/// Sample time series data type.
class TimeSeriesLog {
  final DateTime time;
  final double weight;

  TimeSeriesLog(this.time, this.weight);
}

class LogChartWidget extends StatelessWidget {
  final _data;
  const LogChartWidget(this._data);

  @override
  Widget build(BuildContext context) {
    return charts.TimeSeriesChart(
      [
        ..._data['chart_data'].map((e) {
          return charts.Series<TimeSeriesLog, DateTime>(
            id: '${e.first['reps']} reps',
            domainFn: (datum, index) => datum.time,
            measureFn: (datum, index) => datum.weight,
            data: [
              ...e.map(
                (entry) => TimeSeriesLog(
                  DateTime.parse(entry['date']),
                  double.parse(entry['weight']),
                ),
              ),
            ],
          );
        }),
      ],
      //behaviors: [new charts.SeriesLegend()],
    );
  }
}
