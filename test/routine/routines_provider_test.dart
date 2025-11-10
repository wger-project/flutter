/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2025 wger Team
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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/models/workouts/day.dart';
import 'package:wger/providers/routines.dart';

import '../../test_data/routines.dart';
import 'routines_provider_test.mocks.dart';

@GenerateMocks([RoutinesRepository])
void main() {
  late MockRoutinesRepository mockRepo;
  late Day testDay;

  setUp(() {
    mockRepo = MockRoutinesRepository();
    testDay = Day(
      id: 15,
      routineId: 101,
      name: 'Test Day',
      order: 7,
    );
  });

  group('test routine methods', () {
    test('fetchAllRoutinesSparse calls repository and updates state', () async {
      // Arrange
      final testRoutine = getTestRoutine();
      when(mockRepo.fetchAllRoutinesSparseServer()).thenAnswer((_) async => [testRoutine]);

      final container = ProviderContainer.test(
        overrides: [routinesRepositoryProvider.overrideWithValue(mockRepo)],
      );

      // Act
      final notifier = container.read(routinesRiverpodProvider.notifier);
      await notifier.fetchAllRoutinesSparse();

      // Assert
      verify(mockRepo.fetchAllRoutinesSparseServer()).called(1);
      final state = container.read(routinesRiverpodProvider);
      expect(state.routines.length, 1);
      expect(state.routines.first.id, testRoutine.id);
    });

    test('addRoutine calls repository and prepends created routine to state', () async {
      // Arrange
      final toAdd = getTestRoutine();
      final created = getTestRoutine();
      when(mockRepo.addRoutineServer(any)).thenAnswer((_) async => created);
      final container = ProviderContainer.test(
        overrides: [routinesRepositoryProvider.overrideWithValue(mockRepo)],
      );

      // Act
      final notifier = container.read(routinesRiverpodProvider.notifier);
      final result = await notifier.addRoutine(toAdd);

      // Assert
      verify(mockRepo.addRoutineServer(toAdd)).called(1);
      expect(result, created);
      final state = container.read(routinesRiverpodProvider);
      expect(state.routines.isNotEmpty, true);
      expect(state.routines.first, created);
    });

    test('editRoutine calls repository and replaces routine in state', () async {
      // Arrange
      final routine = getTestRoutine();
      when(mockRepo.editRoutineServer(routine)).thenAnswer((_) async => routine);

      final container = ProviderContainer.test(
        overrides: [routinesRepositoryProvider.overrideWithValue(mockRepo)],
      );
      container.read(routinesRiverpodProvider.notifier).state = RoutinesState(routines: [routine]);

      // Act
      final notifier = container.read(routinesRiverpodProvider.notifier);
      await notifier.editRoutine(routine);

      verify(mockRepo.editRoutineServer(routine)).called(1);
      final state = container.read(routinesRiverpodProvider);
      expect(state.routines.length, 1);
      expect(state.routines.first, routine);
    });

    test('deleteRoutine calls repository and removes routine from state', () async {
      // Arrange
      const routineId = 1;
      when(mockRepo.deleteRoutineServer(routineId)).thenAnswer((_) async => Future.value());

      final container = ProviderContainer.test(
        overrides: [routinesRepositoryProvider.overrideWithValue(mockRepo)],
      );
      container.read(routinesRiverpodProvider.notifier).state = RoutinesState(
        routines: [getTestRoutine()],
      );

      // Act
      final notifier = container.read(routinesRiverpodProvider.notifier);
      await notifier.deleteRoutine(routineId);

      // Assert
      verify(mockRepo.deleteRoutineServer(routineId)).called(1);
      final state = container.read(routinesRiverpodProvider);
      expect(state.routines.length, 0);
    });
  });

  group('test day methods', () {
    test('addDay calls repository and triggers fetchAndSetRoutineFull', () async {
      // Arrange
      when(mockRepo.addDayServer(any)).thenAnswer((_) async => testDay);
      when(mockRepo.fetchAndSetRoutineFullServer(any)).thenAnswer((_) async => getTestRoutine());
      final container = ProviderContainer.test(
        overrides: [routinesRepositoryProvider.overrideWithValue(mockRepo)],
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
        overrides: [routinesRepositoryProvider.overrideWithValue(mockRepo)],
      );

      // Act
      final notifier = container.read(routinesRiverpodProvider.notifier);
      await notifier.editDay(testDay);

      // Assert
      verify(mockRepo.editDayServer(testDay)).called(1);
      verify(mockRepo.fetchAndSetRoutineFullServer(testDay.routineId)).called(1);
    });

    test('editDays calls repository.editDayServer for each day', () async {
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

      final container = ProviderContainer.test(
        overrides: [routinesRepositoryProvider.overrideWithValue(mockRepo)],
      );

      // Act
      final notifier = container.read(routinesRiverpodProvider.notifier);
      await notifier.editDays([day1, day2]);

      // Assert
      verify(mockRepo.editDayServer(day1)).called(1);
      verify(mockRepo.editDayServer(day2)).called(1);
      verifyNever(mockRepo.fetchAndSetRoutineFullServer(any));
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
          overrides: [routinesRepositoryProvider.overrideWithValue(mockRepo)],
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
}
