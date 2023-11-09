import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:wger/helpers/colors.dart';

void main() {
  group('test the color utility', () {
    test('3 items or less', () {
      final result = generateChartColors(2).iterator;
      expect(result.current, equals(const Color(0xFF2A4C7D)));
      result.moveNext();
      expect(result.current, equals(const Color(0xFFD45089)));
    });

    test('5 items or less', () {
      final result = generateChartColors(5).iterator;
      expect(result.current, equals(const Color(0xFF2A4C7D)));
      result.moveNext();
      expect(result.current, equals(const Color(0xFF825298)));
      result.moveNext();
      expect(result.current, equals(const Color(0xFFD45089)));
      result.moveNext();
      expect(result.current, equals(const Color(0xFFFF6A59)));
      result.moveNext();
      expect(result.current, equals(const Color(0xFFFFA600)));
    });

    test('8 items or more - last ones undefined', () {
      final result = generateChartColors(8).iterator;
      expect(result.current, equals(const Color(0xFF2A4C7D)));
      result.moveNext();
      expect(result.current, equals(const Color(0xFF5B5291)));
      result.moveNext();
      expect(result.current, equals(const Color(0xFF8E5298)));
      result.moveNext();
      expect(result.current, equals(const Color(0xFFBF5092)));
      result.moveNext();
      expect(result.current, equals(const Color(0xFFE7537E)));
      result.moveNext();
      expect(result.current, equals(const Color(0xFFFF6461)));
      result.moveNext();
      expect(result.current, equals(const Color(0xFFFF813D)));
      result.moveNext();
      expect(result.current, equals(const Color(0xFFFFA600)));
      result.moveNext();
      expect(result.current, isNull);
    });
  });
}
