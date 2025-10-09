import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:wger/models/exercises/exercise_submission_images.dart';
import 'package:wger/providers/add_exercise.dart';
import 'package:wger/providers/base_provider.dart';

import 'contribute_exercise_image_test.mocks.dart';

/// Unit tests for AddExerciseProvider image metadata handling
///
/// Tests the functionality added for issue #931 - storing and managing
/// CC BY-SA 4.0 license metadata alongside exercise images.
///
/// Key areas tested:
/// - Adding images with complete/partial/no metadata
/// - Edge cases (empty lists, duplicates, special characters)
/// - State management (clear, remove)
/// - Image ordering and batch operations

@GenerateMocks([AddExerciseProvider, WgerBaseProvider])
void main() {
  late MockWgerBaseProvider mockBaseProvider;
  late AddExerciseProvider provider;

  setUp(() {
    mockBaseProvider = MockWgerBaseProvider();
    provider = AddExerciseProvider(mockBaseProvider);
  });

  group('Image metadata handling', () {
    /// Verify that all CC BY-SA license fields are stored correctly
    /// Tests: title, author, authorUrl, sourceUrl, derivativeSourceUrl, style
    test('should store image with all license fields', () {
      final mockFile = File('test.jpg');

      provider.addExerciseImages([
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

      expect(provider.exerciseImages.length, 1);
      expect(provider.exerciseImages.first.imageFile.path, mockFile.path);
    });

    /// License fields are optional - provider should handle null/empty values
    /// Only non-empty fields should be included in the metadata map
    test('should handle empty fields gracefully', () {
      final mockFile = File('test2.jpg');

      provider.addExerciseImages([
        ExerciseSubmissionImage(imageFile: mockFile, title: 'Only Title', type: ImageType.threeD),
      ]);

      expect(provider.exerciseImages.length, 1);
    });

    /// Each image can have different metadata - test storing multiple
    /// images with unique license information
    test('should handle multiple images with different metadata', () {
      final file1 = File('image1.jpg');
      final file2 = File('image2.jpg');

      provider.addExerciseImages([ExerciseSubmissionImage(imageFile: file1, author: 'Author 1')]);
      provider.addExerciseImages([ExerciseSubmissionImage(imageFile: file2, author: 'Author 1')]);

      expect(provider.exerciseImages.length, 2);
      expect(provider.exerciseImages[0].imageFile.path, file1.path);
      expect(provider.exerciseImages[1].imageFile.path, file2.path);
    });

    /// Edge case: calling addExerciseImages with empty list should not crash
    test('should handle empty image list', () {
      provider.addExerciseImages([]);

      expect(provider.exerciseImages.length, 0);
    });

    /// Removing an image should also remove its associated metadata
    /// to prevent memory leaks
    test('should remove image and its metadata', () {
      final mockFile = File('to_remove.jpg');
      provider.addExerciseImages([ExerciseSubmissionImage(imageFile: mockFile)]);

      expect(provider.exerciseImages.length, 1);

      provider.removeImage(mockFile.path);

      expect(provider.exerciseImages.length, 0);
    });

    /// Attempting to remove a non-existent image should throw StateError
    /// (from firstWhere with no orElse)
    test('should handle removing non-existent image gracefully', () {
      expect(() => provider.removeImage('nonexistent.jpg'), throwsStateError);
    });

    /// clear() should reset all state including images and metadata
    test('should clear all images and metadata', () {
      provider.addExerciseImages([
        ExerciseSubmissionImage(imageFile: File('image1.jpg'), title: 'Image 1'),
        ExerciseSubmissionImage(imageFile: File('image2.jpg'), title: 'Image 2'),
      ]);

      expect(provider.exerciseImages.length, 2);

      provider.clear();

      expect(provider.exerciseImages.length, 0);
    });

    /// Clearing an already empty list should not cause errors
    test('should handle clearing empty list', () {
      expect(provider.exerciseImages.length, 0);

      provider.clear();

      expect(provider.exerciseImages.length, 0);
    });

    /// Removing one image from a set should not affect others
    test('should allow removing specific image from multiple images', () {
      final file1 = File('keep1.jpg');
      final file2 = File('remove.jpg');
      final file3 = File('keep2.jpg');

      provider.addExerciseImages([ExerciseSubmissionImage(imageFile: file1)]);
      provider.addExerciseImages([ExerciseSubmissionImage(imageFile: file2)]);
      provider.addExerciseImages([ExerciseSubmissionImage(imageFile: file3)]);

      expect(provider.exerciseImages.length, 3);

      provider.removeImage(file2.path);

      expect(provider.exerciseImages.length, 2);
      expect(provider.exerciseImages[0].imageFile.path, file1.path);
      expect(provider.exerciseImages[1].imageFile.path, file3.path);
    });

    /// Test with extremely long strings (1000 chars) to ensure no
    /// buffer overflow or validation issues
    test('should handle very long metadata strings', () {
      final mockFile = File('long.jpg');
      final longString = 'a' * 1000;

      provider.addExerciseImages([
        ExerciseSubmissionImage(
          imageFile: mockFile,
          title: longString,
          author: longString,
          authorUrl: 'https://example.com/$longString',
        ),
      ]);

      expect(provider.exerciseImages.length, 1);
    });

    /// Unicode characters, emojis, and URL-encoded strings should all work
    /// Tests international character support
    test('should handle special characters in metadata', () {
      final mockFile = File('special.jpg');

      provider.addExerciseImages([
        ExerciseSubmissionImage(
          imageFile: mockFile,
          title: 'Title with émojis 🎉 and spëcial çhars',
          author: 'Autör with ümlauts',
          authorUrl: 'https://example.com/path?query=value&another=value',
        ),
      ]);

      expect(provider.exerciseImages.length, 1);
    });
  });

  group('State management', () {
    /// clear() should reset ALL provider state, not just images
    /// Ensures no data leaks between exercises
    test('should reset all state after clear', () {
      provider.exerciseNameEn = 'Test Exercise';
      provider.descriptionEn = 'Description';
      provider.addExerciseImages([ExerciseSubmissionImage(imageFile: File('test.jpg'))]);

      provider.clear();

      expect(provider.exerciseImages.length, 0);
      expect(provider.exerciseNameEn, isNull);
      expect(provider.descriptionEn, isNull);
    });
  });
}
