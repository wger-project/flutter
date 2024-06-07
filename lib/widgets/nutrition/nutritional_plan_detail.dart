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
import 'package:provider/provider.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/widgets/nutrition/charts.dart';
import 'package:wger/widgets/nutrition/macro_nutrients_table.dart';
import 'package:wger/widgets/nutrition/meal.dart';
import 'package:wger/widgets/nutrition/nutritional_diary_table.dart';

class NutritionalPlanDetailWidget extends StatelessWidget {
  final NutritionalPlan _nutritionalPlan;

  const NutritionalPlanDetailWidget(this._nutritionalPlan);

  @override
  Widget build(BuildContext context) {
    final nutritionalGoals = _nutritionalPlan.nutritionalGoals;
    final lastWeightEntry =
        Provider.of<BodyWeightProvider>(context, listen: false).getNewestEntry();
    final nutritionalGoalsGperKg =
        lastWeightEntry != null ? nutritionalGoals / lastWeightEntry.weight.toDouble() : null;

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
                _nutritionalPlan.dedupMealItems,
                false,
                false,
              )),
          MealWidget(
            _nutritionalPlan.pseudoMealOthers('Other logs'),
            _nutritionalPlan.dedupMealItems,
            false,
            true,
          ),
          if (nutritionalGoals.isComplete())
            Container(
              padding: const EdgeInsets.all(15),
              height: 220,
              child: FlNutritionalPlanPieChartWidget(nutritionalGoals.toValues()),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: MacronutrientsTable(
              nutritionalGoals: nutritionalGoals,
              plannedValuesPercentage: nutritionalGoals.energyPercentage(),
              nutritionalGoalsGperKg: nutritionalGoalsGperKg,
            ),
          ),
          const Padding(padding: EdgeInsets.all(8.0)),
          Text(
            AppLocalizations.of(context).logged,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Container(
            padding: const EdgeInsets.only(top: 16, left: 8, right: 8),
            height: 300,
            child: NutritionalDiaryChartWidgetFl(
              nutritionalPlan: _nutritionalPlan,
            ),
          ),
          if (_nutritionalPlan.logEntriesValues.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context).nutritionalDiary,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(
                    height: 200,
                    child: SingleChildScrollView(
                      child: NutritionalDiaryTable(
                        nutritionalPlan: _nutritionalPlan,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
