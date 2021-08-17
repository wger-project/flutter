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
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/models/nutrition/log.dart';
import 'package:wger/models/nutrition/meal.dart';
import 'package:wger/models/nutrition/meal_item.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';

final ingredient1 = Ingredient(
  id: 1,
  name: 'Water',
  creationDate: DateTime(2021, 5, 1),
  energy: 500,
  carbohydrates: 10,
  carbohydratesSugar: 2,
  protein: 1,
  fat: 2,
  fatSaturated: 1,
  fibres: 1,
  sodium: 0,
);
final ingredient2 = Ingredient(
  id: 2,
  name: 'Burger soup',
  creationDate: DateTime(2021, 5, 10),
  energy: 25,
  carbohydrates: 10,
  carbohydratesSugar: 2,
  protein: 1,
  fat: 12,
  fatSaturated: 9,
  fibres: 50,
  sodium: 0,
);
final ingredient3 = Ingredient(
  id: 3,
  name: 'Broccoli cake',
  creationDate: DateTime(2021, 5, 2),
  energy: 1200,
  carbohydrates: 110,
  carbohydratesSugar: 2,
  protein: 9,
  fat: 10,
  fatSaturated: 8,
  fibres: 1,
  sodium: 10,
);

NutritionalPlan getNutritionalPlan() {
  final mealItem1 = MealItem(
    ingredientId: 1,
    amount: 100,
  );
  mealItem1.ingredientObj = ingredient1;

  final mealItem2 = MealItem(
    ingredientId: 2,
    amount: 75,
  );
  mealItem2.ingredientObj = ingredient2;

  final mealItem3 = MealItem(
    ingredientId: 3,
    amount: 300,
  );
  mealItem3.ingredientObj = ingredient3;

  final meal1 = Meal(
    id: 1,
    plan: 1,
    time: TimeOfDay(hour: 17, minute: 0),
  );
  meal1.mealItems = [mealItem1, mealItem2];

  final meal2 = Meal(
    id: 2,
    plan: 1,
    time: TimeOfDay(hour: 22, minute: 5),
  );
  meal2.mealItems = [mealItem3];

  final NutritionalPlan plan = NutritionalPlan(
    id: 1,
    description: 'lots and lots of mass',
    creationDate: DateTime(2021, 5, 23),
  );
  plan.meals = [meal1, meal2];

  // Add logs
  plan.logs.add(Log.fromMealItem(mealItem1, 1, DateTime(2021, 6, 1)));
  plan.logs.add(Log.fromMealItem(mealItem2, 1, DateTime(2021, 6, 2)));
  plan.logs.add(Log.fromMealItem(mealItem3, 1, DateTime(2021, 6, 3)));

  return plan;
}
