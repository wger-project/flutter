/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:material_ui/material_ui.dart';
import 'package:wger/features/nutrition/models/ingredient.dart';
import 'package:wger/features/nutrition/models/log.dart';
import 'package:wger/features/nutrition/models/meal.dart';
import 'package:wger/features/nutrition/models/meal_item.dart';
import 'package:wger/features/nutrition/models/nutritional_plan.dart';

const _planUuid = 'cc000000-0000-4000-8000-000000000010';
const _mealUuids = [
  'cc000000-0000-4000-8000-000000000001',
  'cc000000-0000-4000-8000-000000000002',
  'cc000000-0000-4000-8000-000000000003',
  'cc000000-0000-4000-8000-000000000004',
];

/// Nutrition values are per 100 g, roughly matching the real foods.
Ingredient _ingredient(
  int id,
  String name, {
  required int energy,
  required num carbs,
  required num sugar,
  required num protein,
  required num fat,
  required num fatSaturated,
  required num fiber,
  bool isVegan = false,
  NutriScore? nutriscore,
}) => Ingredient(
  remoteId: '$id',
  sourceName: 'Built-in testdata',
  sourceUrl: 'https://example.com/ingredient/$id',
  id: id,
  code: '20000000$id',
  name: name,
  created: DateTime(2026, 1, 1),
  energy: energy,
  carbohydrates: carbs,
  carbohydratesSugar: sugar,
  protein: protein,
  fat: fat,
  fatSaturated: fatSaturated,
  fiber: fiber,
  sodium: 0.05,
  isVegan: isVegan,
  isVegetarian: true,
  nutriscore: nutriscore,
);

final _oats = _ingredient(
  201,
  'Rolled oats',
  energy: 372,
  carbs: 58.7,
  sugar: 0.7,
  protein: 13.5,
  fat: 7,
  fatSaturated: 1.2,
  fiber: 10,
  isVegan: true,
  nutriscore: NutriScore.a,
);
final _milk = _ingredient(
  202,
  'Whole milk',
  energy: 64,
  carbs: 4.7,
  sugar: 4.7,
  protein: 3.4,
  fat: 3.6,
  fatSaturated: 2.3,
  fiber: 0,
  nutriscore: NutriScore.b,
);
final _banana = _ingredient(
  203,
  'Banana',
  energy: 89,
  carbs: 22.8,
  sugar: 12.2,
  protein: 1.1,
  fat: 0.3,
  fatSaturated: 0.1,
  fiber: 2.6,
  isVegan: true,
  nutriscore: NutriScore.a,
);
final _chicken = _ingredient(
  204,
  'Chicken breast',
  energy: 107,
  carbs: 0,
  sugar: 0,
  protein: 23.1,
  fat: 1.8,
  fatSaturated: 0.5,
  fiber: 0,
  nutriscore: NutriScore.a,
);
final _rice = _ingredient(
  205,
  'Basmati rice, cooked',
  energy: 130,
  carbs: 28.2,
  sugar: 0.1,
  protein: 2.7,
  fat: 0.3,
  fatSaturated: 0.1,
  fiber: 0.4,
  isVegan: true,
  nutriscore: NutriScore.a,
);
final _broccoli = _ingredient(
  206,
  'Broccoli',
  energy: 34,
  carbs: 6.6,
  sugar: 1.7,
  protein: 2.8,
  fat: 0.4,
  fatSaturated: 0.1,
  fiber: 2.6,
  isVegan: true,
  nutriscore: NutriScore.a,
);
final _skyr = _ingredient(
  207,
  'Skyr',
  energy: 63,
  carbs: 4,
  sugar: 4,
  protein: 10.6,
  fat: 0.2,
  fatSaturated: 0.1,
  fiber: 0,
  nutriscore: NutriScore.a,
);
final _apple = _ingredient(
  208,
  'Apple',
  energy: 52,
  carbs: 13.8,
  sugar: 10.4,
  protein: 0.3,
  fat: 0.2,
  fatSaturated: 0,
  fiber: 2.4,
  isVegan: true,
  nutriscore: NutriScore.a,
);
final _salmon = _ingredient(
  209,
  'Salmon fillet',
  energy: 208,
  carbs: 0,
  sugar: 0,
  protein: 20.4,
  fat: 13.4,
  fatSaturated: 3.1,
  fiber: 0,
  nutriscore: NutriScore.b,
);
final _potatoes = _ingredient(
  210,
  'Potatoes, boiled',
  energy: 77,
  carbs: 17,
  sugar: 0.8,
  protein: 2,
  fat: 0.1,
  fatSaturated: 0,
  fiber: 2.2,
  isVegan: true,
  nutriscore: NutriScore.a,
);

