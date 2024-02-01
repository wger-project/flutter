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

import 'package:wger/models/exercises/exercise.dart';
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

const RepetitionUnit repetitionUnit1 = RepetitionUnit(id: 1, name: 'Repetitions');
const RepetitionUnit repetitionUnit2 = RepetitionUnit(id: 2, name: 'Hours');

WorkoutPlan getWorkout({List<Exercise>? exercises}) {
  final testBases = exercises ?? getTestExercises();

  final log1 = Log.empty()
    ..id = 1
    ..weight = 10
    ..rir = '1.5'
    ..date = DateTime(2021, 5, 1)
    ..reps = 10
    ..workoutPlan = 1;
  log1.exerciseBase = testBases[0];
  log1.weightUnit = weightUnit1;
  log1.repetitionUnit = repetitionUnit1;

  final log2 = Log.empty()
    ..id = 2
    ..weight = 10
    ..rir = '2'
    ..date = DateTime(2021, 5, 1)
    ..reps = 12
    ..workoutPlan = 1;
  log2.exerciseBase = testBases[0];
  log2.weightUnit = weightUnit1;
  log2.repetitionUnit = repetitionUnit1;

  final log3 = Log.empty()
    ..id = 3
    ..weight = 50
    ..rir = ''
    ..date = DateTime(2021, 5, 2)
    ..reps = 8
    ..workoutPlan = 1;
  log3.exerciseBase = testBases[1];
  log3.weightUnit = weightUnit1;
  log3.repetitionUnit = repetitionUnit1;

  final settingBenchPress = Setting(
    setId: 1,
    order: 1,
    exerciseId: 1,
    repetitionUnitId: 1,
    reps: 6,
    weightUnitId: 1,
    comment: 'ddd',
    rir: '3',
  );
  settingBenchPress.repetitionUnit = repetitionUnit1;
  settingBenchPress.weightUnit = weightUnit1;
  settingBenchPress.exercise = testBases[0];
  settingBenchPress.weight = 80;

  final setBenchPress = Set.withData(
    id: 1,
    day: 1,
    sets: 3,
    order: 1,
    comment: 'Make sure to warm up',
  );
  setBenchPress.addExerciseBase(testBases[0]);
  setBenchPress.settings.add(settingBenchPress);
  setBenchPress.settingsComputed = [settingBenchPress, settingBenchPress];

  final settingSquat = Setting(
    setId: 2,
    order: 1,
    exerciseId: 8,
    repetitionUnitId: 1,
    reps: 8,
    weightUnitId: 1,
    comment: 'ddd',
    rir: '2',
  );
  settingSquat.repetitionUnit = repetitionUnit1;
  settingSquat.weightUnit = weightUnit1;
  settingSquat.exercise = testBases[4];
  settingSquat.weight = 120;

  final setSquat = Set.withData(
    id: 2,
    day: 1,
    sets: 3,
    order: 1,
  );
  setSquat.addExerciseBase(testBases[4]);
  setSquat.settings.add(settingSquat);
  setSquat.settingsComputed = [settingSquat, settingSquat];

  final settingSideRaises = Setting(
    setId: 2,
    order: 1,
    exerciseId: 8,
    repetitionUnitId: 1,
    reps: 12,
    weightUnitId: 1,
    comment: 'ddd',
    rir: '',
  );
  settingSideRaises.repetitionUnit = repetitionUnit1;
  settingSideRaises.weightUnit = weightUnit1;
  settingSideRaises.exercise = testBases[5];
  settingSideRaises.weight = 6;

  final setSideRaises = Set.withData(
    id: 3,
    day: 1,
    sets: 3,
    order: 1,
  );
  setSideRaises.addExerciseBase(testBases[5]);
  setSideRaises.settings.add(settingSideRaises);
  setSideRaises.settingsComputed = [settingSideRaises, settingSideRaises];

  final dayChestShoulders = Day()
    ..id = 1
    ..workoutId = 1
    ..description = 'chest, shoulders'
    ..daysOfWeek = [1, 2];
  dayChestShoulders.sets.add(setBenchPress);
  dayChestShoulders.sets.add(setSideRaises);

  final dayLegs = Day()
    ..id = 2
    ..workoutId = 1
    ..description = 'legs'
    ..daysOfWeek = [4];
  dayLegs.sets.add(setSquat);

  final workout = WorkoutPlan(
    id: 1,
    creationDate: DateTime(2021, 01, 01),
    name: '3 day workout',
    days: [dayChestShoulders, dayLegs],
    logs: [log1, log2, log3],
  );

  return workout;
}
