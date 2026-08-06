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

import 'package:flutter/material.dart';
import 'package:wger/features/exercises/models/exercise.dart';
import 'package:wger/features/routines/models/base_config.dart';
import 'package:wger/features/routines/models/day.dart';
import 'package:wger/features/routines/models/day_data.dart';
import 'package:wger/features/routines/models/log.dart';
import 'package:wger/features/routines/models/routine.dart';
import 'package:wger/features/routines/models/session.dart';
import 'package:wger/features/routines/models/set_config_data.dart';
import 'package:wger/features/routines/models/slot.dart';
import 'package:wger/features/routines/models/slot_data.dart';
import 'package:wger/features/routines/models/slot_entry.dart';

import '../routines.dart';
import 'exercises.dart';

/// A three day push/pull/legs routine, running relative to today, with a
/// completed push session for the gym mode summary. Built from the screenshot
/// exercises so names are localized and the muscle distribution is real.
Routine getScreenshotRoutine() {
  final exercises = getScreenshotExercises();
  final benchPress = exercises[0];
  final crunches = exercises[1];
  final deadLift = exercises[2];
  final curls = exercises[3];
  final squats = exercises[4];
  final raises = exercises[5];

  final today = DateTime.now();

  SlotEntry entry(
    int slotId,
    Exercise exercise, {
    required int sets,
    required int reps,
    required num weight,
  }) => SlotEntry(
    slotId: slotId,
    type: SlotEntryType.normal,
    order: 1,
    exerciseId: exercise.id,
    repetitionUnitId: 1,
    repetitionRounding: 1,
    weightUnitId: 1,
    weightRounding: 1.25,
    comment: '',
    repetitionUnit: testRepetitionUnit1,
    weightUnit: testWeightUnit1,
    exercise: exercise,
    nrOfSetsConfigs: [BaseConfig.firstIteration(sets, 1)],
    repetitionsConfigs: [BaseConfig.firstIteration(reps, 1)],
    weightConfigs: [BaseConfig.firstIteration(weight, 1)],
  );

  Slot slot(
    int id,
    int dayId,
    int order,
    Exercise exercise, {
    required int sets,
    required int reps,
    required num weight,
    String comment = '',
  }) {
    final slot = Slot.withData(id: id, day: dayId, order: order, comment: comment);
    slot.addExerciseBase(exercise);
    slot.entries.add(entry(id, exercise, sets: sets, reps: reps, weight: weight));
    return slot;
  }

  final dayPush = Day(
    id: 1,
    routineId: 1,
    name: 'Push day',
    description: 'Chest, shoulders and triceps',
    slots: [
      slot(1, 1, 1, benchPress, sets: 4, reps: 8, weight: 80, comment: 'Warm up properly first'),
      slot(2, 1, 2, raises, sets: 3, reps: 12, weight: 10),
    ],
  );
  final dayPull = Day(
    id: 2,
    routineId: 1,
    name: 'Pull day',
    description: 'Back and biceps',
    slots: [
      slot(3, 2, 1, deadLift, sets: 3, reps: 5, weight: 120),
      slot(4, 2, 2, curls, sets: 3, reps: 12, weight: 14),
    ],
  );
  final dayLegs = Day(
    id: 3,
    routineId: 1,
    name: 'Legs and core',
    description: 'Legs and abs',
    slots: [
      slot(5, 3, 1, squats, sets: 4, reps: 15, weight: 0),
      slot(6, 3, 2, crunches, sets: 3, reps: 20, weight: 0),
    ],
  );

  // One collapsed entry per exercise, the way the routine detail screen
  // shows a day
  SetConfigData displaySet(
    Exercise exercise, {
    required int sets,
    required int reps,
    num? weight,
    int? restTime,
    double? rir,
  }) => SetConfigData(
    exerciseId: exercise.id,
    exercise: exercise,
    slotEntryId: 1,
    nrOfSets: sets,
    repetitions: reps,
    repetitionsUnit: testRepetitionUnit1,
    weight: weight ?? 0,
    weightUnit: testWeightUnit1,
    restTime: restTime,
    rir: rir,
    rpe: null,
    textRepr: weight == null ? '$sets sets $reps reps' : '$sets sets ${reps}x${weight}kg',
  );

  // One entry per set, the way gym mode steps through a day
  SetConfigData gymSet(Exercise exercise, {required int reps, required num weight}) =>
      SetConfigData(
        exerciseId: exercise.id,
        exercise: exercise,
        slotEntryId: 1,
        nrOfSets: 1,
        repetitions: reps,
        repetitionsUnit: testRepetitionUnit1,
        weight: weight,
        weightUnit: testWeightUnit1,
        restTime: 120,
        rir: 2,
        rpe: null,
        textRepr: '${reps}x${weight}kg',
      );

  final dayData = [
    DayData(
      iteration: 1,
      date: today,
      label: '',
      day: dayPush,
      slots: [
        SlotData(
          comment: 'Warm up properly first',
          isSuperset: false,
          exerciseIds: [benchPress.id],
          setConfigs: [displaySet(benchPress, sets: 4, reps: 8, weight: 80, restTime: 120, rir: 2)],
        ),
        SlotData(
          comment: '',
          isSuperset: false,
          exerciseIds: [raises.id],
          setConfigs: [displaySet(raises, sets: 3, reps: 12, weight: 10, restTime: 60)],
        ),
      ],
    ),
    DayData(
      iteration: 1,
      date: today.add(const Duration(days: 2)),
      label: '',
      day: dayPull,
      slots: [
        SlotData(
          comment: 'Reset your form between the reps',
          isSuperset: false,
          exerciseIds: [deadLift.id],
          setConfigs: [displaySet(deadLift, sets: 3, reps: 5, weight: 120, restTime: 180, rir: 1)],
        ),
        SlotData(
          comment: '',
          isSuperset: false,
          exerciseIds: [curls.id],
          setConfigs: [displaySet(curls, sets: 3, reps: 12, weight: 14, restTime: 60)],
        ),
      ],
    ),
    DayData(
      iteration: 1,
      date: today.add(const Duration(days: 4)),
      label: '',
      day: dayLegs,
      slots: [
        SlotData(
          comment: 'Keep a steady pace and brace your core',
          isSuperset: false,
          exerciseIds: [squats.id],
          setConfigs: [displaySet(squats, sets: 4, reps: 15)],
        ),
        SlotData(
          comment: '',
          isSuperset: false,
          exerciseIds: [crunches.id],
          setConfigs: [displaySet(crunches, sets: 3, reps: 20)],
        ),
      ],
    ),
  ];

  final dayDataGym = [
    DayData(
      iteration: 1,
      date: today,
      label: '',
      day: dayPush,
      slots: [
        SlotData(
          comment: 'Warm up properly first',
          isSuperset: false,
          exerciseIds: [benchPress.id],
          setConfigs: [for (var i = 0; i < 4; i++) gymSet(benchPress, reps: 8, weight: 80)],
        ),
        SlotData(
          comment: '',
          isSuperset: false,
          exerciseIds: [raises.id],
          setConfigs: [for (var i = 0; i < 3; i++) gymSet(raises, reps: 12, weight: 10)],
        ),
      ],
    ),
  ];

  // The push session behind the gym mode summary: every planned set logged
  var logId = 0;
  Log log(Exercise exercise, {required num weight, required int reps, double? rir}) {
    final log = Log(
      id: 'screenshot-log-${logId++}',
      exerciseId: exercise.id,
      iteration: 1,
      slotEntryId: 1,
      weight: weight,
      rir: rir,
      date: today,
      repetitions: reps,
      routineId: 1,
    );
    log.exercise = exercise;
    log.weightUnit = testWeightUnit1;
    log.repetitionUnit = testRepetitionUnit1;
    return log;
  }

  final session = WorkoutSession(
    id: 'screenshot-session-1',
    routineId: 1,
    date: today,
    impression: WorkoutImpression.good,
    notes: 'Bench felt strong today',
    timeStart: const TimeOfDay(hour: 17, minute: 30),
    timeEnd: const TimeOfDay(hour: 18, minute: 42),
    logs: [
      log(benchPress, weight: 80, reps: 8, rir: 2),
      log(benchPress, weight: 80, reps: 8, rir: 2),
      log(benchPress, weight: 80, reps: 8, rir: 1.5),
      log(benchPress, weight: 80, reps: 8, rir: 1),
      log(raises, weight: 10, reps: 12, rir: 2),
      log(raises, weight: 10, reps: 12, rir: 2),
      log(raises, weight: 10, reps: 12, rir: 1),
    ],
  );

  return Routine(
    id: 1,
    created: today.subtract(const Duration(days: 42)),
    name: '3 day split',
    description:
        'Push, pull and legs across the week. Add weight as soon as you hit '
        'the top of the rep range on every set.',
    start: today.subtract(const Duration(days: 42)),
    end: today.add(const Duration(days: 42)),
    days: [dayPush, dayPull, dayLegs],
    sessions: [session],
    dayData: dayData,
    dayDataGym: dayDataGym,
    isHydrated: true,
  );
}
