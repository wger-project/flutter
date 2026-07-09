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
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/features/routines/models/log.dart';
import 'package:wger/features/routines/providers/workout_logs_notifier.dart';
import 'package:wger/features/routines/providers/workout_logs_repository.dart';

import 'workout_logs_notifier_test.mocks.dart';

@GenerateMocks([WorkoutLogRepository])
void main() {
  late MockWorkoutLogRepository mockRepo;
  late ProviderContainer container;

  setUp(() {
    mockRepo = MockWorkoutLogRepository();
    container = ProviderContainer.test(
      overrides: [workoutLogRepositoryProvider.overrideWithValue(mockRepo)],
    );
  });

  Log makeLog({
    num repetitions = 10,
    int repetitionsUnitId = 1,
    num weight = 50,
    int weightUnitId = 1,
    DateTime? date,
  }) {
    return Log(
      exerciseId: 1,
      routineId: 100,
      repetitions: repetitions,
      repetitionsUnitId: repetitionsUnitId,
      weight: weight,
      weightUnitId: weightUnitId,
      date: date ?? DateTime.utc(2026, 4, 15),
    );
  }

  void stubLogs(List<Log> logs) {
    when(
      mockRepo.watchLogsByExerciseDrift(
        routineId: anyNamed('routineId'),
        exerciseId: anyNamed('exerciseId'),
        since: anyNamed('since'),
      ),
    ).thenAnswer((_) => Stream.value(logs));
  }

  Future<List<Log>> readLogs({int? weeksBack, bool distinct = true}) {
    final provider = pastExerciseLogsProvider(
      routineId: 100,
      exerciseId: 1,
      weeksBack: weeksBack,
      distinct: distinct,
    );
    // Keep the autoDispose provider alive until the stream emitted
    container.listen(provider, (_, _) {});

    return container.read(provider.future);
  }

  group('pastExerciseLogs scope', () {
    test('limits the logs to the routine when no scope is set', () async {
      stubLogs([]);

      await readLogs();

      verify(
        mockRepo.watchLogsByExerciseDrift(routineId: 100, exerciseId: 1, since: null),
      ).called(1);
    });

    test('drops the routine and cuts off at the given week when a scope is set', () async {
      stubLogs([]);
      final now = DateTime(2026, 4, 15, 12);

      await withClock(Clock.fixed(now), () => readLogs(weeksBack: 8));

      verify(
        mockRepo.watchLogsByExerciseDrift(
          routineId: null,
          exerciseId: 1,
          since: now.subtract(const Duration(days: 56)),
        ),
      ).called(1);
    });
  });

  group('pastExerciseLogs deduplication', () {
    test('keeps the newest log of each repetitions/weight combination', () async {
      final newest = makeLog(date: DateTime.utc(2026, 4, 16));
      stubLogs([
        newest,
        makeLog(date: DateTime.utc(2026, 4, 15)),
        makeLog(weight: 60, date: DateTime.utc(2026, 4, 14)),
      ]);

      final logs = await readLogs();

      expect(logs, hasLength(2));
      expect(logs.first.date, newest.date);
      expect(logs.map((l) => l.weight).toList(), [50, 60]);
    });

    test('keeps logs that only differ in their units', () async {
      stubLogs([
        makeLog(),
        makeLog(repetitionsUnitId: 2),
        makeLog(weightUnitId: 2),
      ]);

      expect(await readLogs(), hasLength(3));
    });

    test('returns every log when disabled', () async {
      stubLogs([makeLog(), makeLog(), makeLog()]);

      expect(await readLogs(distinct: false), hasLength(3));
    });
  });
}
