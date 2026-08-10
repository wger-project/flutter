/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 - 2026 wger Team
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
import 'package:wger/core/date.dart';

void main() {
  group('daysInRange', () {
    test('covers both ends of the range', () {
      final days = daysInRange(DateTime(2026, 5, 4), DateTime(2026, 5, 7));

      expect(days.map((day) => day.day), [4, 5, 6, 7]);
      expect(days.every((day) => day.isUtc), isTrue);
    });

    test('a single day yields that day', () {
      expect(daysInRange(DateTime(2026, 5, 4), DateTime(2026, 5, 4)), [DateTime.utc(2026, 5, 4)]);
    });

    test('ignores the time of day of the bounds', () {
      final days = daysInRange(DateTime(2026, 5, 4, 23, 30), DateTime(2026, 5, 5, 0, 15));

      expect(days, [DateTime.utc(2026, 5, 4), DateTime.utc(2026, 5, 5)]);
    });

    test('keeps the last day across a daylight-saving switch', () {
      // Counting elapsed time instead of calendar days drops a day here: the
      // spring-forward day is 23 hours long, so the range came up one short
      // and the calendar silently lost the events of March 31st. Only bites
      // in a zone that observes DST (CI pins Europe/Berlin).
      final spring = daysInRange(DateTime(2026, 3, 1), DateTime(2026, 3, 31));

      expect(spring, hasLength(31));
      expect(spring.last, DateTime.utc(2026, 3, 31));
    });

    test('keeps the day count across the autumn switch', () {
      final autumn = daysInRange(DateTime(2026, 10, 1), DateTime(2026, 10, 31));

      expect(autumn, hasLength(31));
      expect(autumn.last, DateTime.utc(2026, 10, 31));
    });

    test('spans month and year boundaries', () {
      final days = daysInRange(DateTime(2026, 12, 30), DateTime(2027, 1, 2));

      expect(days, [
        DateTime.utc(2026, 12, 30),
        DateTime.utc(2026, 12, 31),
        DateTime.utc(2027, 1, 1),
        DateTime.utc(2027, 1, 2),
      ]);
    });
  });

  group('isSameDayAs', () {
    test('the time of day does not matter', () {
      expect(DateTime(2026, 5, 4, 8).isSameDayAs(DateTime(2026, 5, 4, 23, 59)), isTrue);
    });

    test('neighbouring days are not the same day', () {
      expect(DateTime(2026, 5, 4, 23, 59).isSameDayAs(DateTime(2026, 5, 5)), isFalse);
    });

    test('compares the calendar day each value carries, not the instant', () {
      // Dates read back through DateOnlyTextConverter are UTC midnight, while
      // the callers compare them against a local `now`
      expect(DateTime.utc(2026, 5, 4).isSameDayAs(DateTime(2026, 5, 4, 14)), isTrue);
    });
  });
}
