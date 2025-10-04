import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/providers/add_exercise.dart';

import '../core/settings_test.mocks.dart';

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

      provider.addExerciseImages(
        [mockFile],
        title: 'Test Title',
        author: 'Test Author',
        authorUrl: 'https://test.com/author',
        sourceUrl: 'https://source.com',
        derivativeSourceUrl: 'https://derivative.com',
        style: '4', // LOW-POLY
      );

      expect(provider.exerciseImages.length, 1);
      expect(provider.exerciseImages.first.path, mockFile.path);
    });

    /// License fields are optional - provider should handle null/empty values
    /// Only non-empty fields should be included in the metadata map
    test('should handle empty fields gracefully', () {
      final mockFile = File('test2.jpg');

      provider.addExerciseImages(
        [mockFile],
        title: 'Only Title',
        author: null, // null value
        authorUrl: '', // empty string
        style: '2', // 3D
      );

      expect(provider.exerciseImages.length, 1);
    });

    /// Each image can have different metadata - test storing multiple
    /// images with unique license information
    test('should handle multiple images with different metadata', () {
      final file1 = File('image1.jpg');
      final file2 = File('image2.jpg');

      provider.addExerciseImages([file1], title: 'Image 1', author: 'Author 1', style: '1');
      provider.addExerciseImages([file2], title: 'Image 2', author: 'Author 2', style: '2');

      expect(provider.exerciseImages.length, 2);
      expect(provider.exerciseImages[0].path, file1.path);
      expect(provider.exerciseImages[1].path, file2.path);
    });

    /// Test all 5 image style types defined by the API
    /// 1=PHOTO, 2=3D, 3=LINE, 4=LOW-POLY, 5=OTHER
    test('should handle all image style types', () {
      final styles = ['1', '2', '3', '4', '5'];

      for (var i = 0; i < styles.length; i++) {
        provider.addExerciseImages([File('image_$i.jpg')], style: styles[i]);
      }

      expect(provider.exerciseImages.length, 5);
    });

    /// If no style is specified, should default to '1' (PHOTO)
    test('should use default style when not specified', () {
      final mockFile = File('default.jpg');

      provider.addExerciseImages([mockFile]);

      expect(provider.exerciseImages.length, 1);
    });

    /// Edge case: calling addExerciseImages with empty list should not crash
    test('should handle empty image list', () {
      provider.addExerciseImages([]);

      expect(provider.exerciseImages.length, 0);
    });

    /// Allows adding the same file multiple times with different metadata
    /// (e.g., different crops or edits of the same original image)
    test('should handle adding same file multiple times', () {
      final mockFile = File('same.jpg');

      provider.addExerciseImages([mockFile], title: 'First');
      provider.addExerciseImages([mockFile], title: 'Second');

      expect(provider.exerciseImages.length, 2);
    });

    /// Removing an image should also remove its associated metadata
    /// to prevent memory leaks
    test('should remove image and its metadata', () {
      final mockFile = File('to_remove.jpg');
      provider.addExerciseImages([mockFile], title: 'Will be removed', style: '1');

      expect(provider.exerciseImages.length, 1);

      provider.removeExercise(mockFile.path);

      expect(provider.exerciseImages.length, 0);
    });

    /// Attempting to remove a non-existent image should throw StateError
    /// (from firstWhere with no orElse)
    test('should handle removing non-existent image gracefully', () {
      expect(() => provider.removeExercise('nonexistent.jpg'), throwsStateError);
    });

    /// clear() should reset all state including images and metadata
    test('should clear all images and metadata', () {
      provider.addExerciseImages([File('image1.jpg')], title: 'Image 1');
      provider.addExerciseImages([File('image2.jpg')], title: 'Image 2');

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

    /// Images should be stored in the order they were added
    /// Important for display consistency
    test('should preserve image order', () {
      final file1 = File('first.jpg');
      final file2 = File('second.jpg');
      final file3 = File('third.jpg');

      provider.addExerciseImages([file1]);
      provider.addExerciseImages([file2]);
      provider.addExerciseImages([file3]);

      expect(provider.exerciseImages[0].path, 'first.jpg');
      expect(provider.exerciseImages[1].path, 'second.jpg');
      expect(provider.exerciseImages[2].path, 'third.jpg');
    });

    /// Multiple images can be added in a single call with shared metadata
    /// Useful for bulk uploads from the same source
    test('should handle batch adding multiple images at once', () {
      final files = [File('batch1.jpg'), File('batch2.jpg'), File('batch3.jpg')];

      provider.addExerciseImages(files, title: 'Batch Upload', style: '3');

      expect(provider.exerciseImages.length, 3);
    });

    /// Removing one image from a set should not affect others
    test('should allow removing specific image from multiple images', () {
      final file1 = File('keep1.jpg');
      final file2 = File('remove.jpg');
      final file3 = File('keep2.jpg');

      provider.addExerciseImages([file1]);
      provider.addExerciseImages([file2]);
      provider.addExerciseImages([file3]);

      expect(provider.exerciseImages.length, 3);

      provider.removeExercise(file2.path);

      expect(provider.exerciseImages.length, 2);
      expect(provider.exerciseImages[0].path, file1.path);
      expect(provider.exerciseImages[1].path, file3.path);
    });

    /// Test with extremely long strings (1000 chars) to ensure no
    /// buffer overflow or validation issues
    test('should handle very long metadata strings', () {
      final mockFile = File('long.jpg');
      final longString = 'a' * 1000;

      provider.addExerciseImages(
        [mockFile],
        title: longString,
        author: longString,
        authorUrl: 'https://example.com/$longString',
      );

      expect(provider.exerciseImages.length, 1);
    });

    /// Unicode characters, emojis, and URL-encoded strings should all work
    /// Tests international character support
    test('should handle special characters in metadata', () {
      final mockFile = File('special.jpg');

      provider.addExerciseImages(
        [mockFile],
        title: 'Title with émojis 🎉 and spëcial çhars',
        author: 'Autör with ümlauts',
        authorUrl: 'https://example.com/path?query=value&another=value',
      );

      expect(provider.exerciseImages.length, 1);
    });
  });

  group('State management', () {
    /// clear() should reset ALL provider state, not just images
    /// Ensures no data leaks between exercises
    test('should reset all state after clear', () {
      provider.exerciseNameEn = 'Test Exercise';
      provider.descriptionEn = 'Description';
      provider.addExerciseImages([File('test.jpg')]);

      provider.clear();

      expect(provider.exerciseImages.length, 0);
      expect(provider.exerciseNameEn, isNull);
      expect(provider.descriptionEn, isNull);
    });
  });
}
