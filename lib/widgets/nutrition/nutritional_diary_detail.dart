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
import 'package:wger/widgets/nutrition/nutrition_tiles.dart';

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
        const DiaryheaderTile(),
        ...logs.map(
          (e) => DiaryEntryTile(diaryEntry: e, nutritionalPlan: _nutritionalPlan),
        ),
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
    final loc = AppLocalizations.of(context);

    Widget columnHeader(bool left, String title) => Padding(
          padding: const EdgeInsets.symmetric(vertical: tablePadding),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: left ? TextAlign.left : TextAlign.right,
          ),
        );

    TableRow macroRow(int indent, bool g, String title, double Function(NutritionalValues nv) get) {
      final valFn = g ? loc.gValue : loc.kcalValue;
      return TableRow(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: tablePadding, horizontal: indent * 12),
            child: Text(title),
          ),
          Text(valFn(get(planned).toStringAsFixed(0)), textAlign: TextAlign.right),
          Text(valFn(get(logged).toStringAsFixed(0)), textAlign: TextAlign.right),
          Text((get(logged) - get(planned)).toStringAsFixed(0), textAlign: TextAlign.right),
        ],
      );
    }

    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: TableBorder(
        horizontalInside: BorderSide(width: 1, color: Theme.of(context).colorScheme.outline),
      ),
      columnWidths: const {0: FractionColumnWidth(0.4)},
      children: [
        TableRow(children: [
          columnHeader(true, loc.macronutrients),
          columnHeader(false, loc.planned),
          columnHeader(false, loc.logged),
          columnHeader(false, loc.difference),
        ]),
        macroRow(0, false, loc.energy, (NutritionalValues nv) => nv.energy),
        macroRow(0, true, loc.protein, (NutritionalValues nv) => nv.protein),
        macroRow(0, true, loc.carbohydrates, (NutritionalValues nv) => nv.carbohydrates),
        macroRow(1, true, loc.sugars, (NutritionalValues nv) => nv.carbohydratesSugar),
        macroRow(0, true, loc.fat, (NutritionalValues nv) => nv.fat),
        macroRow(1, true, loc.saturatedFat, (NutritionalValues nv) => nv.fatSaturated),
        macroRow(0, true, loc.fiber, (NutritionalValues nv) => nv.fiber),
        macroRow(0, true, loc.sodium, (NutritionalValues nv) => nv.sodium),
      ],
    );
  }
}
