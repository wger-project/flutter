/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020, 2025 wger Team
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
import 'package:wger/helpers/consts.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/log.dart';
import 'package:wger/models/workouts/set_config_data.dart';

void main() {
  group('Log.volume', () {
    test('returns weight * repetitions for metric (kg) and repetition unit', () {
      final log = Log(
        exerciseId: 1,
        routineId: 1,
        rir: null,
        date: DateTime.now(),
        weight: 100,
        weightUnitId: WEIGHT_UNIT_KG,
        repetitions: 5,
        repetitionsUnitId: REP_UNIT_REPETITIONS_ID,
      );

      expect(log.volume(metric: true), equals(500));
    });

    test('returns 0 when weight unit does not match metric flag', () {
      final log = Log(
        exerciseId: 2,
        routineId: 1,
        rir: null,
        date: DateTime.now(),
        weight: 100,
        weightUnitId: WEIGHT_UNIT_LB, // pounds
        repetitions: 5,
        repetitionsUnitId: REP_UNIT_REPETITIONS_ID,
      );

      // metric = true expects KG -> mismatch -> 0
      expect(log.volume(metric: true), equals(0));
    });

    test('returns weight * repetitions for imperial (lb) when metric=false', () {
      final log = Log(
        exerciseId: 3,
        routineId: 1,
        rir: null,
        date: DateTime.now(),
        weight: 220, // lb
        weightUnitId: WEIGHT_UNIT_LB,
        repetitions: 3,
        repetitionsUnitId: REP_UNIT_REPETITIONS_ID,
      );

      expect(log.volume(metric: false), equals(660));
    });

    test('returns 0 when repetitions unit is not repetitions', () {
      final log = Log(
        exerciseId: 4,
        routineId: 1,
        rir: null,
        date: DateTime.now(),
        weight: 50,
        weightUnitId: WEIGHT_UNIT_KG,
        repetitions: 10,
        repetitionsUnitId: 999, // some other unit id
      );

      expect(log.volume(metric: true), equals(0));
    });

    test('returns 0 when weight or repetitions are null', () {
      final a = Log(
        exerciseId: 5,
        routineId: 1,
        rir: null,
        date: DateTime.now(),
        weight: null,
        weightUnitId: WEIGHT_UNIT_KG,
        repetitions: 5,
        repetitionsUnitId: REP_UNIT_REPETITIONS_ID,
      );

      final b = Log(
        exerciseId: 6,
        routineId: 1,
        rir: null,
        date: DateTime.now(),
        weight: 50,
        weightUnitId: WEIGHT_UNIT_KG,
        repetitions: null,
        repetitionsUnitId: REP_UNIT_REPETITIONS_ID,
      );

      expect(a.volume(metric: true), equals(0));
      expect(b.volume(metric: true), equals(0));
    });

    test('works with non-integer (num) weight and repetitions', () {
      final log = Log(
        exerciseId: 7,
        routineId: 1,
        rir: null,
        date: DateTime.now(),
        weight: 10.5,
        weightUnitId: WEIGHT_UNIT_KG,
        repetitions: 3,
        repetitionsUnitId: REP_UNIT_REPETITIONS_ID,
      );

      expect(log.volume(metric: true), closeTo(31.5, 0.0001));
    });
  });

  group('Log.fromSetConfigData', () {
    late Exercise exercise;

    setUp(() {
      exercise = Exercise(id: 1);
    });

    test('uses default unit IDs when unit objects are not loaded', () {
      // Reproduces: "Repetitions unit must be present if repetitions have a value"
      //
      // When the user taps "+" in gym mode to add an extra exercise,
      // addExerciseAfterPage() creates a SetConfigData with only exerciseId and
      // slotEntryId — no unit objects. The default constructor sets
      // weightUnitId=WEIGHT_UNIT_KG and repetitionsUnitId=REP_UNIT_REPETITIONS_ID,
      // but Log.fromSetConfigData was using the object setters which overwrite
      // those IDs with null when the objects are null, causing the server to
      // reject the request with a 400 ValidationError.
      final setConfig = SetConfigData(
        exerciseId: 1,
        slotEntryId: 1,
        exercise: exercise,
        // no weightUnit or repetitionsUnit objects — mirrors addExerciseAfterPage()
      );

      final log = Log.fromSetConfigData(setConfig);

      expect(log.weightUnitId, WEIGHT_UNIT_KG);
      expect(log.repetitionsUnitId, REP_UNIT_REPETITIONS_ID);
    });

    test('uses custom unit IDs from SetConfigData when set', () {
      final setConfig = SetConfigData(
        exerciseId: 1,
        slotEntryId: 1,
        exercise: exercise,
        weightUnitId: WEIGHT_UNIT_LB,
        repetitionsUnitId: REP_UNIT_TILL_FAILURE_ID,
      );

      final log = Log.fromSetConfigData(setConfig);

      expect(log.weightUnitId, WEIGHT_UNIT_LB);
      expect(log.repetitionsUnitId, REP_UNIT_TILL_FAILURE_ID);
    });

    test('copies weight and repetitions values', () {
      final setConfig = SetConfigData(
        exerciseId: 1,
        slotEntryId: 1,
        exercise: exercise,
        weight: 80,
        repetitions: 12,
        rir: 2,
      );

      final log = Log.fromSetConfigData(setConfig);

      expect(log.weight, 80);
      expect(log.weightTarget, 80);
      expect(log.repetitions, 12);
      expect(log.repetitionsTarget, 12);
      expect(log.rir, 2);
      expect(log.rirTarget, 2);
    });
  });
}
