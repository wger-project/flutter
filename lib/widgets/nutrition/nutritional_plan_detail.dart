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
import 'package:flutter/material.dart';
import 'package:wger/locale/locales.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/widgets/core/bottom_sheet.dart';
import 'package:wger/widgets/nutrition/forms.dart';
import 'package:wger/widgets/nutrition/meal.dart';

class NutritionalPlanDetailWidget extends StatelessWidget {
  NutritionalPlan _nutritionalPlan;
  NutritionalPlanDetailWidget(this._nutritionalPlan);

  @override
  Widget build(BuildContext context) {
    final nutritionalValues = _nutritionalPlan.nutritionalValues;

    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                DefaultMaterialLocalizations()
                    .formatMediumDate(_nutritionalPlan.creationDate)
                    .toString(),
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                _nutritionalPlan.description,
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            ..._nutritionalPlan.meals.map((meal) => MealWidget(meal)).toList(),
            ElevatedButton(
              child: Text(AppLocalizations.of(context).add),
              onPressed: () {
                showFormBottomSheet(context, 'Add meal', MealForm(_nutritionalPlan));
              },
            ),
            Container(
              padding: EdgeInsets.all(15),
              height: 220,
              child: charts.PieChart(
                [
                  charts.Series<List<dynamic>, String>(
                    id: 'NutritionalValues',
                    domainFn: (datum, index) => datum[0],
                    measureFn: (datum, index) => datum[1],
                    data: [
                      ['protein', nutritionalValues.protein],
                      ['fat', nutritionalValues.fat],
                      ['carbohydrates', nutritionalValues.carbohydrates],
                    ],
                    labelAccessorFn: (List<dynamic> row, _) =>
                        '${row[0]}, ${row[1].toStringAsFixed(0)}g',
                  )
                ],
                defaultRenderer: new charts.ArcRendererConfig(
                  arcWidth: 60,
                  arcRendererDecorators: [new charts.ArcLabelDecorator()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
