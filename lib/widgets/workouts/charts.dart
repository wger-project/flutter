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

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Sample time series data type.
class TimeSeriesLog {
  final DateTime time;
  final double weight;

  TimeSeriesLog(this.time, this.weight);
}

class LogChartWidget extends StatelessWidget {
  final _data;
  final DateTime _currentDate;
  const LogChartWidget(this._data, this._currentDate);

  @override
  Widget build(BuildContext context) {
    return _data.containsKey('chart_data') && _data['chart_data'].length > 0
        ? charts.TimeSeriesChart(
            [
              ..._data['chart_data'].map((e) {
                return charts.Series<TimeSeriesLog, DateTime>(
                  id: '${e.first['reps']} ${AppLocalizations.of(context).reps}',
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
            primaryMeasureAxis: new charts.NumericAxisSpec(
              tickProviderSpec:
                  new charts.BasicNumericTickProviderSpec(zeroBound: false),
            ),
            behaviors: [
              new charts.SeriesLegend(
                position: charts.BehaviorPosition.bottom,
              ),
              new charts.RangeAnnotation([
                charts.LineAnnotationSegment(
                  _currentDate, charts.RangeAnnotationAxisType.domain,
                  strokeWidthPx: 2,
                  labelPosition: charts.AnnotationLabelPosition.margin,
                  color: charts.Color.black,
                  dashPattern: [0, 1, 1, 1],
                  //startLabel: DateFormat.yMd(Localizations.localeOf(context).languageCode)
                  //      .format(_currentDate),
                )
              ]),
            ],
          )
        : Container();
  }
}
