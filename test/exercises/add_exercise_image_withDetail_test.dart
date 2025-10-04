import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/providers/add_exercise.dart';

import '../core/settings_test.mocks.dart';

void main() {
  late MockWgerBaseProvider mockBaseProvider;
  late AddExerciseProvider provider;

  setUp(() {
    mockBaseProvider = MockWgerBaseProvider();
    provider = AddExerciseProvider(mockBaseProvider);
  });

  group('Image metadata handling', () {
    test('should store image with all license fields', () {
      final mockFile = File('test.jpg');

      provider.addExerciseImages(
        [mockFile],
        title: 'Test Title',
        author: 'Test Author',
        authorUrl: 'https://test.com/author',
        sourceUrl: 'https://source.com',
        derivativeSourceUrl: 'https://derivative.com',
        style: '4',
      );

      expect(provider.exerciseImages.length, 1);
      expect(provider.exerciseImages.first.path, mockFile.path);
    });

    test('should handle empty fields gracefully', () {
      final mockFile = File('test2.jpg');

      provider.addExerciseImages(
        [mockFile],
        title: 'Only Title',
        author: null,
        authorUrl: '',
        style: '2',
      );

      expect(provider.exerciseImages.length, 1);
    });

    test('should handle multiple images with different metadata', () {
      final file1 = File('image1.jpg');
      final file2 = File('image2.jpg');

      provider.addExerciseImages([file1], title: 'Image 1', author: 'Author 1', style: '1');
      provider.addExerciseImages([file2], title: 'Image 2', author: 'Author 2', style: '2');

      expect(provider.exerciseImages.length, 2);
      expect(provider.exerciseImages[0].path, file1.path);
      expect(provider.exerciseImages[1].path, file2.path);
    });

    test('should handle all image style types', () {
      final styles = ['1', '2', '3', '4', '5'];

      for (var i = 0; i < styles.length; i++) {
        provider.addExerciseImages(
          [File('image_$i.jpg')],
          style: styles[i],
        );
      }

      expect(provider.exerciseImages.length, 5);
    });

    test('should use default style when not specified', () {
      final mockFile = File('default.jpg');

      provider.addExerciseImages([mockFile]);

      expect(provider.exerciseImages.length, 1);
    });

    test('should handle empty image list', () {
      provider.addExerciseImages([]);

      expect(provider.exerciseImages.length, 0);
    });

    test('should handle adding same file multiple times', () {
      final mockFile = File('same.jpg');

      provider.addExerciseImages([mockFile], title: 'First');
      provider.addExerciseImages([mockFile], title: 'Second');

      expect(provider.exerciseImages.length, 2);
    });

    test('should remove image and its metadata', () {
      final mockFile = File('to_remove.jpg');
      provider.addExerciseImages([mockFile], title: 'Will be removed', style: '1');

      expect(provider.exerciseImages.length, 1);

      provider.removeExercise(mockFile.path);

      expect(provider.exerciseImages.length, 0);
    });

    test('should handle removing non-existent image gracefully', () {
      expect(
            () => provider.removeExercise('nonexistent.jpg'),
        throwsStateError,
      );
    });

    test('should clear all images and metadata', () {
      provider.addExerciseImages([File('image1.jpg')], title: 'Image 1');
      provider.addExerciseImages([File('image2.jpg')], title: 'Image 2');

      expect(provider.exerciseImages.length, 2);

      provider.clear();

      expect(provider.exerciseImages.length, 0);
    });

    test('should handle clearing empty list', () {
      expect(provider.exerciseImages.length, 0);

      provider.clear();

      expect(provider.exerciseImages.length, 0);
    });

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

    test('should handle batch adding multiple images at once', () {
      final files = [
        File('batch1.jpg'),
        File('batch2.jpg'),
        File('batch3.jpg'),
      ];

      provider.addExerciseImages(files, title: 'Batch Upload', style: '3');

      expect(provider.exerciseImages.length, 3);
    });

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