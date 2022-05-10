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
import 'package:wger/models/workouts/log.dart';

void main() {
  group('Test the workout log model', () {
    late Log log1;
    late Log log2;

    setUp(() {
      log1 = Log(
        id: 123,
        workoutPlan: 100,
        exerciseBaseId: 1,
        reps: 10,
        rir: '1.5',
        repetitionUnitId: 1,
        weight: 20,
        weightUnitId: 1,
        date: DateTime(2010, 10, 1),
      );
      log2 = Log(
        id: 9,
        workoutPlan: 42,
        exerciseBaseId: 1,
        reps: 10,
        rir: '1.5',
        repetitionUnitId: 1,
        weight: 20,
        weightUnitId: 1,
        date: DateTime(2063, 4, 5),
      );
    });

    test('Test equal values (besides Id, workoutPlan and date)', () async {
      expect(log1, log2);
    });

    test('Test different rir values', () async {
      log1.rir = null;
      expect(log1, isNot(log2));
    });

    test('Test different weight values', () async {
      log1.weight = 100;
      expect(log1, isNot(log2));
    });

    test('Test different weight units', () async {
      log1.weightUnitId = 2;
      expect(log1, isNot(log2));
    });

    test('Test different reps', () async {
      log1.reps = 99;
      expect(log1, isNot(log2));
    });

    test('Test different rep units', () async {
      log1.repetitionUnitId = 44;
      expect(log1, isNot(log2));
    });
  });
}
