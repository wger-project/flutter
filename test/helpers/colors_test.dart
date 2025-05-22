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
