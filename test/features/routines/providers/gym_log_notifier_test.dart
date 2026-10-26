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

import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/features/routines/models/log.dart';
import 'package:wger/features/routines/models/repetition_unit.dart';
import 'package:wger/features/routines/models/weight_unit.dart';
import 'package:wger/features/routines/providers/gym_log_notifier.dart';

import '../../../../test_data/exercises.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer.test();
  });

  Log makeLog({
    String? id,
    int exerciseId = 1,
    int routineId = 100,
    num weight = 50,
    num repetitions = 10,
    DateTime? date,
  }) {
    return Log(
      id: id ?? 'log-1',
      exerciseId: exerciseId,
      routineId: routineId,
      weight: weight,
      repetitions: repetitions,
      date: date ?? DateTime.utc(2020, 1, 1),
    );
  }

  test('initial state is null', () {
    expect(container.read(gymLogProvider), isNull);
  });

  test('setLog accepts a log with no exercise, as read from the database', () {
    container.read(gymLogProvider.notifier).setLog(makeLog());

    final state = container.read(gymLogProvider)!;
    expect(state.exerciseId, 1);
    expect(state.exerciseObjOrNull, isNull);
  });

  test('setLog stores a copy with cleared id/sessionId and the current clock as date', () {
    final fixed = DateTime.utc(2026, 5, 1, 12);
    withClock(Clock.fixed(fixed), () {
      final source = makeLog(id: 'original-id', date: DateTime.utc(2020, 1, 1))
        ..sessionId = 'session-from-2020';

      container.read(gymLogProvider.notifier).setLog(source);

      final state = container.read(gymLogProvider)!;
      expect(state.exerciseId, source.exerciseId);
      expect(state.weight, source.weight);
      expect(state.date, fixed);
      // setLog must clear id AND sessionId: the source is a historical template,
      // the copy is a fresh entry that gets its own UUID from Drift on insert
      // and must land in today's session, not back on the template's old one.
      expect(state.id, isNull);
      expect(state.sessionId, isNull);
    });
  });

  group('copyValuesFrom', () {
    const kg = WeightUnit(id: 1, name: 'kg');
    const lbs = WeightUnit(id: 2, name: 'lbs');
    const reps = RepetitionUnit(id: 1, name: 'Repetitions');
    const seconds = RepetitionUnit(id: 3, name: 'Seconds');

    setUp(() {
      final current =
          Log(
              exerciseId: testBenchPress.id,
              routineId: 100,
              slotEntryId: 7,
              iteration: 5,
              weight: 80,
              weightTarget: 80,
              repetitions: 8,
              repetitionsTarget: 8,
              rir: 2,
              rirTarget: 2,
              date: DateTime.utc(2026, 10, 19),
            )
            ..exercise = testBenchPress
            ..weightUnit = kg
            ..repetitionUnit = reps;
      container.read(gymLogProvider.notifier).setLog(current);
    });

    test('takes the entered values, the set context stays the current one', () {
      final pastLog =
          Log(
              id: 'past',
              exerciseId: testBenchPress.id,
              routineId: 99,
              sessionId: 'past-session',
              slotEntryId: 3,
              iteration: 1,
              weight: 95,
              weightTarget: 90,
              repetitions: 7,
              repetitionsTarget: 6,
              rir: 1,
              rirTarget: 3,
            )
            ..weightUnit = lbs
            ..repetitionUnit = seconds;

      container.read(gymLogProvider.notifier).copyValuesFrom(pastLog);

      final state = container.read(gymLogProvider)!;
      expect(state.weight, 95);
      expect(state.weightUnitId, lbs.id);
      expect(state.weightUnitObj, lbs);
      expect(state.repetitions, 7);
      expect(state.repetitionsUnitId, seconds.id);
      expect(state.repetitionsUnitObj, seconds);
      expect(state.rir, 1);

      expect(state.id, isNull);
      expect(state.sessionId, isNull);
      expect(state.routineId, 100);
      expect(state.slotEntryId, 7);
      expect(state.iteration, 5);
      expect(state.weightTarget, 80);
      expect(state.repetitionsTarget, 8);
      expect(state.rirTarget, 2);
      expect(state.exerciseObj.id, testBenchPress.id);
    });

    test('clears values the past log left empty', () {
      final pastLog = Log(exerciseId: testBenchPress.id, repetitions: 12);

      container.read(gymLogProvider.notifier).copyValuesFrom(pastLog);

      final state = container.read(gymLogProvider)!;
      expect(state.repetitions, 12);
      expect(state.weight, isNull);
      expect(state.rir, isNull);
    });
  });

  group('mutating setters when state is set', () {
    setUp(() {
      container.read(gymLogProvider.notifier).setLog(makeLog());
    });

    test('setWeight updates only the weight', () {
      container.read(gymLogProvider.notifier).setWeight(99);

      final state = container.read(gymLogProvider)!;
      expect(state.weight, 99);
      expect(state.repetitions, 10);
    });

    test('setRepetitions updates only the repetitions', () {
      container.read(gymLogProvider.notifier).setRepetitions(7);

      final state = container.read(gymLogProvider)!;
      expect(state.repetitions, 7);
      expect(state.weight, 50);
    });

    test('setRepetitionUnit overwrites the unit object and id', () {
      const unit = RepetitionUnit(id: 5, name: 'Seconds');

      container.read(gymLogProvider.notifier).setRepetitionUnit(unit);

      final state = container.read(gymLogProvider)!;
      expect(state.repetitionsUnitObj?.id, 5);
      expect(state.repetitionsUnitId, 5);
    });

    test('setWeightUnit overwrites the unit object and id', () {
      const unit = WeightUnit(id: 7, name: 'lbs');

      container.read(gymLogProvider.notifier).setWeightUnit(unit);

      final state = container.read(gymLogProvider)!;
      expect(state.weightUnitObj?.id, 7);
      expect(state.weightUnitId, 7);
    });
  });

  group('setters are no-ops when state is null', () {
    test('copyValuesFrom on null state stays null', () {
      container.read(gymLogProvider.notifier).copyValuesFrom(makeLog());

      expect(container.read(gymLogProvider), isNull);
    });

    test('setWeight on null state stays null', () {
      container.read(gymLogProvider.notifier).setWeight(99);

      expect(container.read(gymLogProvider), isNull);
    });

    test('setRepetitions on null state stays null', () {
      container.read(gymLogProvider.notifier).setRepetitions(7);

      expect(container.read(gymLogProvider), isNull);
    });

    test('setRepetitionUnit on null state stays null', () {
      container
          .read(gymLogProvider.notifier)
          .setRepetitionUnit(
            const RepetitionUnit(id: 5, name: 'Seconds'),
          );

      expect(container.read(gymLogProvider), isNull);
    });

    test('setWeightUnit on null state stays null', () {
      container
          .read(gymLogProvider.notifier)
          .setWeightUnit(
            const WeightUnit(id: 7, name: 'lbs'),
          );

      expect(container.read(gymLogProvider), isNull);
    });
  });
}
