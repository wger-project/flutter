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

import 'package:flutter_test/flutter_test.dart';
import 'package:wger/models/nutrition/ingredient_weight_unit.dart';
import 'package:wger/models/nutrition/meal_item.dart';
import 'package:wger/models/nutrition/nutritional_goals.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/models/nutrition/nutritional_values.dart';

import '../../test_data/nutritional_plans.dart';

void main() {
  late NutritionalPlan plan;

  setUp(() {
    plan = getNutritionalPlan();
  });

  group('model tests', () {
    test('Test NutritionalPlan.nutritionalGoals based on meals', () {
      expect(
        plan.nutritionalGoals,
        NutritionalGoals(
          energy: 4118.75,
          protein: 32.75,
          carbohydrates: 347.5,
          carbohydratesSugar: 9.5,
          fat: 59.0,
          fatSaturated: 37.75,
          fiber: 52.5,
          sodium: 30.5,
        ),
      );
    });
    test('Test NutritionalPlan.nutritionalValues based on 3 macros and energy', () {
      expect(
        NutritionalPlan(
          description: '3 macros and energy defined',
          creationDate: DateTime(2024, 5, 4),
          startDate: DateTime(2024, 5, 4),
          goalProtein: 150,
          goalCarbohydrates: 100,
          goalFat: 100,
          goalEnergy: 1500,
        ).nutritionalGoals,
        NutritionalGoals(
          energy: 1500,
          protein: 150,
          carbohydrates: 100,
          fat: 100,
        ),
      );
    });
    test('Test NutritionalPlan.nutritionalValues based on 2 macros and energy', () {
      expect(
        NutritionalPlan(
          description: '2 macros and energy defined',
          creationDate: DateTime(2024, 5, 4),
          startDate: DateTime(2024, 5, 4),
          goalProtein: 100,
          goalCarbohydrates: 100,
          goalEnergy: 1700,
        ).nutritionalGoals,
        NutritionalGoals(
          energy: 1700,
          protein: 100,
          carbohydrates: 100,
          fat: 100, // inferred
        ),
      );
    });
    test('Test NutritionalPlan.nutritionalValues based on 3 macros only', () {
      expect(
        NutritionalPlan(
          description: '3 macros defined',
          creationDate: DateTime(2024, 5, 4),
          startDate: DateTime(2024, 5, 4),
          goalProtein: 100,
          goalCarbohydrates: 100,
          goalFat: 10,
        ).nutritionalGoals,
        NutritionalGoals(
          energy: 890, // inferred
          protein: 100,
          carbohydrates: 100,
          fat: 10,
        ),
      );
    });

    test('Test the nutritionalValues method for meals', () {
      final meal = plan.meals.first;
      final values = NutritionalValues.values(518.75, 5.75, 17.5, 3.5, 29.0, 13.75, 49.5, 0.5);
      expect(meal.plannedNutritionalValues, values);
    });

    test('Test that the getter returns all meal items for a plan', () {
      expect(plan.dedupMealItems, plan.meals[0].mealItems + plan.meals[1].mealItems);
    });
  });

  group('weight unit tests', () {
    test('MealItem nutritionalValues without weight unit uses grams', () {
      final item = MealItem(ingredientId: 1, amount: 200);
      item.ingredient = ingredient1;
      // ingredient1: energy=500 per 100g, so 200g = 1000
      expect(item.nutritionalValues.energy, closeTo(1000, 0.01));
      expect(item.nutritionalValues.protein, closeTo(10, 0.01));
    });

    test('MealItem nutritionalValues with weight unit', () {
      final unit = const IngredientWeightUnit(id: 1, name: 'Serving', grams: 50);
      final item = MealItem(ingredientId: 1, amount: 3);
      item.ingredient = ingredient1;
      item.weightUnitObj = unit;
      // 3 servings * 50g = 150g, energy = 500 * 150 / 100 = 750
      expect(item.nutritionalValues.energy, closeTo(750, 0.01));
      expect(item.nutritionalValues.protein, closeTo(7.5, 0.01));
    });

    test('MealItem nutritionalValues with weight unit amount 1', () {
      final unit = const IngredientWeightUnit(id: 2, name: 'Cup', grams: 240);
      final item = MealItem(ingredientId: 1, amount: 1);
      item.ingredient = ingredient1;
      item.weightUnitObj = unit;
      // 1 * 240g, energy = 500 * 240 / 100 = 1200
      expect(item.nutritionalValues.energy, closeTo(1200, 0.01));
    });
  });
}
