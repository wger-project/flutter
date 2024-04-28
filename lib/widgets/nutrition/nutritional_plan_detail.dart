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
import 'package:wger/helpers/colors.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/models/nutrition/nutritional_values.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/screens/nutritional_diary_screen.dart';
import 'package:wger/widgets/measurements/charts.dart';
import 'package:wger/widgets/nutrition/charts.dart';
import 'package:wger/widgets/nutrition/forms.dart';
import 'package:wger/widgets/nutrition/meal.dart';

class NutritionalPlanDetailWidget extends StatelessWidget {
  final NutritionalPlan _nutritionalPlan;

  const NutritionalPlanDetailWidget(this._nutritionalPlan);

  @override
  Widget build(BuildContext context) {
    final plannedNutritionalValues = _nutritionalPlan.plannedNutritionalValues;
    final lastWeightEntry =
        Provider.of<BodyWeightProvider>(context, listen: false).getNewestEntry();
    final valuesGperKg = lastWeightEntry != null
        ? _nutritionalPlan.gPerBodyKg(lastWeightEntry.weight, plannedNutritionalValues)
        : null;

    return SliverList(
        delegate: SliverChildListDelegate(
      [
        SizedBox(
          width: 300,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FlNutritionalPlanGoalWidget(
              nutritionalPlan: _nutritionalPlan,
            ),
          ),
        ),
        const SizedBox(height: 10),
        ..._nutritionalPlan.meals.map((meal) => MealWidget(
              meal,
              _nutritionalPlan.allMealItems,
            )),
        MealWidget(
          _nutritionalPlan.pseudoMealOthers('Other logs'),
          _nutritionalPlan.allMealItems,
        ),
        if (!_nutritionalPlan.onlyLogging)
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
          child: FlNutritionalPlanPieChartWidget(plannedNutritionalValues), // chart
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: MacronutrientsTable(
            plannedNutritionalValues: plannedNutritionalValues,
            plannedValuesPercentage: _nutritionalPlan.energyPercentage(plannedNutritionalValues),
            plannedValuesGperKg: valuesGperKg,
          ),
        ),
        const Padding(padding: EdgeInsets.all(8.0)),
        Text(
          AppLocalizations.of(context).logged,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Container(
          padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
          height: 300,
          child: NutritionalDiaryChartWidgetFl(nutritionalPlan: _nutritionalPlan), //  chart
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 40, left: 25, right: 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Indicator(
                color: LIST_OF_COLORS3[0],
                text: AppLocalizations.of(context).deficit,
                isSquare: true,
                marginRight: 0,
              ),
              Indicator(
                color: COLOR_SURPLUS,
                text: AppLocalizations.of(context).surplus,
                isSquare: true,
                marginRight: 0,
              ),
              Indicator(
                color: LIST_OF_COLORS3[1],
                text: AppLocalizations.of(context).today,
                isSquare: true,
                marginRight: 0,
              ),
              Indicator(
                color: LIST_OF_COLORS3[2],
                text: AppLocalizations.of(context).weekAverage,
                isSquare: true,
                marginRight: 0,
              ),
            ],
          ),
        ),
        if (_nutritionalPlan.logEntriesValues.isNotEmpty)
          Column(
            children: [
              Text(
                AppLocalizations.of(context).nutritionalDiary,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              SizedBox(
                  height: 200,
                  child: SingleChildScrollView(
                    child: Table(
                      children: [
                        nutrionalDiaryHeader(context, _nutritionalPlan),
                        ..._nutritionalPlan.logEntriesValues.entries.map((entry) =>
                            nutritionDiaryEntry(context, entry.key, entry.value, _nutritionalPlan))
                      ],
                    ),
                  )),
            ],
          ),
      ],
    ));
  }
}

class MacronutrientsTable extends StatelessWidget {
  const MacronutrientsTable({
    super.key,
    required this.plannedNutritionalValues,
    required this.plannedValuesPercentage,
    required this.plannedValuesGperKg,
  });

