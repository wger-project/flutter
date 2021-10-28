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
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/models/nutrition/nutritrional_values.dart';

import '../test_data/nutritional_plans.dart';

void main() {
  late NutritionalPlan plan;

  setUp(() {
    plan = getNutritionalPlan();
  });

  group('model tests', () {
    test('Test the nutritionalValues method for nutritional plans', () {
      final values = NutritionalValues.values(4118.75, 32.75, 347.5, 9.5, 59.0, 37.75, 52.5, 30.5);
      expect(plan.nutritionalValues, values);
    });

    test('Test the nutritionalValues method for meals', () {
      final meal = plan.meals.first;
      final values = NutritionalValues.values(518.75, 5.75, 17.5, 3.5, 29.0, 13.75, 49.5, 0.5);
      expect(meal.nutritionalValues, values);
    });

    test('Test that the getter returns all meal items for a plan', () {
      expect(plan.allMealItems, plan.meals[0].mealItems + plan.meals[1].mealItems);
    });
  });
}
