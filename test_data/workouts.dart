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

import 'package:wger/models/workouts/day.dart';
import 'package:wger/models/workouts/log.dart';
import 'package:wger/models/workouts/repetition_unit.dart';
import 'package:wger/models/workouts/set.dart';
import 'package:wger/models/workouts/setting.dart';
import 'package:wger/models/workouts/weight_unit.dart';
import 'package:wger/models/workouts/workout_plan.dart';

import './exercises.dart';

const weightUnit1 = WeightUnit(id: 1, name: 'kg');
const weightUnit2 = WeightUnit(id: 2, name: 'metric tonnes');

const RepetitionUnit repetitionUnit1 =
    RepetitionUnit(id: 1, name: 'Repetitions');
const RepetitionUnit repetitionUnit2 = RepetitionUnit(id: 2, name: 'Hours');

WorkoutPlan getWorkout() {
  var setting1 = Setting(
    setId: 1,
    order: 1,
    exerciseId: 1,
    repetitionUnitId: 1,
    reps: 2,
    weightUnitId: 1,
    comment: 'ddd',
    rir: '2',
  );
  setting1.repetitionUnit = repetitionUnit1;
  setting1.weightUnit = weightUnit1;
  setting1.exercise = exercise1;
  setting1.weight = 10;

  var log1 = Log.empty()
    ..id = 1
    ..weight = 10
    ..rir = '1.5'
    ..date = DateTime(2021, 5, 1)
    ..reps = 10
    ..workoutPlan = 1;
  log1.exercise = exercise1;
  log1.weightUnit = weightUnit1;
  log1.repetitionUnit = repetitionUnit1;

  var log2 = Log.empty()
    ..id = 2
    ..weight = 10
    ..rir = '2'
    ..date = DateTime(2021, 5, 1)
    ..reps = 12
    ..workoutPlan = 1;
  log2.exercise = exercise1;
  log2.weightUnit = weightUnit1;
  log2.repetitionUnit = repetitionUnit1;

  var log3 = Log.empty()
    ..id = 3
    ..weight = 50
    ..rir = ''
    ..date = DateTime(2021, 5, 2)
    ..reps = 8
    ..workoutPlan = 1;
  log3.exercise = exercise2;
  log3.weightUnit = weightUnit1;
  log3.repetitionUnit = repetitionUnit1;

  var set1 = Set.withData(
    id: 1,
    day: 1,
    sets: 3,
    order: 1,
  );
  set1.addExercise(exercise1);
  set1.settings.add(setting1);
  set1.settingsComputed = [setting1, setting1];

  var day1 = Day()
    ..id = 1
    ..workoutId = 1
    ..description = 'test day 1'
    ..daysOfWeek = [1, 2];
  day1.sets.add(set1);

  var day2 = Day()
    ..id = 2
    ..workoutId = 1
    ..description = 'test day 2'
    ..daysOfWeek = [4];

  var workout = WorkoutPlan(
      id: 1,
      creationDate: DateTime(2021, 01, 01),
      name: 'test workout 1',
      days: [day1, day2],
      logs: [log1, log2, log3]);

  return workout;
}
