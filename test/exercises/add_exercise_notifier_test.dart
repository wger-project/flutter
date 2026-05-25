/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 - 2026 wger Team
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

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/models/exercises/exercise_submission.dart';
import 'package:wger/models/exercises/exercise_submission_images.dart';
import 'package:wger/providers/add_exercise_notifier.dart';
import 'package:wger/providers/add_exercise_repository.dart';

import '../../test_data/exercises.dart';
import 'add_exercise_notifier_test.mocks.dart';

@GenerateMocks([AddExerciseRepository])
void main() {
  late MockAddExerciseRepository mockRepo;
  late ProviderContainer container;

  setUp(() {
    mockRepo = MockAddExerciseRepository();
    container = ProviderContainer.test(
      overrides: [addExerciseRepositoryProvider.overrideWithValue(mockRepo)],
    );
  });

  group('build', () {
    test('starts with the empty AddExerciseState', () {
      final state = container.read(addExerciseProvider);

      expect(state.author, '');
      expect(state.exerciseImages, isEmpty);
      expect(state.category, isNull);
    });
  });

  group('field setters', () {
    test('setAuthor / name / description / language setters update state', () {
      final n = container.read(addExerciseProvider.notifier);

      n.setAuthor('Alice');
      n.setExerciseNameEn('Bench Press');
      n.setExerciseNameTrans('Bankdrücken');
      n.setDescriptionEn('English desc');
      n.setDescriptionTrans('Deutsche Beschreibung');
      n.setLanguageEn(testEnglish);
      n.setLanguageTranslation(testGerman);
      n.setAlternateNamesEn(['Chest Press']);
      n.setAlternateNamesTrans(['Flachbankdrücken']);

      final state = container.read(addExerciseProvider);
      expect(state.author, 'Alice');
      expect(state.exerciseNameEn, 'Bench Press');
      expect(state.exerciseNameTrans, 'Bankdrücken');
      expect(state.descriptionEn, 'English desc');
      expect(state.descriptionTrans, 'Deutsche Beschreibung');
      expect(state.languageEn, testEnglish);
      expect(state.languageTranslation, testGerman);
      expect(state.alternateNamesEn, ['Chest Press']);
      expect(state.alternateNamesTrans, ['Flachbankdrücken']);
    });

    test('category, equipment, muscles setters update state', () {
      final n = container.read(addExerciseProvider.notifier);

      n.setCategory(testCategoryArms);
      n.setEquipment([testEquipmentBench, testEquipmentDumbbell]);
      n.setPrimaryMuscles([tMuscle1]);
      n.setSecondaryMuscles([tMuscle2, tMuscle3]);

      final state = container.read(addExerciseProvider);
      expect(state.category, testCategoryArms);
      expect(state.equipment, [testEquipmentBench, testEquipmentDumbbell]);
      expect(state.primaryMuscles, [tMuscle1]);
      expect(state.secondaryMuscles, [tMuscle2, tMuscle3]);
    });
  });

  group('variation setters, mutual exclusion', () {
    test('setVariationGroup clears variationConnectToExercise', () {
      final n = container.read(addExerciseProvider.notifier);
      n.setVariationConnectToExercise(42);
      expect(container.read(addExerciseProvider).variationConnectToExercise, 42);

      n.setVariationGroup('chest');

      final state = container.read(addExerciseProvider);
      expect(state.variationGroup, 'chest');
      expect(state.variationConnectToExercise, isNull);
    });

    test('setVariationConnectToExercise clears variationGroup', () {
      final n = container.read(addExerciseProvider.notifier);
      n.setVariationGroup('chest');
      expect(container.read(addExerciseProvider).variationGroup, 'chest');

      n.setVariationConnectToExercise(42);

      final state = container.read(addExerciseProvider);
      expect(state.variationConnectToExercise, 42);
      expect(state.variationGroup, isNull);
    });
  });

  group('image management', () {
    final image1 = ExerciseSubmissionImage(imageFile: File('/tmp/img1.jpg'));
    final image2 = ExerciseSubmissionImage(imageFile: File('/tmp/img2.jpg'));

    test('addExerciseImages appends to the existing list', () {
      final n = container.read(addExerciseProvider.notifier);

      n.addExerciseImages([image1]);
      n.addExerciseImages([image2]);

      expect(container.read(addExerciseProvider).exerciseImages, [image1, image2]);
    });

    test('removeImage drops the entry whose path matches', () {
      final n = container.read(addExerciseProvider.notifier);
      n.addExerciseImages([image1, image2]);

      n.removeImage('/tmp/img1.jpg');

      expect(container.read(addExerciseProvider).exerciseImages, [image2]);
    });

    test('removeImage on a non-matching path is a no-op', () {
      final n = container.read(addExerciseProvider.notifier);
      n.addExerciseImages([image1]);

      n.removeImage('/tmp/does-not-exist.jpg');

      expect(container.read(addExerciseProvider).exerciseImages, [image1]);
    });
  });

  group('clear', () {
    test('resets state to the empty AddExerciseState', () {
      final n = container.read(addExerciseProvider.notifier);
      n.setAuthor('Alice');
      n.setCategory(testCategoryArms);

      n.clear();

      final state = container.read(addExerciseProvider);
      expect(state.author, '');
      expect(state.category, isNull);
    });
  });

  group('postExerciseToServer', () {
    test('submits, uploads each image, clears state, returns id', () async {
      final image1 = ExerciseSubmissionImage(imageFile: File('/tmp/img1.jpg'));
      final image2 = ExerciseSubmissionImage(imageFile: File('/tmp/img2.jpg'));
      final n = container.read(addExerciseProvider.notifier);

      // Build a valid state by going through the setters (matches what the
      // UI does in production).
      n.setAuthor('Alice');
      n.setExerciseNameEn('Bench Press');
      n.setDescriptionEn('English desc');
      n.setLanguageEn(testEnglish);
      n.setCategory(testCategoryArms);
      n.setPrimaryMuscles([tMuscle1]);
      n.addExerciseImages([image1, image2]);

      when(mockRepo.submit(any)).thenAnswer((_) async => 7);
      when(
        mockRepo.uploadImage(
          exerciseId: anyNamed('exerciseId'),
          image: anyNamed('image'),
          author: anyNamed('author'),
        ),
      ).thenAnswer((_) async {});

      final newId = await n.postExerciseToServer();

      expect(newId, 7);
      verify(mockRepo.submit(any)).called(1);
      verify(
        mockRepo.uploadImage(exerciseId: 7, image: image1, author: 'Alice'),
      ).called(1);
      verify(
        mockRepo.uploadImage(exerciseId: 7, image: image2, author: 'Alice'),
      ).called(1);
      // State should be reset after a successful submission.
      expect(container.read(addExerciseProvider).author, '');
      expect(container.read(addExerciseProvider).exerciseImages, isEmpty);
    });

    test('skips image upload when no images are attached', () async {
      final n = container.read(addExerciseProvider.notifier);
      n.setAuthor('Alice');
      n.setExerciseNameEn('Bench Press');
      n.setDescriptionEn('English desc');
      n.setLanguageEn(testEnglish);
      n.setCategory(testCategoryArms);
      n.setPrimaryMuscles([tMuscle1]);

      when(mockRepo.submit(any)).thenAnswer((_) async => 9);

      final newId = await n.postExerciseToServer();

      expect(newId, 9);
      verifyNever(
        mockRepo.uploadImage(
          exerciseId: anyNamed('exerciseId'),
          image: anyNamed('image'),
          author: anyNamed('author'),
        ),
      );
    });

    test('passes the same payload that exerciseApiObject builds', () async {
      final n = container.read(addExerciseProvider.notifier);
      n.setAuthor('Alice');
      n.setExerciseNameEn('Bench Press');
      n.setDescriptionEn('English desc');
      n.setLanguageEn(testEnglish);
      n.setCategory(testCategoryArms);
      n.setPrimaryMuscles([tMuscle1]);

      // Snapshot the API object before submitting (the notifier clears state
      // afterwards).
      final expected = container.read(addExerciseProvider).exerciseApiObject;
      when(mockRepo.submit(any)).thenAnswer((_) async => 1);

      await n.postExerciseToServer();

      final captured = verify(mockRepo.submit(captureAny)).captured.single as ExerciseSubmissionApi;
      expect(captured.author, expected.author);
      expect(captured.category, expected.category);
      expect(captured.translations, hasLength(expected.translations.length));
    });
  });
}
