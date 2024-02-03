import 'package:flutter_test/flutter_test.dart';
import 'package:wger/helpers/colors.dart';

void main() {
  group('generateChartColors', () {
    test('should generate 3 colors for 3 items using iterator', () {
      final iterator = generateChartColors(3).iterator;
      final expectedColors = LIST_OF_COLORS3.iterator;

      while (iterator.moveNext() && expectedColors.moveNext()) {
        expect(iterator.current, equals(expectedColors.current));
      }

      expect(iterator.moveNext(), isFalse);
      expect(expectedColors.moveNext(), isFalse);
    });

    test('should generate 5 colors for 5 items using iterator', () {
      final iterator = generateChartColors(5).iterator;
      final expectedColors = LIST_OF_COLORS5.iterator;

      while (iterator.moveNext() && expectedColors.moveNext()) {
        expect(iterator.current, equals(expectedColors.current));
      }

      expect(iterator.moveNext(), isFalse);
      expect(expectedColors.moveNext(), isFalse);
    });

    test('should generate 8 colors for 8 items using iterator', () {
      final iterator = generateChartColors(8).iterator;
      final expectedColors = LIST_OF_COLORS8.iterator;

      while (iterator.moveNext() && expectedColors.moveNext()) {
        expect(iterator.current, equals(expectedColors.current));
      }

      expect(iterator.moveNext(), isFalse);
      expect(expectedColors.moveNext(), isFalse);
    });

    test('should generate 8 colors for more than 8 items using iterator', () {
      final iterator = generateChartColors(10).iterator;
      final expectedColors = LIST_OF_COLORS8.iterator;

      while (iterator.moveNext() && expectedColors.moveNext()) {
        expect(iterator.current, equals(expectedColors.current));
      }

      expect(iterator.moveNext(), isFalse);
      expect(expectedColors.moveNext(), isFalse);
    });

    test('should generate 8 colors for 0 items using iterator', () {
      final iterator = generateChartColors(0).iterator;
      final expectedColors = LIST_OF_COLORS3.iterator;

      while (iterator.moveNext() && expectedColors.moveNext()) {
        expect(iterator.current, equals(expectedColors.current));
      }

      expect(iterator.moveNext(), isFalse);
      expect(expectedColors.moveNext(), isFalse);
    });

    test('should generate 8 colors for negative items using iterator', () {
      final iterator = generateChartColors(-5).iterator;
      final expectedColors = LIST_OF_COLORS3.iterator;

      while (iterator.moveNext() && expectedColors.moveNext()) {
        expect(iterator.current, equals(expectedColors.current));
      }

      expect(iterator.moveNext(), isFalse);
      expect(expectedColors.moveNext(), isFalse);
    });
  });
}
