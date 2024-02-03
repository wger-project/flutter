import 'package:flutter_test/flutter_test.dart';
import 'package:wger/helpers/colors.dart';

void main() {
  group('generateChartColors', () {
    test('should generate 3 colors for 3 items', () {
      final colors = generateChartColors(3).toList();
      expect(colors, LIST_OF_COLORS3);
    });

    test('should generate 5 colors for 5 items', () {
      final colors = generateChartColors(5).toList();
      expect(colors, LIST_OF_COLORS5);
    });

    test('should generate 8 colors for 8 items', () {
      final colors = generateChartColors(8).toList();
      expect(colors, LIST_OF_COLORS8);
    });

    test('should generate 8 colors for more than 8 items', () {
      final colors = generateChartColors(10).toList();
      expect(colors, LIST_OF_COLORS8);
    });

    test('should generate 8 colors for 0 items', () {
      final colors = generateChartColors(0).toList();
      expect(colors, LIST_OF_COLORS3);
    });

    test('should generate 8 colors for negative items', () {
      final colors = generateChartColors(-5).toList();
      expect(colors, LIST_OF_COLORS3);
    });
  });
}
