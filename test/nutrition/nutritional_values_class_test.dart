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
import 'package:wger/models/nutrition/nutritional_values.dart';

void main() {
  var values1 = NutritionalValues();
  var values2 = NutritionalValues();
  var values3 = NutritionalValues();
  var values4 = NutritionalValues();

  group('Test the NutritionalValues class', () {
    setUp(() {
      values1 = NutritionalValues.values(4000, 30.5, 340.5, 11.7, 41.0, 31.75, 21.3, 33.3);
      values2 = NutritionalValues.values(4000, 30.5, 340.5, 11.7, 41.0, 31.75, 21.3, 33.3);
      values3 = NutritionalValues.values(5000, 30.5, 340.5, 11.7, 41.0, 31.75, 21.3, 33.3);
      values4 = NutritionalValues.values(1000, 10, 100, 1, 10.0, 10, 10, 10);
    });

    test('Test the equality operator', () {
      expect(values1, values2);
      expect(values1, isNot(equals(values3)));
    });

    test('Test the plus operator', () {
      final values5 = values1 + values4;
      final result = NutritionalValues.values(5000, 40.5, 440.5, 12.7, 51.0, 41.75, 31.3, 43.3);
      expect(values5, result);
    });

    test('Test the add method', () {
      values1.add(values4);
      final result = NutritionalValues.values(5000, 40.5, 440.5, 12.7, 51.0, 41.75, 31.3, 43.3);
      expect(values1, result);
    });
  });
}
