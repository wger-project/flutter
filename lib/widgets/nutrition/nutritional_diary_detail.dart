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
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/models/nutrition/nutritional_values.dart';
import 'package:wger/widgets/nutrition/charts.dart';
import 'package:wger/widgets/nutrition/widgets.dart';

class NutritionalDiaryDetailWidget extends StatelessWidget {
  final NutritionalPlan _nutritionalPlan;
  final DateTime _date;

  const NutritionalDiaryDetailWidget(this._nutritionalPlan, this._date);

  @override
  Widget build(BuildContext context) {
    final nutritionalGoals = _nutritionalPlan.nutritionalGoals;
    final valuesLogged = _nutritionalPlan.getValuesForDate(_date);
    final logs = _nutritionalPlan.getLogsForDate(_date);

    if (valuesLogged == null) {
      return const Text('');
    }

    return Column(
      children: [
        Card(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                height: 220,
                child: FlNutritionalPlanPieChartWidget(valuesLogged),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: NutritionDiaryTable(
                  planned: nutritionalGoals.toValues(),
                  logged: valuesLogged,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        const NutritionDiaryheader(),
        ...logs.map((e) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  NutritionDiaryEntry(diaryEntry: e, nutritionalPlan: _nutritionalPlan),
                ],
              ),
            )),
      ],
    );
  }
}

class NutritionDiaryTable extends StatelessWidget {
  const NutritionDiaryTable({
    super.key,
    required this.planned,
    required this.logged,
  });

  static const double tablePadding = 7;
  final NutritionalValues planned;
  final NutritionalValues logged;

  @override
  Widget build(BuildContext context) {
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: TableBorder(
        horizontalInside: BorderSide(width: 1, color: Theme.of(context).colorScheme.outline),
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
              AppLocalizations.of(context).planned,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              AppLocalizations.of(context).logged,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              AppLocalizations.of(context).difference,
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
            Text(AppLocalizations.of(context).kcalValue(planned.energy.toStringAsFixed(0))),
            Text(AppLocalizations.of(context).kcalValue(logged.energy.toStringAsFixed(0))),
            Text((logged.energy - planned.energy).toStringAsFixed(0)),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: tablePadding),
              child: Text(AppLocalizations.of(context).protein),
            ),
            Text(AppLocalizations.of(context).gValue(planned.protein.toStringAsFixed(0))),
            Text(AppLocalizations.of(context).gValue(logged.protein.toStringAsFixed(0))),
            Text((logged.protein - planned.protein).toStringAsFixed(0)),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: tablePadding),
              child: Text(AppLocalizations.of(context).carbohydrates),
            ),
            Text(AppLocalizations.of(context).gValue(planned.carbohydrates.toStringAsFixed(0))),
            Text(AppLocalizations.of(context).gValue(logged.carbohydrates.toStringAsFixed(0))),
            Text((logged.carbohydrates - planned.carbohydrates).toStringAsFixed(0)),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: tablePadding, horizontal: 12),
              child: Text(AppLocalizations.of(context).sugars),
            ),
            Text(
                AppLocalizations.of(context).gValue(planned.carbohydratesSugar.toStringAsFixed(0))),
            Text(AppLocalizations.of(context).gValue(logged.carbohydratesSugar.toStringAsFixed(0))),
            Text((logged.carbohydratesSugar - planned.carbohydratesSugar).toStringAsFixed(0)),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: tablePadding),
              child: Text(AppLocalizations.of(context).fat),
            ),
            Text(AppLocalizations.of(context).gValue(planned.fat.toStringAsFixed(0))),
            Text(AppLocalizations.of(context).gValue(logged.fat.toStringAsFixed(0))),
            Text((logged.fat - planned.fat).toStringAsFixed(0)),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: tablePadding, horizontal: 12),
              child: Text(AppLocalizations.of(context).saturatedFat),
            ),
            Text(AppLocalizations.of(context).gValue(planned.fatSaturated.toStringAsFixed(0))),
            Text(AppLocalizations.of(context).gValue(logged.fatSaturated.toStringAsFixed(0))),
            Text((logged.fatSaturated - planned.fatSaturated).toStringAsFixed(0)),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: tablePadding),
              child: Text(AppLocalizations.of(context).fibres),
            ),
            Text(AppLocalizations.of(context).gValue(planned.fibres.toStringAsFixed(0))),
            Text(AppLocalizations.of(context).gValue(logged.fibres.toStringAsFixed(0))),
            Text((logged.fibres - planned.fibres).toStringAsFixed(0)),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: tablePadding),
              child: Text(AppLocalizations.of(context).sodium),
            ),
            Text(AppLocalizations.of(context).gValue(planned.sodium.toStringAsFixed(0))),
            Text(AppLocalizations.of(context).gValue(logged.sodium.toStringAsFixed(0))),
            Text((logged.sodium - planned.sodium).toStringAsFixed(0)),
          ],
        ),
      ],
    );
  }
}