/// A lean bulk plan running relative to today: four meals with real foods,
/// explicit macro goals, breakfast, lunch and the snack already logged today,
/// and two weeks of diary history for the logged chart.
NutritionalPlan getNutritionalPlanScreenshot() {
  final today = DateTime.now();

  MealItem item(Ingredient ingredient, num amount) =>
      MealItem(ingredientId: ingredient.id, amount: amount, ingredient: ingredient);

  final meals = [
    Meal(
      id: _mealUuids[0],
      plan: _planUuid,
      time: const TimeOfDay(hour: 7, minute: 0),
      name: 'Breakfast',
      mealItems: [item(_oats, 80), item(_milk, 300), item(_banana, 120)],
    ),
    Meal(
      id: _mealUuids[1],
      plan: _planUuid,
      time: const TimeOfDay(hour: 12, minute: 30),
      name: 'Lunch',
      mealItems: [item(_chicken, 180), item(_rice, 250), item(_broccoli, 150)],
    ),
    Meal(
      id: _mealUuids[2],
      plan: _planUuid,
      time: const TimeOfDay(hour: 16, minute: 0),
      name: 'Snack',
      mealItems: [item(_skyr, 300), item(_apple, 180)],
    ),
    Meal(
      id: _mealUuids[3],
      plan: _planUuid,
      time: const TimeOfDay(hour: 19, minute: 0),
      name: 'Dinner',
      mealItems: [item(_salmon, 200), item(_potatoes, 300), item(_broccoli, 150)],
    ),
  ];

  final plan = NutritionalPlan(
    id: _planUuid,
    description: 'Lean bulk',
    creationDate: today.subtract(const Duration(days: 45)),
    startDate: today.subtract(const Duration(days: 45)),
    onlyLogging: false,
    hasGoalCalories: true,
    goalEnergy: 2400,
    goalProtein: 150,
    goalCarbohydrates: 250,
    goalFat: 80,
    goalFiber: 30,
    meals: meals,
  );

  // A meal logged on [date]: one diary entry per planned item, attached to
  // the plan and, for today, to the meal so its card shows the progress
  void logMeal(Meal meal, DateTime date) {
    for (final mealItem in meal.mealItems) {
      final log = LogItem.fromMealItem(mealItem, _planUuid, meal.id, date);
      plan.diaryEntries.add(log);
      if (date.day == today.day && date.month == today.month && date.year == today.year) {
        meal.diaryEntries.add(log);
      }
    }
  }

  DateTime at(int daysAgo, TimeOfDay time) => DateTime(
    today.year,
    today.month,
    today.day - daysAgo,
    time.hour,
    time.minute,
  );

  // Today: everything up to the afternoon snack is logged, dinner is not
  for (final meal in meals.take(3)) {
    logMeal(meal, at(0, meal.time!));
  }
  // Two weeks of full days for the diary chart and table
  for (var daysAgo = 1; daysAgo <= 14; daysAgo++) {
    for (final meal in meals) {
      logMeal(meal, at(daysAgo, meal.time!));
    }
  }

  return plan;
}
