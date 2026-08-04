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
import 'package:wger/core/formatting/formatting.dart';

void main() {
  group('hoursAndMinutes', () {
    test('splits the minutes into hours and minutes', () {
      expect(hoursAndMinutes(452, 'en'), '7:32');
    });

    test('pads the minutes so the values line up', () {
      expect(hoursAndMinutes(425, 'en'), '7:05');
    });

    test('keeps a duration below an hour in the same shape', () {
      expect(hoursAndMinutes(45, 'en'), '0:45');
    });

    test('rounds to whole minutes', () {
      expect(hoursAndMinutes(59.6, 'en'), '1:00');
    });

    test('keeps the sign of a negative change', () {
      expect(hoursAndMinutes(-95, 'en'), '-1:35');
    });

    test('takes the digits from the locale', () {
      expect(hoursAndMinutes(452, 'fa'), '۷:۳۲');
    });
  });

  group('durationAxis', () {
    test('leaves the ticks to the chart for every other unit', () {
      expect(durationAxis('kg', 60, 100), isNull);
    });

    test('puts every tick on a whole hour', () {
      final axis = durationAxis('min', 0, 300)!;

      expect(axis.interval, 60);
      expect(axis.min, 0);
      expect(axis.max, 300);
    });

    test('widens the interval until the ticks are few enough', () {
      expect(durationAxis('min', 0, 540)!.interval, 120);
    });

    test('keeps the bounds from cutting the values they were derived from', () {
      expect(durationAxis('min', 0, 540)!.max, greaterThanOrEqualTo(540));
    });

    test('starts at the hour below the data instead of at zero', () {
      expect(durationAxis('min', 385, 460)!.min, 360);
    });
  });

  group('measurementUnit', () {
    test('reads a duration in hours', () {
      expect(measurementUnit('min'), 'h');
    });

    test('leaves every other unit alone', () {
      expect(measurementUnit('kg'), 'kg');
    });
  });
}
