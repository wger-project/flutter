/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
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

import '../../../test_data/routines.dart';

void main() {
  group('Routine model tests', () {
    test('correctly filters out null days', () {
      // Arrange
      final routine = getTestRoutine();
      routine.dayData = [
        getTestRoutine().dayData[0],
        getTestRoutine().dayData[0],
        getTestRoutine().dayData[0],
      ];
      routine.dayData[0].date = DateTime(2026, 1, 1);
      routine.dayData[1].date = DateTime(2026, 1, 2);
      routine.dayData[2].date = DateTime(2026, 1, 3);

      // Assert
      expect(routine.dayDataCurrentIteration.length, equals(3));
      expect(routine.dayDataCurrentIterationFiltered.length, equals(1));
    });
  });
}
