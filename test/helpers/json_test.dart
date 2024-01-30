import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/helpers/json.dart';

void main() {
  group('json file test cases', () {
    group('stringToNum', () {
      test('should return 0 for null input', () {
        expect(stringToNum(null), 0);
      });

      test('should parse string to num', () {
        expect(stringToNum('42'), 42);
      });

      test('should handle invalid input gracefully', () {
        expect(() => stringToNum('invalid'), throwsFormatException);
      });
    });

    group('numToString', () {
      test('should return null for null input', () {
        expect(numToString(null), isNull);
      });

      test('should convert num to string', () {
        expect(numToString(42), '42');
      });
    });

    group('toDate', () {
      test('should return null for null input', () {
        expect(toDate(null), isNull);
      });

      test('should format DateTime to yyyy-MM-dd', () {
        final dateTime = DateTime(2022, 1, 30);
        expect(toDate(dateTime), '2022-01-30');
      });
    });

    group('stringToTime', () {
      test('should default to 00:00 for null input', () {
        expect(stringToTime(null), const TimeOfDay(hour: 0, minute: 0));
      });

      test('should convert string to TimeOfDay', () {
        expect(stringToTime('12:34'), const TimeOfDay(hour: 12, minute: 34));
      });
    });

    group('timeToString', () {
      test('should return null for null input', () {
        expect(timeToString(null), isNull);
      });

      test('should format TimeOfDay to 24-hour format', () {
        const time = TimeOfDay(hour: 12, minute: 34);
        expect(timeToString(time), '12:34');
      });
    });
  });
}
