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
        expect(dateToYYYYMMDD(null), isNull);
      });

      test('should format DateTime to yyyy-MM-dd', () {
        final dateTime = DateTime(2022, 1, 30);
        expect(dateToYYYYMMDD(dateTime), '2022-01-30');
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

    group('dateToIso8601StringWithOffset', () {
      test('should return null for null input', () {
        expect(dateToIso8601StringWithOffset(null), isNull);
      });

      test('should format DateTime with positive offset', () {
        final dateTime = DateTime(2023, 6, 15, 14, 30).toLocal();
        final result = dateToIso8601StringWithOffset(dateTime);

        // Extract the date part and offset part
        final datePart = result!.substring(0, 19); // YYYY-MM-DDTHH:mm:ss
        final offsetPart = result.substring(19); // +HH:mm or -HH:mm

        expect(datePart, matches(RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}$')));
        expect(offsetPart, matches(RegExp(r'^[+-]\d{2}:\d{2}$')));
      });
    });

    group('iso8601StringToLocalDateTime', () {
      test('should parse UTC ISO string correctly', () {
        const input = '2023-06-15T14:30:00Z';
        final result = iso8601StringToLocalDateTime(input);

        expect(result, isA<DateTime>());
        expect(result.isUtc, isFalse); // Should be converted to local time
      });

      test('should parse ISO string with offset correctly', () {
        const input = '2023-06-15T14:30:00+02:00';
        final result = iso8601StringToLocalDateTime(input);

        expect(result, isA<DateTime>());
        expect(result.isUtc, isFalse);
      });
    });

    group('iso8601StringToLocalDateTimeNull', () {
      test('should return null for null input', () {
        expect(iso8601StringToLocalDateTimeNull(null), isNull);
      });

      test('should parse valid ISO string', () {
        const input = '2023-06-15T14:30:00Z';
        final result = iso8601StringToLocalDateTimeNull(input);

        expect(result, isA<DateTime>());
        expect(result!.isUtc, isFalse);
      });
    });
  });
}
