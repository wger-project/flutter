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
import 'package:wger/theme/theme.dart';

class MeasurementChartEntry {
  num value;
  DateTime date;

  MeasurementChartEntry(this.value, this.date);
}

/// Weight chart widget
class MeasurementChartWidget extends StatelessWidget {
  final List<MeasurementChartEntry> _entries;
  final String unit;

  /// [_entries] is a list of [MeasurementChartEntry]
  const MeasurementChartWidget(this._entries, {this.unit = 'kg'});

  @override
  Widget build(BuildContext context) {
    final unitTickFormatter = charts.BasicNumericTickFormatterSpec((num? value) => '$value $unit');

    return charts.TimeSeriesChart(
      [
        charts.Series<MeasurementChartEntry, DateTime>(
          id: 'Measurement',
          colorFn: (_, __) => wgerChartSecondaryColor,
          domainFn: (MeasurementChartEntry entry, _) => entry.date,
          measureFn: (MeasurementChartEntry entry, _) => entry.value,
          data: _entries,
        )
      ],
      animate: true,
      defaultRenderer: charts.LineRendererConfig(includePoints: true),
      primaryMeasureAxis: charts.NumericAxisSpec(
        tickProviderSpec: const charts.BasicNumericTickProviderSpec(zeroBound: false),
        tickFormatterSpec: unitTickFormatter,
      ),
    );
  }
}
