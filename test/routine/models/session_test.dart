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
import 'package:wger/models/workouts/log.dart';
import 'package:wger/models/workouts/session.dart';

void main() {
  group('WorkoutSession.volume', () {
    test('sums metric volumes correctly', () {
      final session = WorkoutSession(routineId: 1);

      final a = Log(
        exerciseId: 1,
        routineId: 1,
        rir: null,
        date: DateTime.now(),
        weight: 100,
        weightUnitId: WEIGHT_UNIT_KG,
        repetitions: 3,
        repetitionsUnitId: REP_UNIT_REPETITIONS_ID,
      );

      final b = Log(
        exerciseId: 2,
        routineId: 1,
        rir: null,
        date: DateTime.now(),
        weight: 50,
        weightUnitId: WEIGHT_UNIT_KG,
        repetitions: 2,
        repetitionsUnitId: REP_UNIT_REPETITIONS_ID,
      );

      session.logs = [a, b];

      final vol = session.volume;
      expect(vol['metric'], equals(100 * 3 + 50 * 2));
      expect(vol['imperial'], equals(0));
    });

    test('sums imperial volumes correctly', () {
      final session = WorkoutSession(routineId: 1);

      final a = Log(
        exerciseId: 3,
        routineId: 1,
        rir: null,
        date: DateTime.now(),
        weight: 220,
        weightUnitId: WEIGHT_UNIT_LB,
        repetitions: 4,
        repetitionsUnitId: REP_UNIT_REPETITIONS_ID,
      );

      final b = Log(
        exerciseId: 4,
        routineId: 1,
        rir: null,
        date: DateTime.now(),
        weight: 150,
        weightUnitId: WEIGHT_UNIT_LB,
        repetitions: 1,
        repetitionsUnitId: REP_UNIT_REPETITIONS_ID,
      );

      session.logs = [a, b];

      final vol = session.volume;
      expect(vol['imperial'], equals(220 * 4 + 150 * 1));
      expect(vol['metric'], equals(0));
    });

    test('ignores logs with non-matching units or non-rep units', () {
      final session = WorkoutSession(routineId: 1);

      final a = Log(
        exerciseId: 5,
        routineId: 1,
        rir: null,
        date: DateTime.now(),
        weight: 100,
        weightUnitId: WEIGHT_UNIT_KG,
        repetitions: 5,
        repetitionsUnitId: REP_UNIT_REPETITIONS_ID,
      );

      final b = Log(
        exerciseId: 6,
        routineId: 1,
        rir: null,
        date: DateTime.now(),
        weight: 60,
        weightUnitId: WEIGHT_UNIT_LB, // different unit
        repetitions: 2,
        repetitionsUnitId: REP_UNIT_REPETITIONS_ID,
      );

      final c = Log(
        exerciseId: 7,
        routineId: 1,
        rir: null,
        date: DateTime.now(),
        weight: 30,
        weightUnitId: WEIGHT_UNIT_KG,
        repetitions: 20,
        repetitionsUnitId: 999, // some other repetition unit -> should be ignored
      );

      session.logs = [a, b, c];

      final vol = session.volume;
      // only 'a' should count for metric, only 'b' for imperial
      expect(vol['metric'], equals(100 * 5));
      expect(vol['imperial'], equals(60 * 2));
    });

    test('returns zero for empty logs', () {
      final session = WorkoutSession(routineId: 1);
      session.logs = [];

      final vol = session.volume;
      expect(vol['metric'], equals(0));
      expect(vol['imperial'], equals(0));
    });

    test('works with fractional weights and reps', () {
      final session = WorkoutSession(routineId: 1);

      final a = Log(
        exerciseId: 8,
        routineId: 1,
        rir: null,
        date: DateTime.now(),
        weight: 10.5,
        weightUnitId: WEIGHT_UNIT_KG,
        repetitions: 3,
        repetitionsUnitId: REP_UNIT_REPETITIONS_ID,
      );

      final b = Log(
        exerciseId: 9,
        routineId: 1,
        rir: null,
        date: DateTime.now(),
        weight: 5.25,
        weightUnitId: WEIGHT_UNIT_KG,
        repetitions: 2.5,
        repetitionsUnitId: REP_UNIT_REPETITIONS_ID,
      );

      session.logs = [a, b];

      final vol = session.volume;
      expect(vol['metric'], closeTo(10.5 * 3 + 5.25 * 2.5, 1e-9));
      expect(vol['imperial'], equals(0));
    });
  });
}
