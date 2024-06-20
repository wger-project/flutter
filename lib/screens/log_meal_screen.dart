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
import 'package:wger/models/nutrition/meal.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/widgets/nutrition/meal.dart';
import 'package:wger/widgets/nutrition/nutrition_tiles.dart';

class LogMealArguments {
  final Meal meal;
  final bool popTwice;

  const LogMealArguments(this.meal, this.popTwice);
}

class LogMealScreen extends StatefulWidget {
  const LogMealScreen();
  static const routeName = '/log-meal';

  @override
  State<LogMealScreen> createState() => _LogMealScreenState();
}

class _LogMealScreenState extends State<LogMealScreen> {
  double portionPct = 100;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as LogMealArguments;
    final meal = args.meal.copyWith(
      mealItems: args.meal.mealItems
          .map((mealItem) => mealItem.copyWith(amount: mealItem.amount * portionPct / 100))
          .toList(),
    );

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).logMeal)),
      body: Consumer<NutritionPlansProvider>(
        builder: (context, nutritionProvider, child) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Column(
              children: [
                Text(
                  meal.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (meal.mealItems.isEmpty)
                  ListTile(title: Text(AppLocalizations.of(context).noIngredientsDefined))
                else
                  Column(
                    children: [
                      const DiaryheaderTile(),
                      ...meal.mealItems.map(
                        (item) => MealItemEditableFullTile(item, viewMode.withAllDetails, false),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Portion: ${portionPct.round()} %',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Slider.adaptive(
                        min: 0,
                        max: 150,
                        divisions: 30,
                        onChanged: (value) => setState(() => portionPct = value),
                        value: portionPct,
                      ),
                    ],
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (meal.mealItems.isNotEmpty)
                      TextButton(
                        child: const Text('Log'),
                        onPressed: () async {
                          await Provider.of<NutritionPlansProvider>(
                            context,
                            listen: false,
                          ).logMealToDiary(meal);
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                // ignore: use_build_context_synchronously
                                AppLocalizations.of(context).mealLogged,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                          Navigator.of(context).pop();
                          if (args.popTwice) {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    TextButton(
                      child: Text(
                        MaterialLocalizations.of(context).cancelButtonLabel,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
