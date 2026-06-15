/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2026 wger Team
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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/day.dart';
import 'package:wger/models/workouts/log.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/models/workouts/session.dart';
import 'package:wger/models/workouts/slot.dart';
import 'package:wger/models/workouts/slot_entry.dart';
import 'package:wger/providers/exercises_notifier.dart';
import 'package:wger/providers/routines_notifier.dart';
import 'package:wger/providers/routines_repository.dart';

import '../../test_data/exercises.dart';
import '../../test_data/routines.dart';
import '../fake_connectivity.dart';
import 'helpers/routine_form_test_overrides.dart';
import 'routines_provider_test.mocks.dart';

@GenerateMocks([RoutinesRepository])
void main() {
  late MockRoutinesRepository mockRepo;
  late MockWorkoutSessionRepository mockSessionRepo;
  late MockExerciseRepository mockExerciseRepo;
  late Day testDay;

  installFakeConnectivity();

  setUp(() {
    mockRepo = MockRoutinesRepository();
    when(mockRepo.watchAllDrift()).thenAnswer((_) => Stream.value(const <Routine>[]));
    // Mock repos for the two reference-data notifiers `fetchAndSetRoutineFull`
    // awaits, kept locally so individual tests can re-stub them with
    // specific session/exercise data.
    mockSessionRepo = MockWorkoutSessionRepository();
    when(
      mockSessionRepo.watchAllDrift(),
    ).thenAnswer((_) => Stream.value(const <WorkoutSession>[]));
    mockExerciseRepo = MockExerciseRepository();
    when(
      mockExerciseRepo.watchAllDrift(),
    ).thenAnswer((_) => Stream.value(const ExerciseState(<Exercise>[])));
    testDay = Day(
      id: 15,
      routineId: 101,
      name: 'Test Day',
      order: 7,
    );
  });

  /// Overrides for the providers `RoutinesRiverpod.build()` listens to so
  /// they don't reach for the real PowerSync DB.
  List<Override> ambientOverrides() => routineFormAmbientOverrides(
    exercise: mockExerciseRepo,
    session: mockSessionRepo,
    repetitionUnits: testRepetitionUnits,
    weightUnits: testWeightUnits,
  );

  group('test routine methods', () {
    test('addRoutine calls repository (creation still goes via REST)', () async {
      // Arrange
      final toAdd = getTestRoutine();
      final created = getTestRoutine();
      when(mockRepo.addRoutineServer(any)).thenAnswer((_) async => created);
      final container = ProviderContainer.test(
        overrides: [
          routinesRepositoryProvider.overrideWithValue(mockRepo),
          ...ambientOverrides(),
        ],
      );

      // Act
      final notifier = container.read(routinesRiverpodProvider.notifier);
      final result = await notifier.addRoutine(toAdd);

      // Assert
      verify(mockRepo.addRoutineServer(toAdd)).called(1);
      expect(result, created);
    });
  });

  group('test day methods', () {
    test('addDay calls repository and triggers fetchAndSetRoutineFull', () async {
      // Arrange
      when(mockRepo.addDayServer(any)).thenAnswer((_) async => testDay);
      when(mockRepo.fetchAndSetRoutineFullServer(any)).thenAnswer((_) async => getTestRoutine());
      final container = ProviderContainer.test(
        overrides: [
          routinesRepositoryProvider.overrideWithValue(mockRepo),
          ...ambientOverrides(),
        ],
      );

      // Act
      final notifier = container.read(routinesRiverpodProvider.notifier);
      final result = await notifier.addDay(testDay);

      // Assert
      verify(mockRepo.addDayServer(testDay)).called(1);
      verify(mockRepo.fetchAndSetRoutineFullServer(any)).called(1);
      expect(result, testDay);
    });

    test('editDay calls repository and triggers fetchAndSetRoutineFull', () async {
      // Arrange
      when(mockRepo.editDayServer(testDay)).thenAnswer((_) async => Future.value());
      when(
        mockRepo.fetchAndSetRoutineFullServer(testDay.routineId),
      ).thenAnswer((_) async => getTestRoutine());

      final container = ProviderContainer.test(
        overrides: [
          routinesRepositoryProvider.overrideWithValue(mockRepo),
          ...ambientOverrides(),
        ],
      );

      // Act
      final notifier = container.read(routinesRiverpodProvider.notifier);
      await notifier.editDay(testDay);

      // Assert
      verify(mockRepo.editDayServer(testDay)).called(1);
      verify(mockRepo.fetchAndSetRoutineFullServer(testDay.routineId)).called(1);
    });

    test('editDays calls repository.editDayServer for each day and refreshes once', () async {
      // Arrange
      final day1 = Day(
        id: 20,
        routineId: 101,
        name: 'Edited Day 1',
        order: 1,
      );
      final day2 = Day(
        id: 21,
        routineId: 101,
        name: 'Edited Day 2',
        order: 2,
      );
      when(mockRepo.editDayServer(any)).thenAnswer((_) async => Future.value());
      when(mockRepo.fetchAndSetRoutineFullServer(any)).thenAnswer((_) async => getTestRoutine());

      final container = ProviderContainer.test(
        overrides: [
          routinesRepositoryProvider.overrideWithValue(mockRepo),
          ...ambientOverrides(),
        ],
      );

      // Act
      final notifier = container.read(routinesRiverpodProvider.notifier);
      await notifier.editDays([day1, day2]);

      // Assert
      verify(mockRepo.editDayServer(day1)).called(1);
      verify(mockRepo.editDayServer(day2)).called(1);
      // dayData/dayDataGym are server-computed, so we must refresh once after
      // the batch, not once per edit.
      verify(mockRepo.fetchAndSetRoutineFullServer(101)).called(1);
    });

    test(
      'deleteDay calls repository.deleteDayServer and triggers fetchAndSetRoutineFull',
      () async {
        // Arrange
        final dayId = testDay.id!;
        final routineId = testDay.routineId;
        when(mockRepo.deleteDayServer(dayId)).thenAnswer((_) async => Future.value());
        when(
          mockRepo.fetchAndSetRoutineFullServer(routineId),
        ).thenAnswer((_) async => getTestRoutine());

        final container = ProviderContainer.test(
          overrides: [
            routinesRepositoryProvider.overrideWithValue(mockRepo),
            ...ambientOverrides(),
          ],
        );

        // Act
        final notifier = container.read(routinesRiverpodProvider.notifier);
        await notifier.deleteDay(dayId, routineId);

        // Assert
        verify(mockRepo.deleteDayServer(dayId)).called(1);
        verify(mockRepo.fetchAndSetRoutineFullServer(routineId)).called(1);
      },
    );
  });

  group('hydration via fetchAndSetRoutineFull', () {
    // The provider's `_hydrateRoutine` walks four data paths to attach
    // exercise + unit references to objects.

    /// Builds a barebones SlotEntry
    SlotEntry barebonesEntry({
      int exerciseId = 1,
      int repetitionUnitId = 1,
      int weightUnitId = 1,
    }) => SlotEntry(
      id: 1,
      slotId: 1,
      exerciseId: exerciseId,
      repetitionUnitId: repetitionUnitId,
      repetitionRounding: 1,
      weightUnitId: weightUnitId,
      weightRounding: 1.25,
    );

    Routine routineWithEntry(SlotEntry entry) {
      final slot = Slot.withData(id: 1, day: 1, order: 1, comment: '');
      slot.entries.add(entry);
      final day = Day(id: 1, routineId: 101, name: 'Test', order: 1)..slots = [slot];
      return Routine(id: 101, name: 'Test routine')..days = [day];
    }

    void overrideStreams(MockExerciseRepository exerciseRepo) {
      when(exerciseRepo.watchAllDrift()).thenAnswer(
        (_) => Stream.value(ExerciseState(getTestExercises())),
      );
    }

    test('attaches exerciseObj + unit objs on slot entries', () async {
      // Arrange
      overrideStreams(mockExerciseRepo);
      final entry = barebonesEntry();
      final routine = routineWithEntry(entry);
      when(mockRepo.fetchAndSetRoutineFullServer(101)).thenAnswer((_) async => routine);

      final container = ProviderContainer.test(
        overrides: [
          routinesRepositoryProvider.overrideWithValue(mockRepo),
          ...ambientOverrides(),
        ],
      );

      // Act
      final notifier = container.read(routinesRiverpodProvider.notifier);
      final result = await notifier.fetchAndSetRoutineFull(101);

      // Assert
      final hydrated = result.days[0].slots[0].entries[0];
      expect(hydrated.exerciseObj.id, getTestExercises()[0].id);
      expect(hydrated.repetitionUnitObj, testRepetitionUnit1);
      expect(hydrated.weightUnitObj, testWeightUnit1);
    });

    test('leaves entry.repetitionUnitObj null when the unit is not in the cache', () async {
      // Arrange
      overrideStreams(mockExerciseRepo);
      // Use a unit id that doesn't exist in `testRepetitionUnits`.
      final entry = barebonesEntry(repetitionUnitId: 9999);
      final routine = routineWithEntry(entry);
      when(mockRepo.fetchAndSetRoutineFullServer(101)).thenAnswer((_) async => routine);

      final container = ProviderContainer.test(
        overrides: [
          routinesRepositoryProvider.overrideWithValue(mockRepo),
          ...ambientOverrides(),
        ],
      );

      // Act
      final notifier = container.read(routinesRiverpodProvider.notifier);
      final result = await notifier.fetchAndSetRoutineFull(101);

      // Assert: the missing unit doesn't crash hydration; the field
      // ends up as null (graceful fallback).
      final hydrated = result.days[0].slots[0].entries[0];
      expect(hydrated.repetitionUnitObj, isNull);
      // The other refs stay intact.
      expect(hydrated.weightUnitObj, testWeightUnit1);
    });

    test('attaches sessions and hydrates log.exerciseObj', () async {
      // Arrange
      overrideStreams(mockExerciseRepo);
      // Stub the session repo to emit one session whose log references
      // exercise id 1.
      final log = Log(
        id: 'log-1',
        exerciseId: 1,
        routineId: 101,
        sessionId: 'session-1',
        repetitions: 10,
        weight: 50,
      );
      final session = WorkoutSession(
        id: 'session-1',
        routineId: 101,
        date: DateTime(2025, 1, 1),
        logs: [log],
      );
      when(
        mockSessionRepo.watchAllDrift(),
      ).thenAnswer((_) => Stream.value([session]));

      final routine = Routine(id: 101, name: 'Test routine');
      when(mockRepo.fetchAndSetRoutineFullServer(101)).thenAnswer((_) async => routine);

      final container = ProviderContainer.test(
        overrides: [
          routinesRepositoryProvider.overrideWithValue(mockRepo),
          ...ambientOverrides(),
        ],
      );

      // Act
      final notifier = container.read(routinesRiverpodProvider.notifier);
      final result = await notifier.fetchAndSetRoutineFull(101);

      // Assert
      expect(result.sessions, hasLength(1));
      expect(result.sessions[0].logs[0].exerciseObj.id, getTestExercises()[0].id);
    });

    test('concurrent calls share one server roundtrip', () async {
      // Arrange
      when(
        mockRepo.fetchAndSetRoutineFullServer(101),
      ).thenAnswer((_) async => Routine(id: 101, name: 'Test routine'));
      final container = ProviderContainer.test(
        overrides: [
          routinesRepositoryProvider.overrideWithValue(mockRepo),
          ...ambientOverrides(),
        ],
      );

      // Act: fire two calls before the first settles.
      final notifier = container.read(routinesRiverpodProvider.notifier);
      await Future.wait([
        notifier.fetchAndSetRoutineFull(101),
        notifier.fetchAndSetRoutineFull(101),
      ]);

      // Assert: `_fullFetchInFlight` collapses them into a single roundtrip.
      verify(mockRepo.fetchAndSetRoutineFullServer(101)).called(1);
    });
  });

  group('routineHydration family', () {
    test('watching the provider triggers a single structure fetch', () async {
      // Arrange
      when(
        mockRepo.fetchAndSetRoutineFullServer(101),
      ).thenAnswer((_) async => Routine(id: 101, name: 'Test routine'));
      final container = ProviderContainer.test(
        overrides: [
          routinesRepositoryProvider.overrideWithValue(mockRepo),
          ...ambientOverrides(),
        ],
      );

      // Act
      container.listen(routineHydrationProvider(101), (_, _) {});
      await container.read(routineHydrationProvider(101).future);

      // Assert
      verify(mockRepo.fetchAndSetRoutineFullServer(101)).called(1);
    });

    test('concurrent watchers of the same routine share one fetch', () async {
      // Arrange
      when(
        mockRepo.fetchAndSetRoutineFullServer(101),
      ).thenAnswer((_) async => Routine(id: 101, name: 'Test routine'));
      final container = ProviderContainer.test(
        overrides: [
          routinesRepositoryProvider.overrideWithValue(mockRepo),
          ...ambientOverrides(),
        ],
      );

      // Act: two readers of the same family instance.
      container.listen(routineHydrationProvider(101), (_, _) {});
      await Future.wait([
        container.read(routineHydrationProvider(101).future),
        container.read(routineHydrationProvider(101).future),
      ]);

      // Assert: a single shared roundtrip, not one per reader.
      verify(mockRepo.fetchAndSetRoutineFullServer(101)).called(1);
    });
  });
}
