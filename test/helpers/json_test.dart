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

    group('dateToIsoWithTimezone', () {
      test('should format DateTime to a string with timezone', () {
        expect(
          dateToUtcIso8601(DateTime.parse('2025-05-16T18:15:00+02:00')),
          '2025-05-16T16:15:00.000Z',
        );
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
