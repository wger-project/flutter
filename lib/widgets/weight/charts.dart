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
import 'package:flutter/widgets.dart';
import 'package:wger/models/body_weight/weight_entry.dart';
import 'package:wger/theme/theme.dart';

/// Weight chart widget
class WeightChartWidget extends StatelessWidget {
  final List<WeightEntry> _entries;

  /// [_entries] is a list of [WeightEntry] as returned e.g. by the
  /// [BodyWeight] provider.
  WeightChartWidget(this._entries);

  @override
  Widget build(BuildContext context) {
    return charts.TimeSeriesChart(
      [
        charts.Series<WeightEntry, DateTime>(
          id: 'Weight',
          colorFn: (_, __) => wgerChartSecondaryColor,
          domainFn: (WeightEntry weightEntry, _) => weightEntry.date,
          measureFn: (WeightEntry weightEntry, _) => weightEntry.weight,
          data: _entries,
        )
      ],
      defaultRenderer: new charts.LineRendererConfig(includePoints: true),
      primaryMeasureAxis: new charts.NumericAxisSpec(
        tickProviderSpec: new charts.BasicNumericTickProviderSpec(zeroBound: false),
      ),
    );
  }
}
