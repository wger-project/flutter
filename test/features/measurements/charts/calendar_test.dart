/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 wger Team
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
import 'package:wger/features/measurements/charts/calendar.dart';

void main() {
  group('dayOf', () {
    test('takes the calendar day, whatever the time on it', () {
      expect(dayOf(DateTime(2026, 5, 4, 23, 59, 59)), DateTime(2026, 5, 4));
      expect(dayOf(DateTime(2026, 5, 4)), DateTime(2026, 5, 4));
    });
  });

  group('shiftDays', () {
    test('walks the calendar, forwards and backwards', () {
      expect(shiftDays(DateTime(2026, 5, 4), 3), DateTime(2026, 5, 7));
      expect(shiftDays(DateTime(2026, 5, 4), -3), DateTime(2026, 5, 1));
      expect(shiftDays(DateTime(2026, 5, 4), 0), DateTime(2026, 5, 4));
    });

    test('crosses month and year boundaries', () {
      expect(shiftDays(DateTime(2026, 5, 31), 1), DateTime(2026, 6, 1));
      expect(shiftDays(DateTime(2026, 1, 1), -1), DateTime(2025, 12, 31));
      expect(shiftDays(DateTime(2024, 2, 28), 1), DateTime(2024, 2, 29));
    });

    test('drops the time of the day it starts from', () {
      expect(shiftDays(DateTime(2026, 5, 4, 18, 30), 1), DateTime(2026, 5, 5));
    });

    test('a shifted day is that many days away, also over a DST switch', () {
      // The point of shifting through the components: on a machine in a DST
      // zone, adding 24 hours lands at 23:00 of the day before
      for (final day in [
        DateTime(2026, 3, 29),
        DateTime(2026, 10, 25),
        DateTime(2026, 5, 4),
      ]) {
        expect(daysBetween(day, shiftDays(day, 1)), 1, reason: '$day');
        expect(daysBetween(day, shiftDays(day, -1)), -1, reason: '$day');
        expect(daysBetween(day, shiftDays(day, 7)), 7, reason: '$day');
      }
    });
  });

  group('weekStart', () {
    test('every day of a week points at its Monday', () {
      // 4 May 2026 is a Monday
      for (var offset = 0; offset < 7; offset++) {
        expect(weekStart(shiftDays(DateTime(2026, 5, 4), offset)), DateTime(2026, 5, 4));
      }
    });

    test('a Sunday belongs to the week that started six days earlier', () {
      expect(weekStart(DateTime(2026, 5, 10)), DateTime(2026, 5, 4));
    });

    test('the week of a month boundary starts in the month before', () {
      expect(weekStart(DateTime(2026, 6, 2)), DateTime(2026, 6, 1));
      expect(weekStart(DateTime(2026, 1, 1)), DateTime(2025, 12, 29));
    });
  });

  group('daysBetween', () {
    test('counts whole days, in both directions', () {
      expect(daysBetween(DateTime(2026, 5, 4), DateTime(2026, 5, 7)), 3);
      expect(daysBetween(DateTime(2026, 5, 7), DateTime(2026, 5, 4)), -3);
      expect(daysBetween(DateTime(2026, 5, 4), DateTime(2026, 5, 4)), 0);
    });

    test('the time of day does not count as part of a day', () {
      expect(daysBetween(DateTime(2026, 5, 4, 23, 30), DateTime(2026, 5, 5, 0, 30)), 1);
      expect(daysBetween(DateTime(2026, 5, 4, 0, 30), DateTime(2026, 5, 4, 23, 30)), 0);
    });

    test('a 23 and a 25 hour day each count as one', () {
      // The zone the machine runs in decides whether these are short or long;
      // counted in UTC they are one day either way
      expect(daysBetween(DateTime(2026, 3, 28), DateTime(2026, 3, 29)), 1);
      expect(daysBetween(DateTime(2026, 10, 24), DateTime(2026, 10, 25)), 1);
    });

    test('a year of days is a year of days', () {
      expect(daysBetween(DateTime(2025, 1, 1), DateTime(2026, 1, 1)), 365);
      expect(daysBetween(DateTime(2024, 1, 1), DateTime(2025, 1, 1)), 366);
    });
  });
}
