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
import 'package:wger/models/nutrition/log.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/models/nutrition/nutritional_values.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/widgets/nutrition/charts.dart';
import 'package:wger/widgets/nutrition/helpers.dart';

class NutritionalDiaryDetailWidget extends StatelessWidget {
  final NutritionalPlan _nutritionalPlan;
  final DateTime _date;
  static const double tablePadding = 7;

  const NutritionalDiaryDetailWidget(this._nutritionalPlan, this._date);

  Widget getTable(
    NutritionalValues valuesTotal,
    NutritionalValues valuesDate,
    BuildContext context,
  ) {
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
            Text(
              valuesTotal.energy.toStringAsFixed(0) + AppLocalizations.of(context).kcal,
            ),
            Text(
              valuesDate.energy.toStringAsFixed(0) + AppLocalizations.of(context).kcal,
            ),
            Text((valuesDate.energy - valuesTotal.energy).toStringAsFixed(0)),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: tablePadding),
              child: Text(AppLocalizations.of(context).protein),
            ),
            Text(valuesTotal.protein.toStringAsFixed(0) + AppLocalizations.of(context).g),
            Text(valuesDate.protein.toStringAsFixed(0) + AppLocalizations.of(context).g),
            Text((valuesDate.protein - valuesTotal.protein).toStringAsFixed(0)),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: tablePadding),
              child: Text(AppLocalizations.of(context).carbohydrates),
            ),
            Text(valuesTotal.carbohydrates.toStringAsFixed(0) + AppLocalizations.of(context).g),
            Text(valuesDate.carbohydrates.toStringAsFixed(0) + AppLocalizations.of(context).g),
            Text((valuesDate.carbohydrates - valuesTotal.carbohydrates).toStringAsFixed(0)),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: tablePadding, horizontal: 12),
              child: Text(AppLocalizations.of(context).sugars),
            ),
            Text(
                valuesTotal.carbohydratesSugar.toStringAsFixed(0) + AppLocalizations.of(context).g),
            Text(valuesDate.carbohydratesSugar.toStringAsFixed(0) + AppLocalizations.of(context).g),
            Text((valuesDate.carbohydratesSugar - valuesTotal.carbohydratesSugar)
                .toStringAsFixed(0)),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: tablePadding),
              child: Text(AppLocalizations.of(context).fat),
            ),
            Text(valuesTotal.fat.toStringAsFixed(0) + AppLocalizations.of(context).g),
            Text(valuesDate.fat.toStringAsFixed(0) + AppLocalizations.of(context).g),
            Text((valuesDate.fat - valuesTotal.fat).toStringAsFixed(0)),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: tablePadding, horizontal: 12),
              child: Text(AppLocalizations.of(context).saturatedFat),
            ),
            Text(valuesTotal.fatSaturated.toStringAsFixed(0) + AppLocalizations.of(context).g),
            Text(valuesDate.fatSaturated.toStringAsFixed(0) + AppLocalizations.of(context).g),
            Text((valuesDate.fatSaturated - valuesTotal.fatSaturated).toStringAsFixed(0)),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: tablePadding),
              child: Text(AppLocalizations.of(context).fibres),
            ),
            Text(valuesTotal.fibres.toStringAsFixed(0) + AppLocalizations.of(context).g),
            Text(valuesDate.fibres.toStringAsFixed(0) + AppLocalizations.of(context).g),
            Text((valuesDate.fibres - valuesTotal.fibres).toStringAsFixed(0)),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: tablePadding),
              child: Text(AppLocalizations.of(context).sodium),
            ),
            Text(valuesTotal.sodium.toStringAsFixed(0) + AppLocalizations.of(context).g),
            Text(valuesDate.sodium.toStringAsFixed(0) + AppLocalizations.of(context).g),
            Text((valuesDate.sodium - valuesTotal.sodium).toStringAsFixed(0)),
          ],
        ),
      ],
    );
  }

  List<Widget> getEntriesTable(List<Log> logs, BuildContext context) {
    return logs.map((log) {
      final values = log.nutritionalValues;

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            DateFormat.Hm(Localizations.localeOf(context).languageCode).format(log.datetime),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${log.amount.toStringAsFixed(0)}${AppLocalizations.of(context).g} ${log.ingredientObj.name}',
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                ...getMutedNutritionalValues(values, context),
                const SizedBox(height: 12),
              ],
            ),
          ),
          IconButton(
              tooltip: AppLocalizations.of(context).delete,
              onPressed: () {
                Provider.of<NutritionPlansProvider>(context, listen: false)
                    .deleteLog(log.id!, _nutritionalPlan.id!);
              },
              icon: const Icon(Icons.delete_outline)),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final valuesTotal = _nutritionalPlan.nutritionalValues;
    final valuesDate = _nutritionalPlan.getValuesForDate(_date);
    final logs = _nutritionalPlan.getLogsForDate(_date);

    if (valuesDate == null) {
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
                child: FlNutritionalPlanPieChartWidget(valuesDate),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: getTable(valuesTotal, valuesDate, context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        ...getEntriesTable(logs, context),
      ],
    );
  }
}