  static const double tablePadding = 7;
  final NutritionalValues plannedNutritionalValues;
  final BaseNutritionalValues plannedValuesPercentage;
  final BaseNutritionalValues? plannedValuesGperKg;

  @override
  Widget build(BuildContext context) {
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: TableBorder(
        horizontalInside: BorderSide(
          width: 1,
          color: Theme.of(context).colorScheme.outline,
        ),
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
              plannedNutritionalValues.energy.toStringAsFixed(0) +
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
            Text(plannedNutritionalValues.protein.toStringAsFixed(0) +
                AppLocalizations.of(context).g),
            Text(plannedValuesPercentage.protein.toStringAsFixed(1)),
            Text(
                plannedValuesGperKg != null ? plannedValuesGperKg!.protein.toStringAsFixed(1) : ''),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: tablePadding),
              child: Text(AppLocalizations.of(context).carbohydrates),
            ),
            Text(plannedNutritionalValues.carbohydrates.toStringAsFixed(0) +
                AppLocalizations.of(context).g),
            Text(plannedValuesPercentage.carbohydrates.toStringAsFixed(1)),
            Text(plannedValuesGperKg != null
                ? plannedValuesGperKg!.carbohydrates.toStringAsFixed(1)
                : ''),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: tablePadding, horizontal: 12),
              child: Text(AppLocalizations.of(context).sugars),
            ),
            Text(plannedNutritionalValues.carbohydratesSugar.toStringAsFixed(0) +
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
            Text(plannedNutritionalValues.fat.toStringAsFixed(0) + AppLocalizations.of(context).g),
            Text(plannedValuesPercentage.fat.toStringAsFixed(1)),
            Text(plannedValuesGperKg != null ? plannedValuesGperKg!.fat.toStringAsFixed(1) : ''),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: tablePadding, horizontal: 12),
              child: Text(AppLocalizations.of(context).saturatedFat),
            ),
            Text(plannedNutritionalValues.fatSaturated.toStringAsFixed(0) +
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
            Text(plannedNutritionalValues.fibres.toStringAsFixed(0) +
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
            Text(plannedNutritionalValues.sodium.toStringAsFixed(0) +
                AppLocalizations.of(context).g),
            const Text(''),
            const Text(''),
          ],
        ),
      ],
    );
  }
}

TableRow nutrionalDiaryHeader(BuildContext context, final NutritionalPlan plan) {
  return TableRow(
    children: [
      TextButton(onPressed: () {}, child: const Text('')),
      Text('${AppLocalizations.of(context).energyShort} (${AppLocalizations.of(context).kcal})'),
      if (plan.goalEnergy != null) Text(AppLocalizations.of(context).difference),
      Text('${AppLocalizations.of(context).protein} (${AppLocalizations.of(context).g})'),
      Text(
          '${AppLocalizations.of(context).carbohydratesShort} (${AppLocalizations.of(context).g})'),
      Text('${AppLocalizations.of(context).fatShort} (${AppLocalizations.of(context).g})'),
    ],
  );
}

TableRow nutritionDiaryEntry(final BuildContext context, final DateTime date,
    final NutritionalValues values, final NutritionalPlan plan) {
  return TableRow(
    children: [
      GestureDetector(
          onTap: () => Navigator.of(context).pushNamed(
                NutritionalDiaryScreen.routeName,
                arguments: NutritionalDiaryArguments(plan, date),
              ),
          child: Text(
            style: TextStyle(color: LIST_OF_COLORS3.first),
            DateFormat.Md(Localizations.localeOf(context).languageCode).format(date),
          )),
      Text(values.energy.toStringAsFixed(0)),
      if (plan.goalEnergy != null) Text((values.energy - plan.goalEnergy!).toStringAsFixed(0)),
      Text(values.protein.toStringAsFixed(0)),
      Text(values.carbohydrates.toStringAsFixed(0)),
      Text(values.fat.toStringAsFixed(0)),
    ],
  );
}
