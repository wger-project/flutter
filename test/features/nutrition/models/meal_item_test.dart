/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
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

import 'package:flutter_test/flutter_test.dart';
import 'package:wger/features/nutrition/models/ingredient_weight_unit.dart';
import 'package:wger/features/nutrition/models/meal_item.dart';

import '../../../../test_data/nutritional_plans.dart';

void main() {
  group('MealItem.nutritionalValues', () {
    test('without weight unit uses grams', () {
      final item = MealItem(ingredientId: 1, amount: 200);
      item.ingredient = ingredient1;
      // ingredient1: energy=500 per 100g, so 200g = 1000
      expect(item.nutritionalValues.energy, closeTo(1000, 0.01));
      expect(item.nutritionalValues.protein, closeTo(10, 0.01));
    });

    test('with weight unit', () {
      const unit = IngredientWeightUnit(
        id: 1,
        uuid: '00000000-0000-0000-0000-000000000001',
        ingredientId: 1,
        name: 'Serving',
        grams: 50,
      );
      final item = MealItem(ingredientId: 1, amount: 3);
      item.ingredient = ingredient1;
      item.weightUnitObj = unit;
      // 3 servings * 50g = 150g, energy = 500 * 150 / 100 = 750
      expect(item.nutritionalValues.energy, closeTo(750, 0.01));
      expect(item.nutritionalValues.protein, closeTo(7.5, 0.01));
    });

    test('with weight unit amount 1', () {
      const unit = IngredientWeightUnit(
        id: 2,
        uuid: '00000000-0000-0000-0000-000000000002',
        ingredientId: 1,
        name: 'Cup',
        grams: 240,
      );
      final item = MealItem(ingredientId: 1, amount: 1);
      item.ingredient = ingredient1;
      item.weightUnitObj = unit;
      // 1 * 240g, energy = 500 * 240 / 100 = 1200
      expect(item.nutritionalValues.energy, closeTo(1200, 0.01));
    });
  });
}
