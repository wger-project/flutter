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

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/models/exercises/muscle.dart';
import 'package:wger/providers/exercise_filters_notifier.dart';
import 'package:wger/providers/exercise_repository.dart';
import 'package:wger/providers/exercises_notifier.dart';

import '../../test_data/exercises.dart';
import 'exercise_filters_notifier_test.mocks.dart';

@GenerateMocks([ExerciseRepository])
void main() {
  final exercises = [
    testBenchPress,
    testCrunches,
    testDeadLift,
    testCurls,
    testSquats,
    testSideRaises,
  ];
  const categories = [testCategoryArms, testCategoryLegs, testCategoryAbs, testCategoryShoulders];
  const equipment = [testEquipmentBench, testEquipmentDumbbell];

  late MockExerciseRepository mockRepo;

  setUp(() {
    mockRepo = MockExerciseRepository();
    when(mockRepo.watchAllDrift()).thenAnswer((_) => Stream.value(ExerciseState(exercises)));
    when(mockRepo.watchCategoriesDrift()).thenAnswer((_) => Stream.value(categories));
    when(mockRepo.watchEquipmentDrift()).thenAnswer((_) => Stream.value(equipment));
    when(mockRepo.watchMusclesDrift()).thenAnswer((_) => Stream.value(<Muscle>[]));
  });

  /// Builds a container, subscribes to [exerciseListFiltersProvider] (so Riverpod
  /// actually starts watching the upstream streams), drains the microtask
  /// queue so the streams' first values land, and returns the container.
  Future<ProviderContainer> primedContainer() async {
    final container = ProviderContainer.test(
      overrides: [exerciseRepositoryProvider.overrideWithValue(mockRepo)],
    );
    container.listen(exerciseListFiltersProvider, (_, _) {});
    await pumpEventQueue();
    return container;
  }

  group('build flow', () {
    test('returns isLoading=false with full data after streams settle', () async {
      final container = await primedContainer();

      final state = container.read(exerciseListFiltersProvider);

      expect(state.isLoading, isFalse);
      expect(state.exercises, hasLength(exercises.length));
      expect(state.filteredExercises, hasLength(exercises.length));
    });

    test('returns isLoading=false with empty results when an upstream errors', () async {
      when(mockRepo.watchAllDrift()).thenAnswer((_) => Stream.error(StateError('boom')));

      final container = await primedContainer();
      final state = container.read(exerciseListFiltersProvider);

      expect(state.isLoading, isFalse);
      expect(state.exercises, isEmpty);
      expect(state.filteredExercises, isEmpty);
    });
  });

  group('_initializeFilters', () {
    test('populates filter maps with all categories and equipment unselected', () async {
      final container = await primedContainer();

      final state = container.read(exerciseListFiltersProvider);

      expect(state.filters.exerciseCategories.items.keys, containsAll(categories));
      expect(state.filters.exerciseCategories.items.values.every((v) => v == false), isTrue);
      expect(state.filters.equipment.items.keys, containsAll(equipment));
      expect(state.filters.equipment.items.values.every((v) => v == false), isTrue);
    });
  });

  group('_applyFilters via setFilters', () {
    test('returns all exercises when nothing is marked and search term is short', () async {
      final container = await primedContainer();
      final state = container.read(exerciseListFiltersProvider);

      // 1-char search term is below the threshold, should return all.
      container
          .read(exerciseListFiltersProvider.notifier)
          .setFilters(state.filters.copyWith(searchTerm: 'D'));

      expect(
        container.read(exerciseListFiltersProvider).filteredExercises,
        hasLength(exercises.length),
      );
    });

    test('filters by selected category', () async {
      final container = await primedContainer();
      final state = container.read(exerciseListFiltersProvider);

      // tCategory3 (Abs) covers DeadLift, Curls and Squats.
      final newFilters = state.filters.copyWith(
        exerciseCategories: state.filters.exerciseCategories.copyWith(
          items: {for (final c in categories) c: c == testCategoryAbs},
        ),
      );
      container.read(exerciseListFiltersProvider.notifier).setFilters(newFilters);

      final filtered = container.read(exerciseListFiltersProvider).filteredExercises;
      expect(filtered.map((e) => e.id).toSet(), {testDeadLift.id, testCurls.id, testSquats.id});
    });

    test('filters by selected equipment', () async {
      // testBenchPress is the only fixture with tEquipment1 (Bench).
      final container = await primedContainer();
      final state = container.read(exerciseListFiltersProvider);

      final newFilters = state.filters.copyWith(
        equipment: state.filters.equipment.copyWith(
          items: {for (final e in equipment) e: e == testEquipmentBench},
        ),
      );
      container.read(exerciseListFiltersProvider.notifier).setFilters(newFilters);

      final filtered = container.read(exerciseListFiltersProvider).filteredExercises;
      expect(filtered.map((e) => e.id).toList(), [testBenchPress.id]);
    });

    test('filters by search term against the English translation name', () async {
      final container = await primedContainer();
      final state = container.read(exerciseListFiltersProvider);

      container
          .read(exerciseListFiltersProvider.notifier)
          .setFilters(state.filters.copyWith(searchTerm: 'dead'));

      final filtered = container.read(exerciseListFiltersProvider).filteredExercises;
      expect(filtered.map((e) => e.id).toList(), [testDeadLift.id]);
    });

    test('combines category + equipment + search', () async {
      final container = await primedContainer();
      final state = container.read(exerciseListFiltersProvider);

      // Category=Abs (tCategory3), Equipment=Dumbbell (tEquipment2), search='Squat'
      // → matches only testSquats. testBenchPress is filtered out by category
      // (tCategory1=Arms), the others by search term.
      final newFilters = state.filters.copyWith(
        searchTerm: 'Squat',
        exerciseCategories: state.filters.exerciseCategories.copyWith(
          items: {for (final c in categories) c: c == testCategoryAbs},
        ),
        equipment: state.filters.equipment.copyWith(
          items: {for (final e in equipment) e: e == testEquipmentDumbbell},
        ),
      );
      container.read(exerciseListFiltersProvider.notifier).setFilters(newFilters);

      final filtered = container.read(exerciseListFiltersProvider).filteredExercises;
      expect(filtered.map((e) => e.id).toList(), [testSquats.id]);
    });
  });

  group('setFilters', () {
    test('updates state.filters and re-runs filtering', () async {
      final container = await primedContainer();
      final state = container.read(exerciseListFiltersProvider);

      container
          .read(exerciseListFiltersProvider.notifier)
          .setFilters(state.filters.copyWith(searchTerm: 'curls'));

      final after = container.read(exerciseListFiltersProvider);
      expect(after.filters.searchTerm, 'curls');
      expect(after.filteredExercises.map((e) => e.id).toList(), [testCurls.id]);
    });
  });

  group('survives catalogue re-emission (sync tick)', () {
    /// Primes a container whose exercises stream is driven by [controller], so a
    /// test can push a second emission to simulate a PowerSync catalogue write.
    Future<ProviderContainer> primedWith(StreamController<ExerciseState> controller) async {
      when(mockRepo.watchAllDrift()).thenAnswer((_) => controller.stream);
      final container = ProviderContainer.test(
        overrides: [exerciseRepositoryProvider.overrideWithValue(mockRepo)],
      );
      container.listen(exerciseListFiltersProvider, (_, _) {});
      controller.add(ExerciseState(exercises));
      await pumpEventQueue();
      return container;
    }

    test('keeps the user search term and selection when the exercises stream re-emits', () async {
      final controller = StreamController<ExerciseState>();
      addTearDown(controller.close);
      final container = await primedWith(controller);

      // User narrows to Abs + Dumbbell + 'Squat' → only testSquats.
      final state = container.read(exerciseListFiltersProvider);
      container
          .read(exerciseListFiltersProvider.notifier)
          .setFilters(
            state.filters.copyWith(
              searchTerm: 'Squat',
              exerciseCategories: state.filters.exerciseCategories.copyWith(
                items: {for (final c in categories) c: c == testCategoryAbs},
              ),
              equipment: state.filters.equipment.copyWith(
                items: {for (final e in equipment) e: e == testEquipmentDumbbell},
              ),
            ),
          );
      expect(
        container.read(exerciseListFiltersProvider).filteredExercises.map((e) => e.id).toList(),
        [testSquats.id],
      );

      // A sync tick rewrites the catalogue: the exercises stream re-emits.
      controller.add(ExerciseState(exercises));
      await pumpEventQueue();

      final after = container.read(exerciseListFiltersProvider);
      expect(after.filters.searchTerm, 'Squat');
      expect(after.filters.exerciseCategories.selected, contains(testCategoryAbs));
      expect(after.filters.equipment.selected, contains(testEquipmentDumbbell));
      expect(after.filteredExercises.map((e) => e.id).toList(), [testSquats.id]);
    });

    test('a re-emission keeps filtering with the pinned user language', () async {
      // Only the German name ('Bankdrücken') contains 'Bank'; English is 'Bench press'.
      final bilingual = testBenchPress.copyWith(translations: [benchPressEn, benchPressDe]);
      final withGerman = [
        bilingual,
        ...exercises.where((e) => e.id != testBenchPress.id),
      ];
      final controller = StreamController<ExerciseState>();
      addTearDown(controller.close);
      when(mockRepo.watchAllDrift()).thenAnswer((_) => controller.stream);

      final container = ProviderContainer.test(
        overrides: [exerciseRepositoryProvider.overrideWithValue(mockRepo)],
      );
      container.listen(exerciseListFiltersProvider, (_, _) {});
      controller.add(ExerciseState(withGerman));
      await pumpEventQueue();

      final state = container.read(exerciseListFiltersProvider);
      container
          .read(exerciseListFiltersProvider.notifier)
          .setFilters(state.filters.copyWith(searchTerm: 'Bank'), 'de');
      expect(
        container.read(exerciseListFiltersProvider).filteredExercises.map((e) => e.id).toList(),
        [testBenchPress.id],
      );

      // The rebuild must keep the German language, not fall back to English.
      controller.add(ExerciseState(withGerman));
      await pumpEventQueue();
      expect(
        container.read(exerciseListFiltersProvider).filteredExercises.map((e) => e.id).toList(),
        [testBenchPress.id],
      );
    });
  });
}
