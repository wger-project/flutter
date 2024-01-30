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

import '../../test_data/exercises.dart';
import '../../test_data/workouts.dart';

void main() {
  group('model tests', () {
    test('Test the filterLogsByExercise method', () {
      final workout = getWorkout();

      expect(workout.logs.length, 3);
      final logExercise1 = workout.filterLogsByExerciseBase(getTestExercises()[0]);
      expect(logExercise1.length, 2);
      expect(logExercise1[0].id, 1);
      expect(logExercise1[1].id, 2);

      final logExercise2 = workout.filterLogsByExerciseBase(getTestExercises()[1]);
      expect(logExercise2.length, 1);
      expect(logExercise2[0].id, 3);

      expect(workout.filterLogsByExerciseBase(getTestExercises()[2]).length, 0);
    });
  });
}
