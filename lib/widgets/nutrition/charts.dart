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
import 'package:wger/models/nutrition/nutritrional_values.dart';

/// Nutritional plan pie chart widget
class NutritionalPlanPieChartWidget extends StatelessWidget {
  final NutritionalValues _nutritionalValues;

  /// [_nutritionalValues] are the calculated [NutritionalValues] for the wanted
  /// plan.
  NutritionalPlanPieChartWidget(this._nutritionalValues);

  @override
  Widget build(BuildContext context) {
    return charts.PieChart(
      [
        charts.Series<List<dynamic>, String>(
          id: 'NutritionalValues',
          domainFn: (datum, index) => datum[0],
          measureFn: (datum, index) => datum[1],
          data: [
            ['protein', _nutritionalValues.protein],
            ['fat', _nutritionalValues.fat],
            ['carbohydrates', _nutritionalValues.carbohydrates],
          ],
          labelAccessorFn: (List<dynamic> row, _) => '${row[0]}, ${row[1].toStringAsFixed(0)}g',
        )
      ],
      defaultRenderer: new charts.ArcRendererConfig(
        arcWidth: 60,
        arcRendererDecorators: [new charts.ArcLabelDecorator()],
      ),
    );
  }
}
