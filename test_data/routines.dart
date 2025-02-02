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

import 'package:flutter/material.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/base_config.dart';
import 'package:wger/models/workouts/day.dart';
import 'package:wger/models/workouts/day_data.dart';
import 'package:wger/models/workouts/log.dart';
import 'package:wger/models/workouts/repetition_unit.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/models/workouts/session.dart';
import 'package:wger/models/workouts/session_api.dart';
import 'package:wger/models/workouts/set_config_data.dart';
import 'package:wger/models/workouts/slot.dart';
import 'package:wger/models/workouts/slot_data.dart';
import 'package:wger/models/workouts/slot_entry.dart';
import 'package:wger/models/workouts/weight_unit.dart';

import './exercises.dart';

const testWeightUnit1 = WeightUnit(id: 1, name: 'kg');
const testWeightUnit2 = WeightUnit(id: 2, name: 'metric tonnes');
const testWeightUnits = [testWeightUnit1, testWeightUnit2];

const RepetitionUnit testRepetitionUnit1 = RepetitionUnit(id: 1, name: 'Repetitions');
const RepetitionUnit testRepetitionUnit2 = RepetitionUnit(id: 2, name: 'Hours');
const testRepetitionUnits = [testRepetitionUnit1, testRepetitionUnit2];

Routine getTestRoutine({List<Exercise>? exercises}) {
  final testExercises = exercises ?? getTestExercises();

  final log1 = Log.empty()
    ..id = 1
    ..iteration = 2
    ..slotEntryId = 3
    ..weight = 10
    ..rir = '1.5'
    ..date = DateTime(2021, 5, 1)
    ..repetitions = 10
    ..routineId = 1;
  log1.exerciseBase = testExercises[0];
  log1.weightUnit = testWeightUnit1;
  log1.repetitionUnit = testRepetitionUnit1;

  final log2 = Log.empty()
    ..id = 2
    ..iteration = 4
    ..slotEntryId = 1
    ..weight = 10
    ..rir = '2'
    ..date = DateTime(2021, 5, 1)
    ..repetitions = 12
    ..routineId = 1;
  log2.exerciseBase = testExercises[0];
  log2.weightUnit = testWeightUnit1;
  log2.repetitionUnit = testRepetitionUnit1;

  final log3 = Log.empty()
    ..id = 3
    ..iteration = 5
    ..slotEntryId = 1
    ..weight = 50
    ..rir = ''
    ..date = DateTime(2021, 5, 2)
    ..repetitions = 8
    ..routineId = 1;
  log3.exerciseBase = testExercises[1];
  log3.weightUnit = testWeightUnit1;
  log3.repetitionUnit = testRepetitionUnit1;

  final session1 = WorkoutSessionApi(
    session: WorkoutSession(
      id: 1,
      routineId: 1,
      date: DateTime(2021, 5, 1),
      impression: 3,
      notes: 'This is a note',
      timeStart: const TimeOfDay(hour: 10, minute: 0),
      timeEnd: const TimeOfDay(hour: 12, minute: 34),
    ),
    logs: [log1, log2],
  );

  final session2 = WorkoutSessionApi(
    session: WorkoutSession(
      id: 2,
      routineId: 1,
      date: DateTime(2021, 5, 2),
      impression: 1,
      notes: 'This is a note',
      timeStart: const TimeOfDay(hour: 6, minute: 12),
      timeEnd: const TimeOfDay(hour: 8, minute: 1),
    ),
    logs: [log3],
  );

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
    exercise: testExercises[0],
    nrOfSetsConfigs: [
      BaseConfig.firstIteration(4, 1),
    ],
    repetitionsConfigs: [
      BaseConfig.firstIteration(3, 1),
    ],
    weightConfigs: [
      BaseConfig.firstIteration(100, 1),
      BaseConfig(
        id: 1,
        slotEntryId: 1,
        iteration: 2,
        value: 5,
        operation: '+',
        step: 'abs',
        requirements: null,
        repeat: true,
      ),
    ],
  );

  final slotBenchPress = Slot.withData(
    id: 1,
    day: 1,
    order: 1,
    comment: 'Make sure to warm up',
  );
  slotBenchPress.addExerciseBase(testExercises[0]);
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
    exercise: testExercises[4],
    weightConfigs: [
      BaseConfig.firstIteration(80, 1),
    ],
    repetitionsConfigs: [
      BaseConfig.firstIteration(5, 1),
    ],
    nrOfSetsConfigs: [
      BaseConfig.firstIteration(3, 1),
    ],
  );

  final slotSquat = Slot.withData(id: 2, day: 1, order: 1);
  slotSquat.addExerciseBase(testExercises[4]);
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
    exercise: testExercises[5],
    nrOfSetsConfigs: [
      BaseConfig.firstIteration(4, 1),
    ],
    repetitionsConfigs: [
      BaseConfig.firstIteration(12, 1),
    ],
    weightConfigs: [
      BaseConfig.firstIteration(10, 1),
    ],
  );
  // settingSideRaises.weight = 6;

  final slotSideRaises = Slot.withData(id: 3, day: 1, order: 1);
  slotSideRaises.addExerciseBase(testExercises[5]);
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

  final List<DayData> dayDataDisplay = [
    DayData(
      iteration: 1,
      date: DateTime(2024, 11, 01),
      label: '',
      day: dayChestShoulders,
      slots: [
        SlotData(
          comment: 'Bench press',
          isSuperset: false,
          exerciseIds: [1],
          setConfigs: [
            SetConfigData(
              exerciseId: 1,
              exercise: testExercises[0],
              slotEntryId: 1,
              nrOfSets: 4,
              repetitions: 3,
              repetitionsUnit: testRepetitionUnit1,
              weight: 100,
              weightUnit: testWeightUnit1,
              restTime: 120,
              rir: '1.5',
              rpe: '8',
              textRepr: '4 sets 3x100kg',
            ),
          ],
        ),
        SlotData(
          comment: 'Side rises',
          isSuperset: false,
          exerciseIds: [6],
          setConfigs: [
            SetConfigData(
              exerciseId: 6,
              exercise: testExercises[5],
              slotEntryId: 1,
              nrOfSets: 4,
              repetitions: 12,
              repetitionsUnit: testRepetitionUnit1,
              weight: 10,
              weightUnit: testWeightUnit1,
              restTime: 60,
              rir: '',
              rpe: '',
              textRepr: '4 sets 12x10kg',
            ),
          ],
        ),
      ],
    ),
    DayData(
      iteration: 1,
      date: DateTime(2024, 11, 02),
      label: '',
      day: dayLegs,
      slots: [
        SlotData(
          comment: 'Squats',
          isSuperset: false,
          exerciseIds: [8],
          setConfigs: [
            SetConfigData(
              exerciseId: 8,
              exercise: testExercises[4],
              slotEntryId: 1,
              nrOfSets: 4,
              repetitions: 3,
              repetitionsUnit: testRepetitionUnit1,
              weight: 100,
              weightUnit: testWeightUnit1,
              restTime: 120,
              rir: '1.5',
              rpe: '8',
              textRepr: '4 sets 3x100kg',
            ),
          ],
        ),
      ],
    ),
    DayData(
      iteration: 1,
      date: DateTime(2024, 11, 02),
      label: 'null day (filled because of fitInWeek flag)',
      day: null,
      slots: [],
    ),
    DayData(
      iteration: 1,
      date: DateTime(2024, 11, 02),
      label: 'null day (filled because of fitInWeek flag)',
      day: null,
      slots: [],
    ),
  ];

  final routine = Routine(
    id: 1,
    created: DateTime(2021, 01, 01),
    name: '3 day workout',
    description: 'This is a 3 day workout and this text is important',
    start: DateTime(2024, 11, 01),
    end: DateTime(2024, 12, 01),
    days: [dayChestShoulders, dayLegs],
    sessions: [session1, session2],
    dayData: dayDataDisplay,
    dayDataCurrentIteration: [
      ...dayDataDisplay,
      DayData(
        iteration: 2,
        date: DateTime(2024, 11, 02),
        label: '',
        day: dayLegs,
        slots: [
          SlotData(
            comment: 'Squats',
            isSuperset: false,
            exerciseIds: [8],
            setConfigs: [
              SetConfigData(
                exerciseId: 8,
                exercise: testExercises[4],
                slotEntryId: 1,
                nrOfSets: 5,
                repetitions: 8,
                repetitionsUnit: testRepetitionUnit1,
                weight: 105,
                weightUnit: testWeightUnit1,
                restTime: 120,
                rir: '1',
                rpe: '9',
                textRepr: '5 sets 8x105kg',
              ),
            ],
          ),
        ],
      ),
    ],
    dayDataGym: [
      DayData(
        iteration: 1,
        date: DateTime(2024, 11, 01),
        label: '',
        day: dayChestShoulders,
        slots: [
          SlotData(
            comment: 'Make sure to warm up',
            isSuperset: false,
            exerciseIds: [testExercises[0].id!],
            setConfigs: [
              SetConfigData(
                exerciseId: 1,
                exercise: testExercises[0],
                slotEntryId: 1,
                nrOfSets: 1,
                repetitions: 3,
                repetitionsUnit: testRepetitionUnit1,
                weight: 100,
                weightUnit: testWeightUnit1,
                restTime: 120,
                rir: '1.5',
                rpe: '8',
                textRepr: '3x100kg',
              ),
              SetConfigData(
                exerciseId: testExercises[0].id!,
                exercise: testExercises[0],
                slotEntryId: 1,
                nrOfSets: 1,
                repetitions: 3,
                repetitionsUnit: testRepetitionUnit1,
                weight: 100,
                weightUnit: testWeightUnit1,
                restTime: 120,
                rir: '1.5',
                rpe: '8',
                textRepr: '3x100kg',
              ),
              SetConfigData(
                exerciseId: testExercises[0].id!,
                exercise: testExercises[0],
                slotEntryId: 1,
                nrOfSets: 1,
                repetitions: 3,
                repetitionsUnit: testRepetitionUnit1,
                weight: 100,
                weightUnit: testWeightUnit1,
                restTime: 120,
                rir: '1.5',
                rpe: '8',
                textRepr: '3x100kg',
              ),
            ],
          ),
          SlotData(
            comment: 'Side rises',
            isSuperset: false,
            exerciseIds: [testExercises[5].id!],
            setConfigs: [
              SetConfigData(
                exerciseId: testExercises[5].id!,
                exercise: testExercises[5],
                slotEntryId: 1,
                nrOfSets: 1,
                repetitions: 12,
                repetitionsUnit: testRepetitionUnit1,
                weight: 10,
                weightUnit: testWeightUnit1,
                restTime: 60,
                rir: '',
                rpe: '',
                textRepr: '12x10kg',
              ),
              SetConfigData(
                exerciseId: testExercises[5].id!,
                exercise: testExercises[5],
                slotEntryId: 1,
                nrOfSets: 1,
                repetitions: 12,
                repetitionsUnit: testRepetitionUnit1,
                weight: 10,
                weightUnit: testWeightUnit1,
                restTime: 60,
                rir: '',
                rpe: '',
                textRepr: '12x10kg',
              ),
              SetConfigData(
                exerciseId: testExercises[5].id!,
                exercise: testExercises[5],
                slotEntryId: 1,
                nrOfSets: 1,
                repetitions: 12,
                repetitionsUnit: testRepetitionUnit1,
                weight: 10,
                weightUnit: testWeightUnit1,
                restTime: 60,
                rir: '',
                rpe: '',
                textRepr: '12x10kg',
              ),
            ],
          ),
        ],
      ),
      DayData(
        iteration: 1,
        date: DateTime(2024, 11, 02),
        label: '',
        day: dayLegs,
        slots: [
          SlotData(
            comment: 'Squats',
            isSuperset: false,
            exerciseIds: [testExercises[4].id!],
            setConfigs: [
              SetConfigData(
                exerciseId: 8,
                exercise: testExercises[4],
                slotEntryId: 1,
                nrOfSets: 1,
                repetitions: 3,
                repetitionsUnit: testRepetitionUnit1,
                weight: 100,
                weightUnit: testWeightUnit1,
                restTime: 120,
                rir: '1.5',
                rpe: '8',
                textRepr: '3x100kg',
              ),
              SetConfigData(
                exerciseId: testExercises[4].id!,
                exercise: testExercises[4],
                slotEntryId: 1,
                nrOfSets: 1,
                repetitions: 3,
                repetitionsUnit: testRepetitionUnit1,
                weight: 100,
                weightUnit: testWeightUnit1,
                restTime: 120,
                rir: '1.5',
                rpe: '8',
                textRepr: '3x100kg',
              ),
              SetConfigData(
                exerciseId: testExercises[4].id!,
                exercise: testExercises[4],
                slotEntryId: 1,
                nrOfSets: 1,
                repetitions: 3,
                repetitionsUnit: testRepetitionUnit1,
                weight: 100,
                weightUnit: testWeightUnit1,
                restTime: 120,
                rir: '1.5',
                rpe: '8',
                textRepr: '3x100kg',
              ),
            ],
          ),
        ],
      ),
    ],
  );

  return routine;
}
