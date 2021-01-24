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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wger/locale/locales.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/models/nutrition/nutritrional_values.dart';
import 'package:wger/widgets/core/bottom_sheet.dart';
import 'package:wger/widgets/nutrition/charts.dart';
import 'package:wger/widgets/nutrition/forms.dart';
import 'package:wger/widgets/nutrition/meal.dart';

class NutritionalPlanDetailWidget extends StatelessWidget {
  final NutritionalPlan _nutritionalPlan;
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
                _nutritionalPlan.description,
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                DateFormat.yMd().format(_nutritionalPlan.creationDate),
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            ElevatedButton(
              child: Text(AppLocalizations.of(context).add),
              onPressed: () {
                showFormBottomSheet(
                  context,
                  AppLocalizations.of(context).addMeal,
                  MealForm(_nutritionalPlan.id),
                );
              },
            ),
            if (_nutritionalPlan.meals != null && _nutritionalPlan.meals.length > 0)
              ..._nutritionalPlan.meals.map((meal) => MealWidget(meal)).toList(),
            Container(
              padding: EdgeInsets.all(15),
              height: 220,
              child: NutritionalPlanPieChartWidget(nutritionalValues),
            ),
            Container(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(AppLocalizations.of(context).energy),
                        Text(AppLocalizations.of(context).protein),
                        Text(AppLocalizations.of(context).carbohydrates),
                        Text(AppLocalizations.of(context).sugars),
                        Text(AppLocalizations.of(context).fat),
                        Text(AppLocalizations.of(context).saturatedFat),
                        Text(AppLocalizations.of(context).fibres),
                        Text(AppLocalizations.of(context).sodium),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(nutritionalValues.energy.toStringAsFixed(0)),
                        Text(nutritionalValues.protein.toStringAsFixed(0)),
                        Text(nutritionalValues.carbohydrates.toStringAsFixed(0)),
                        Text(nutritionalValues.carbohydratesSugar.toStringAsFixed(0)),
                        Text(nutritionalValues.fat.toStringAsFixed(0)),
                        Text(nutritionalValues.fatSaturated.toStringAsFixed(0)),
                        Text(nutritionalValues.fibres.toStringAsFixed(0)),
                        Text(nutritionalValues.sodium.toStringAsFixed(0)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context).kcal),
                      Text(AppLocalizations.of(context).g),
                      Text(AppLocalizations.of(context).g),
                      Text(AppLocalizations.of(context).g),
                      Text(AppLocalizations.of(context).g),
                      Text(AppLocalizations.of(context).g),
                      Text(AppLocalizations.of(context).g),
                      Text(AppLocalizations.of(context).g),
                    ],
                  ),
                ],
              ),
            ),
            Padding(padding: const EdgeInsets.all(8.0)),
            Text('Diary', style: Theme.of(context).textTheme.headline6),
            Container(
              padding: EdgeInsets.all(15),
              height: 220,
              child: NutritionalDiaryChartWidget(nutritionalPlan: _nutritionalPlan),
            ),
            Container(
              height: 200,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(''),
                          Text(
                              '${AppLocalizations.of(context).energy} (${AppLocalizations.of(context).kcal}'),
                          Text(
                              '${AppLocalizations.of(context).protein} (${AppLocalizations.of(context).g})'),
                          Text(
                              '${AppLocalizations.of(context).carbohydrates} (${AppLocalizations.of(context).g})'),
                          Text(
                              '${AppLocalizations.of(context).sugars} (${AppLocalizations.of(context).g})'),
                          Text(
                              '${AppLocalizations.of(context).fat} (${AppLocalizations.of(context).g})'),
                          Text(
                              '${AppLocalizations.of(context).saturatedFat} (${AppLocalizations.of(context).g})'),
                        ],
                      ),
                    ),
                    ..._nutritionalPlan.logEntriesValues.entries
                        .map((entry) => NutritionDiaryEntry(entry.key, entry.value))
                        .toList()
                        .reversed,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NutritionDiaryEntry extends StatelessWidget {
  final DateTime date;
  final NutritionalValues values;

  NutritionDiaryEntry(
    this.date,
    this.values,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(DateFormat.yMd().format(date).toString(),
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text(values.energy.toStringAsFixed(0)),
          Text(values.protein.toStringAsFixed(0)),
          Text(values.carbohydrates.toStringAsFixed(0)),
          Text(values.carbohydratesSugar.toStringAsFixed(0)),
          Text(values.fat.toStringAsFixed(0)),
          Text(values.fatSaturated.toStringAsFixed(0)),
        ],
      ),
    );
  }
}
