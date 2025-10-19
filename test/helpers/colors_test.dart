/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) wger Team
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
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/helpers/colors.dart';

void main() {
  group('generateChartColors', () {
    test('should generate 3 colors for 3 items', () {
      final iterator = generateChartColors(3).iterator;
      final expectedColors = LIST_OF_COLORS3.iterator;

      while (expectedColors.moveNext()) {
        expect(iterator.moveNext(), isTrue);
        expect(iterator.current, equals(expectedColors.current));
      }

      expect(iterator.moveNext(), isTrue);
      expect(iterator.current, equals(Colors.black));
    });

    test('should generate 5 colors for 5 items', () {
      final iterator = generateChartColors(5).iterator;
      final expectedColors = LIST_OF_COLORS5.iterator;

      while (expectedColors.moveNext()) {
        expect(iterator.moveNext(), isTrue);
        expect(iterator.current, equals(expectedColors.current));
      }

      expect(iterator.moveNext(), isTrue);
      expect(iterator.current, equals(Colors.black));
    });

    test('should generate 8 colors for 8 items', () {
      final iterator = generateChartColors(8).iterator;
      final expectedColors = LIST_OF_COLORS8.iterator;

      while (expectedColors.moveNext()) {
        expect(iterator.moveNext(), isTrue);
        expect(iterator.current, equals(expectedColors.current));
      }

      expect(iterator.moveNext(), isTrue);
      expect(iterator.current, equals(Colors.black));
    });

    test('should generate surplus color for more than 8 items', () {
      final iterator = generateChartColors(10).iterator;
      final expectedColors = LIST_OF_COLORS8.iterator;

      while (expectedColors.moveNext()) {
        expect(iterator.moveNext(), isTrue);
        expect(iterator.current, equals(expectedColors.current));
      }

      // After exhausting the 8 colors, it should always return black
      for (int i = 0; i < 12; i++) {
        expect(iterator.moveNext(), isTrue);
        expect(iterator.current, equals(Colors.black));
      }
    });

    test('should generate 3 colors for 0 items', () {
      final iterator = generateChartColors(0).iterator;
      final expectedColors = LIST_OF_COLORS3.iterator;

      while (expectedColors.moveNext()) {
        expect(iterator.moveNext(), isTrue);
        expect(iterator.current, equals(expectedColors.current));
      }

      expect(iterator.moveNext(), isTrue);
      expect(iterator.current, equals(Colors.black));
    });

    test('should generate 3 colors for negative number of items', () {
      final iterator = generateChartColors(-5).iterator;
      final expectedColors = LIST_OF_COLORS3.iterator;

      while (expectedColors.moveNext()) {
        expect(iterator.moveNext(), isTrue);
        expect(iterator.current, equals(expectedColors.current));
      }

      expect(iterator.moveNext(), isTrue);
      expect(iterator.current, equals(Colors.black));
    });
  });
}
