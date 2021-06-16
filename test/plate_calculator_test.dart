/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
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

import 'package:flutter_test/flutter_test.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/gym_mode.dart';

void main() {
  group('Test the plate calculator', () {
    test('Regular weights', () async {
      expect(plateCalculator(40, BAR_WEIGHT, AVAILABLE_PLATES), [10]);
      expect(plateCalculator(100, BAR_WEIGHT, AVAILABLE_PLATES), [15, 15, 10]);
      expect(plateCalculator(102.5, BAR_WEIGHT, AVAILABLE_PLATES), [15, 15, 10, 1.25]);
      expect(plateCalculator(140, BAR_WEIGHT, AVAILABLE_PLATES), [15, 15, 15, 15]);
      expect(plateCalculator(45, BAR_WEIGHT, AVAILABLE_PLATES), [10, 2.5]);
      expect(plateCalculator(85, BAR_WEIGHT, AVAILABLE_PLATES), [15, 15, 2.5]);
    });

    test('Exceptions', () async {
      expect(
        plateCalculator(10, BAR_WEIGHT, AVAILABLE_PLATES),
        [],
        reason: 'Weight is less than the bar',
      );

      expect(
        plateCalculator(101, BAR_WEIGHT, AVAILABLE_PLATES),
        [],
        reason: 'Weight cant be achieved with plates',
      );
    });
  });

  group('Test the plate calculator group', () {
    test('Test groups', () async {
      expect(groupPlates([15, 15, 15, 10, 10, 5]), {15: 3, 10: 2, 5: 1});
      expect(groupPlates([15, 10, 5, 1.25]), {15: 1, 10: 1, 5: 1, 1.25: 1});
      expect(groupPlates([10, 10, 10, 10, 10, 10, 10]), {10: 7});
    });
  });
}
