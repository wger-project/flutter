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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/providers/exercise_repository.dart';
import 'package:wger/providers/exercises_notifier.dart';
import 'package:wger/providers/network_provider.dart';

import '../../test_data/exercises.dart';
import 'exercises_notifier_test.mocks.dart';

@GenerateMocks([ExerciseRepository])
void main() {
  final exercises = [testBenchPress, testCrunches, testDeadLift, testCurls, testSquats];
  late MockExerciseRepository mockRepo;

  setUp(() {
    mockRepo = MockExerciseRepository();
    when(mockRepo.watchAllDrift()).thenAnswer((_) => Stream.value(ExerciseState(exercises)));
  });

  Future<ProviderContainer> primedContainer({bool isOnline = true}) async {
    final container = ProviderContainer.test(
      overrides: [
        exerciseRepositoryProvider.overrideWithValue(mockRepo),
        networkStatusProvider.overrideWithValue(isOnline),
      ],
    );
    container.listen(exercisesProvider, (_, _) {});
    await pumpEventQueue();
    return container;
  }

  group('ExerciseState', () {
    // Two exercises share the 'chest' variationGroup, one is in 'legs', and
    // testCrunches has no variationGroup at all (so it should be excluded
    // from all variation lookups).
    final benchPress = Exercise(
      id: 100,
      uuid: 'bench-uuid',
      category: testCategoryArms,
      variationGroup: 'chest',
    );
    final inclineBench = Exercise(
      id: 101,
      uuid: 'incline-uuid',
      category: testCategoryArms,
      variationGroup: 'chest',
    );
    final squat = Exercise(
      id: 200,
      uuid: 'squat-uuid',
      category: testCategoryLegs,
      variationGroup: 'legs',
    );
    final variationExercises = [benchPress, inclineBench, squat, testCrunches];
    const emptyState = ExerciseState([]);

    test('getById returns the matching exercise', () {
      final s = ExerciseState(exercises);

      expect(s.getById(testDeadLift.id).id, testDeadLift.id);
    });

    test('getById throws when no exercise matches', () {
      expect(() => emptyState.getById(999), throwsStateError);
    });

    test('getByVariation buckets exercises that share a variationGroup', () {
      final s = ExerciseState(variationExercises);

      final buckets = s.getByVariation();

      expect(buckets.keys.toSet(), {'chest', 'legs'});
      expect(buckets['chest']!.map((e) => e.id).toSet(), {benchPress.id, inclineBench.id});
      expect(buckets['legs']!.map((e) => e.id).toList(), [squat.id]);
    });

    test('getByVariation returns empty when no exercise has a variationGroup', () {
      final s = ExerciseState([testCrunches]);

      expect(s.getByVariation(), isEmpty);
    });

    test('findByVariationGroup returns empty when called with null', () {
      final s = ExerciseState(variationExercises);

      expect(s.findByVariationGroup(null), isEmpty);
    });

    test('findByVariationGroup returns all exercises in the group', () {
      final s = ExerciseState(variationExercises);

      final result = s.findByVariationGroup('chest');

      expect(result.map((e) => e.id).toSet(), {benchPress.id, inclineBench.id});
    });

    test('findByVariationGroup excludes the given exercise id', () {
      final s = ExerciseState(variationExercises);

      final result = s.findByVariationGroup('chest', exerciseIdToExclude: benchPress.id);

      expect(result.map((e) => e.id).toList(), [inclineBench.id]);
    });

    test('findByVariationGroup returns empty for a group with no members', () {
      final s = ExerciseState(variationExercises);

      expect(s.findByVariationGroup('non-existent'), isEmpty);
    });
  });

  group('searchExercise', () {
    test('returns empty for an empty term, regardless of network state', () async {
      final online = await primedContainer(isOnline: true);
      final offline = await primedContainer(isOnline: false);

      expect(await online.read(exercisesProvider.notifier).searchExercise(''), isEmpty);
      expect(await offline.read(exercisesProvider.notifier).searchExercise(''), isEmpty);
      verifyNever(mockRepo.searchExerciseServer(any));
    });

    test('online: hits the server search and hydrates ids against the snapshot', () async {
      when(
        mockRepo.searchExerciseServer(
          any,
          languageCode: anyNamed('languageCode'),
          searchEnglish: anyNamed('searchEnglish'),
        ),
      ).thenAnswer((_) async => [testCrunches.id, testSquats.id]);
      final container = await primedContainer(isOnline: true);

      final result = await container.read(exercisesProvider.notifier).searchExercise('foo');

      expect(result.map((e) => e.id).toSet(), {testCrunches.id, testSquats.id});
      verify(
        mockRepo.searchExerciseServer('foo', languageCode: 'en', searchEnglish: false),
      ).called(1);
    });

    test('online: ids that are not in the snapshot get dropped', () async {
      when(
        mockRepo.searchExerciseServer(
          any,
          languageCode: anyNamed('languageCode'),
          searchEnglish: anyNamed('searchEnglish'),
        ),
      ).thenAnswer((_) async => [9999]);
      final container = await primedContainer(isOnline: true);

      final result = await container.read(exercisesProvider.notifier).searchExercise('foo');

      expect(result, isEmpty);
    });

    test('offline: searches the in-memory snapshot by translation name', () async {
      final container = await primedContainer(isOnline: false);

      final result = await container.read(exercisesProvider.notifier).searchExercise('dead');

      expect(result.map((e) => e.id).toList(), [testDeadLift.id]);
      verifyNever(mockRepo.searchExerciseServer(any));
    });

    test('offline: search is case-insensitive', () async {
      final container = await primedContainer(isOnline: false);

      final result = await container.read(exercisesProvider.notifier).searchExercise('DEAD');

      expect(result.map((e) => e.id).toList(), [testDeadLift.id]);
    });

    // NOTE: a focused test for the searchEnglish=true branch is omitted because
    // Exercise.getTranslation('xx') falls back to English when no 'xx'
    // translation exists, so a German search already matches English names in
    // this fixture set. A useful test would need a German translation that
    // intentionally diverges from the English one.
  });
}
