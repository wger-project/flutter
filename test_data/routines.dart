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
import 'package:wger/models/workouts/base_config.dart';
import 'package:wger/models/workouts/day.dart';
import 'package:wger/models/workouts/day_data.dart';
import 'package:wger/models/workouts/log.dart';
import 'package:wger/models/workouts/repetition_unit.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/models/workouts/slot.dart';
import 'package:wger/models/workouts/slot_data.dart';
import 'package:wger/models/workouts/slot_entry.dart';
import 'package:wger/models/workouts/weight_unit.dart';

import './exercises.dart';

const testWeightUnit1 = WeightUnit(id: 1, name: 'kg');
const testWeightUnit2 = WeightUnit(id: 2, name: 'metric tonnes');

const RepetitionUnit testRepetitionUnit1 = RepetitionUnit(id: 1, name: 'Repetitions');
const RepetitionUnit testRepetitionUnit2 = RepetitionUnit(id: 2, name: 'Hours');

Routine getRoutine({List<Exercise>? exercises}) {
  final testExercise = exercises ?? getTestExercises();

  final log1 = Log.empty()
    ..id = 1
    ..weight = 10
    ..rir = '1.5'
    ..date = DateTime(2021, 5, 1)
    ..reps = 10
    ..routineId = 1;
  log1.exerciseBase = testExercise[0];
  log1.weightUnit = testWeightUnit1;
  log1.repetitionUnit = testRepetitionUnit1;

  final log2 = Log.empty()
    ..id = 2
    ..weight = 10
    ..rir = '2'
    ..date = DateTime(2021, 5, 1)
    ..reps = 12
    ..routineId = 1;
  log2.exerciseBase = testExercise[0];
  log2.weightUnit = testWeightUnit1;
  log2.repetitionUnit = testRepetitionUnit1;

  final log3 = Log.empty()
    ..id = 3
    ..weight = 50
    ..rir = ''
    ..date = DateTime(2021, 5, 2)
    ..reps = 8
    ..routineId = 1;
  log3.exerciseBase = testExercise[1];
  log3.weightUnit = testWeightUnit1;
  log3.repetitionUnit = testRepetitionUnit1;

  final slotEntryBenchPress = SlotEntry(
    slotId: 1,
    type: 'normal',
    order: 1,
    exerciseId: 1,
    repetitionUnitId: 1,
    repetitionRounding: 1,
    weightUnitId: 1,
    weightRounding: 1.25,
    comment: 'ddd',
    repetitionUnit: testRepetitionUnit1,
    weightUnit: testWeightUnit1,
    exercise: testExercise[0],
    weightConfigs: [
      BaseConfig.firstIteration(100, 1),
      BaseConfig(
        id: 1,
        slotEntryId: 1,
        iteration: 2,
        value: 5,
        operation: '+',
        step: 'abs',
        needLogToApply: false,
        requirements: null,
        repeat: true,
      ),
    ],
    repsConfigs: [
      BaseConfig.firstIteration(3, 1),
    ],
    nrOfSetsConfigs: [
      BaseConfig.firstIteration(4, 1),
    ],
  );

  final slotBenchPress = Slot.withData(
    id: 1,
    day: 1,
    order: 1,
    comment: 'Make sure to warm up',
  );
  slotBenchPress.addExerciseBase(testExercise[0]);
  slotBenchPress.entries.add(slotEntryBenchPress);

  final slotEntrySquat = SlotEntry(
    slotId: 2,
    type: 'normal',
    order: 1,
    exerciseId: 8,
    repetitionUnitId: 1,
    repetitionRounding: 0.25,
    weightUnitId: 1,
    weightRounding: 0.25,
    comment: 'ddd',
    repetitionUnit: testRepetitionUnit1,
    weightUnit: testWeightUnit1,
    exercise: testExercise[4],
    weightConfigs: [
      BaseConfig.firstIteration(80, 1),
    ],
    repsConfigs: [
      BaseConfig.firstIteration(5, 1),
    ],
    nrOfSetsConfigs: [
      BaseConfig.firstIteration(3, 1),
    ],
  );

  final slotSquat = Slot.withData(id: 2, day: 1, order: 1);
  slotSquat.addExerciseBase(testExercise[4]);
  slotSquat.entries.add(slotEntrySquat);

  final slotEntrySideRaises = SlotEntry(
    slotId: 2,
    type: 'normal',
    order: 1,
    exerciseId: 8,
    repetitionUnitId: 1,
    repetitionRounding: 0.25,
    weightUnitId: 1,
    weightRounding: 0.25,
    comment: 'ddd',
    repetitionUnit: testRepetitionUnit1,
    weightUnit: testWeightUnit1,
    exercise: testExercise[5],
    weightConfigs: [
      BaseConfig.firstIteration(10, 1),
    ],
    repsConfigs: [
      BaseConfig.firstIteration(12, 1),
    ],
    nrOfSetsConfigs: [
      BaseConfig.firstIteration(4, 1),
    ],
  );
  // settingSideRaises.weight = 6;

  final slotSideRaises = Slot.withData(id: 3, day: 1, order: 1);
  slotSideRaises.addExerciseBase(testExercise[5]);
  slotSideRaises.entries.add(slotEntrySideRaises);

  final dayChestShoulders = Day(
    id: 1,
    routineId: 1,
    name: 'first day',
    description: 'chest, shoulders',
    slots: [slotBenchPress, slotSideRaises],
  );

  final dayLegs = Day(
    id: 2,
    routineId: 1,
    name: 'second day',
    description: 'legs',
    slots: [slotSquat],
  );

  final routine = Routine(
      id: 1,
      created: DateTime(2021, 01, 01),
      name: '3 day workout',
      start: DateTime(2024, 11, 01),
      end: DateTime(2024, 12, 01),
      days: [
        dayChestShoulders,
        dayLegs
      ],
      logs: [
        log1,
        log2,
        log3
      ],
      dayDataCurrentIteration: [
        DayData(
          iteration: 1,
          date: DateTime(2024, 11, 01),
          label: '',
          day: dayChestShoulders,
          slots: [
            SlotData(
              comment: 'foo',
              isSuperset: false,
              exerciseIds: [1],
              setConfigs: [
                // SetConfigData(
                //   reps: 10,
                //   weight: 10,
                //   rir: '1.5',
                // ),
              ],
            )
          ],
        ),
        DayData(
          iteration: 1,
          date: DateTime(2024, 11, 02),
          label: '',
          day: dayLegs,
          slots: [
            SlotData(
              comment: 'foo',
              isSuperset: false,
              exerciseIds: [8],
              setConfigs: [
                // SetConfigData(
                //   reps: 8,
                //   weight: 50,
                //   rir: '',
                // ),
              ],
            )
          ],
        ),
      ]);

  return routine;
}
