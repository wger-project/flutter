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

import '../../../../test_data/routines.dart';

void main() {
  group('Routine model tests', () {
    test('correctly filters out null days', () {
      // Arrange: a rest day of the "fixed weekly schedule" carries no day
      final routine = getTestRoutine();
      final withDay = getTestRoutine().dayData[0];
      final withoutDay = getTestRoutine().dayData[0]..day = null;
      routine.dayData = [withDay, withoutDay];
      withDay.date = DateTime(2026, 1, 1);
      withoutDay.date = DateTime(2026, 1, 2);

      // Assert
      expect(routine.dayDataCurrentIteration.length, equals(2));
      expect(routine.dayDataCurrentIterationFiltered, [withDay]);
    });

    test('keeps the last entry of a day repeated by the weekly schedule', () {
      // Arrange: three entries for the same day, as the fixed weekly
      // schedule produces them
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
      expect(routine.dayDataCurrentIterationFiltered, [routine.dayData[2]]);
    });

    test('Test the filterLogsByExercise method', () {
      final routine = getTestRoutine();

      expect(routine.logs.length, 3);
      final logExercise1 = routine.filterLogsByExercise(1);
      expect(logExercise1.length, 2);
      expect(logExercise1[0].id, '1');
      expect(logExercise1[1].id, '2');

      final logExercise2 = routine.filterLogsByExercise(2);
      expect(logExercise2.length, 1);
      expect(logExercise2[0].id, '3');

      expect(routine.filterLogsByExercise(3).length, 0);
    });

    test('Test the groupLogsByRepetition method', () {
      final routine = getTestRoutine();

      expect(routine.logs.length, 3);
      final result = routine.groupLogsByRepetition();
      expect(result.keys, [10, 12, 8]);
      expect(result[8], [routine.logs[2]]);
      expect(result[10], [routine.logs[0]]);
      expect(result[12], [routine.logs[1]]);
    });
  });
}
