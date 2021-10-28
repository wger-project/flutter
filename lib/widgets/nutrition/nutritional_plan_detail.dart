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

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/models/nutrition/nutritional_values.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/screens/nutritional_diary_screen.dart';
import 'package:wger/theme/theme.dart';
import 'package:wger/widgets/nutrition/charts.dart';
import 'package:wger/widgets/nutrition/forms.dart';
import 'package:wger/widgets/nutrition/meal.dart';

class NutritionalPlanDetailWidget extends StatelessWidget {
  final NutritionalPlan _nutritionalPlan;
  const NutritionalPlanDetailWidget(this._nutritionalPlan);
  static const double tablePadding = 7;

  @override
  Widget build(BuildContext context) {
    final nutritionalValues = _nutritionalPlan.nutritionalValues;
    final valuesPercentage = _nutritionalPlan.energyPercentage(nutritionalValues);
    final lastWeightEntry = Provider.of<BodyWeightProvider>(context, listen: false).getLastEntry();
    final valuesGperKg = lastWeightEntry != null
        ? _nutritionalPlan.gPerBodyKg(lastWeightEntry.weight, nutritionalValues)
        : null;

    return SliverList(
      delegate: SliverChildListDelegate(
        [
          const SizedBox(height: 10),
          ..._nutritionalPlan.meals
              .map((meal) => MealWidget(meal, _nutritionalPlan.allMealItems))
              .toList(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              child: Text(AppLocalizations.of(context).addMeal),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  FormScreen.routeName,
                  arguments: FormScreenArguments(
                    AppLocalizations.of(context).addMeal,
                    MealForm(_nutritionalPlan.id!),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(15),
            height: 220,
            child: NutritionalPlanPieChartWidget(nutritionalValues),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              border: const TableBorder(
                horizontalInside: BorderSide(width: 1, color: wgerTextMuted),
              ),
              columnWidths: const {0: FractionColumnWidth(0.4)},
              children: [
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: tablePadding),
                      child: Text(
                        AppLocalizations.of(context).macronutrients,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context).total,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      AppLocalizations.of(context).percentEnergy,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      AppLocalizations.of(context).gPerBodyKg,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: tablePadding),
                      child: Text(AppLocalizations.of(context).energy),
                    ),
                    Text(
                      nutritionalValues.energy.toStringAsFixed(0) +
                          AppLocalizations.of(context).kcal,
                    ),
                    const Text(''),
                    const Text(''),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: tablePadding),
                      child: Text(AppLocalizations.of(context).protein),
                    ),
                    Text(nutritionalValues.protein.toStringAsFixed(0) +
                        AppLocalizations.of(context).g),
                    Text(valuesPercentage.protein.toStringAsFixed(1)),
                    Text(valuesGperKg != null ? valuesGperKg.protein.toStringAsFixed(1) : ''),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: tablePadding),
                      child: Text(AppLocalizations.of(context).carbohydrates),
                    ),
                    Text(nutritionalValues.carbohydrates.toStringAsFixed(0) +
                        AppLocalizations.of(context).g),
                    Text(valuesPercentage.carbohydrates.toStringAsFixed(1)),
                    Text(valuesGperKg != null ? valuesGperKg.carbohydrates.toStringAsFixed(1) : ''),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: tablePadding, horizontal: 12),
                      child: Text(AppLocalizations.of(context).sugars),
                    ),
                    Text(nutritionalValues.carbohydratesSugar.toStringAsFixed(0) +
                        AppLocalizations.of(context).g),
                    const Text(''),
                    const Text(''),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: tablePadding),
                      child: Text(AppLocalizations.of(context).fat),
                    ),
                    Text(nutritionalValues.fat.toStringAsFixed(0) + AppLocalizations.of(context).g),
                    Text(valuesPercentage.fat.toStringAsFixed(1)),
                    Text(valuesGperKg != null ? valuesGperKg.fat.toStringAsFixed(1) : ''),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: tablePadding, horizontal: 12),
                      child: Text(AppLocalizations.of(context).saturatedFat),
                    ),
                    Text(nutritionalValues.fatSaturated.toStringAsFixed(0) +
                        AppLocalizations.of(context).g),
                    const Text(''),
                    const Text(''),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: tablePadding),
                      child: Text(AppLocalizations.of(context).fibres),
                    ),
                    Text(nutritionalValues.fibres.toStringAsFixed(0) +
                        AppLocalizations.of(context).g),
                    const Text(''),
                    const Text(''),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: tablePadding),
                      child: Text(AppLocalizations.of(context).sodium),
                    ),
                    Text(nutritionalValues.sodium.toStringAsFixed(0) +
                        AppLocalizations.of(context).g),
                    const Text(''),
                    const Text(''),
                  ],
                ),
              ],
            ),
          ),
          const Padding(padding: EdgeInsets.all(8.0)),
          Text(
            AppLocalizations.of(context).nutritionalDiary,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline6,
          ),
          Container(
            padding: const EdgeInsets.all(15),
            height: 220,
            child: NutritionalDiaryChartWidget(nutritionalPlan: _nutritionalPlan),
          ),
          SizedBox(
            height: 200,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () {}, child: const Text('')),
                      Text(
                          '${AppLocalizations.of(context).energyShort} (${AppLocalizations.of(context).kcal})'),
                      Text(
                          '${AppLocalizations.of(context).proteinShort} (${AppLocalizations.of(context).g})'),
                      Text(
                          '${AppLocalizations.of(context).carbohydratesShort} (${AppLocalizations.of(context).g})'),
                      Text(
                          '${AppLocalizations.of(context).fatShort} (${AppLocalizations.of(context).g})'),
                    ],
                  ),
                ),
                ..._nutritionalPlan.logEntriesValues.entries
                    .map((entry) => NutritionDiaryEntry(entry.key, entry.value, _nutritionalPlan))
                    .toList()
                    .reversed,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NutritionDiaryEntry extends StatelessWidget {
  final DateTime date;
  final NutritionalValues values;
  final NutritionalPlan plan;

  const NutritionDiaryEntry(
    this.date,
    this.values,
    this.plan,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextButton(
              onPressed: () => Navigator.of(context).pushNamed(
                    NutritionalDiaryScreen.routeName,
                    arguments: NutritionalDiaryArguments(plan, date),
                  ),
              child: Text(
                DateFormat.yMd(Localizations.localeOf(context).languageCode).format(date),
              )),
          Text(values.energy.toStringAsFixed(0)),
          Text(values.protein.toStringAsFixed(0)),
          Text(values.carbohydrates.toStringAsFixed(0)),
          Text(values.fat.toStringAsFixed(0)),
        ],
      ),
    );
  }
}
