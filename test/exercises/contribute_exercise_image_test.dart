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

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:wger/models/exercises/exercise_submission_images.dart';
import 'package:wger/providers/add_exercise_notifier.dart';
import 'package:wger/providers/add_exercise_repository.dart';

import 'contribute_exercise_image_test.mocks.dart';

/// Unit tests for the exercise-contribution image metadata handling
///
/// Tests the functionality added for issue #931 - storing and managing
/// CC BY-SA 4.0 license metadata alongside exercise images.
@GenerateMocks([AddExerciseRepository])
void main() {
  late ProviderContainer container;

  AddExerciseNotifier notifier() => container.read(addExerciseProvider.notifier);
  List<ExerciseSubmissionImage> images() => container.read(addExerciseProvider).exerciseImages;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        addExerciseRepositoryProvider.overrideWithValue(MockAddExerciseRepository()),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('Image metadata handling', () {
    test('should store image with all license fields', () {
      final mockFile = File('test.jpg');

      notifier().addExerciseImages([
        ExerciseSubmissionImage(
          imageFile: mockFile,
          title: 'Test Title',
          author: 'Test Author',
          authorUrl: 'https://test.com/author',
          sourceUrl: 'https://source.com',
          derivativeSourceUrl: 'https://derivative.com',
          type: ImageType.lowPoly,
        ),
      ]);

      expect(images().length, 1);
      expect(images().first.imageFile.path, mockFile.path);
    });

    test('should handle empty fields gracefully', () {
      final mockFile = File('test2.jpg');

      notifier().addExerciseImages([
        ExerciseSubmissionImage(imageFile: mockFile, title: 'Only Title', type: ImageType.threeD),
      ]);

      expect(images().length, 1);
    });

    test('should handle multiple images with different metadata', () {
      final file1 = File('image1.jpg');
      final file2 = File('image2.jpg');

      notifier().addExerciseImages([ExerciseSubmissionImage(imageFile: file1, author: 'Author 1')]);
      notifier().addExerciseImages([ExerciseSubmissionImage(imageFile: file2, author: 'Author 1')]);

      expect(images().length, 2);
      expect(images()[0].imageFile.path, file1.path);
      expect(images()[1].imageFile.path, file2.path);
    });

    test('should handle empty image list', () {
      notifier().addExerciseImages([]);

      expect(images().length, 0);
    });

    test('should remove image and its metadata', () {
      final mockFile = File('to_remove.jpg');
      notifier().addExerciseImages([ExerciseSubmissionImage(imageFile: mockFile)]);

      expect(images().length, 1);

      notifier().removeImage(mockFile.path);

      expect(images().length, 0);
    });

    test('should ignore removing non-existent image', () {
      // Removing a path that doesn't exist should be a no-op (different from
      // the old ChangeNotifier which threw StateError). The filter-based
      // implementation is forgiving.
      notifier().removeImage('nonexistent.jpg');
      expect(images().length, 0);
    });

    test('should clear all images and metadata', () {
      notifier().addExerciseImages([
        ExerciseSubmissionImage(imageFile: File('image1.jpg'), title: 'Image 1'),
        ExerciseSubmissionImage(imageFile: File('image2.jpg'), title: 'Image 2'),
      ]);

      expect(images().length, 2);

      notifier().clear();

      expect(images().length, 0);
    });

    test('should handle clearing empty list', () {
      expect(images().length, 0);
      notifier().clear();
      expect(images().length, 0);
    });

    test('should allow removing specific image from multiple images', () {
      final file1 = File('keep1.jpg');
      final file2 = File('remove.jpg');
      final file3 = File('keep2.jpg');

      notifier().addExerciseImages([ExerciseSubmissionImage(imageFile: file1)]);
      notifier().addExerciseImages([ExerciseSubmissionImage(imageFile: file2)]);
      notifier().addExerciseImages([ExerciseSubmissionImage(imageFile: file3)]);

      expect(images().length, 3);

      notifier().removeImage(file2.path);

      expect(images().length, 2);
      expect(images()[0].imageFile.path, file1.path);
      expect(images()[1].imageFile.path, file3.path);
    });

    test('should handle very long metadata strings', () {
      final mockFile = File('long.jpg');
      final longString = 'a' * 1000;

      notifier().addExerciseImages([
        ExerciseSubmissionImage(
          imageFile: mockFile,
          title: longString,
          author: longString,
          authorUrl: 'https://example.com/$longString',
        ),
      ]);

      expect(images().length, 1);
    });

    test('should handle special characters in metadata', () {
      final mockFile = File('special.jpg');

      notifier().addExerciseImages([
        ExerciseSubmissionImage(
          imageFile: mockFile,
          title: 'Title with émojis 🎉 and spëcial çhars',
          author: 'Autör with ümlauts',
          authorUrl: 'https://example.com/path?query=value&another=value',
        ),
      ]);

      expect(images().length, 1);
    });
  });

  group('State management', () {
    test('should reset all state after clear', () {
      notifier().setExerciseNameEn('Test Exercise');
      notifier().setDescriptionEn('Description');
      notifier().addExerciseImages([ExerciseSubmissionImage(imageFile: File('test.jpg'))]);

      notifier().clear();

      final state = container.read(addExerciseProvider);
      expect(state.exerciseImages.length, 0);
      expect(state.exerciseNameEn, isNull);
      expect(state.descriptionEn, isNull);
    });
  });
}
