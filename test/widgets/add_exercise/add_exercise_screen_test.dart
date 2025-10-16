import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:wger/exceptions/http_exception.dart';
import 'package:wger/providers/add_exercise.dart';

@GenerateMocks([AddExerciseProvider])
import 'add_exercise_translation_test.mocks.dart';

void main() {
  late MockAddExerciseProvider mockAddExerciseProvider;

  setUp(() {
    mockAddExerciseProvider = MockAddExerciseProvider();
  });

  group('Language validation - correct language', () {
    test('English text validated as English', () async {
      const text =
          'Push-ups are a basic exercise to strengthen the upper body, especially the chest, shoulders, and triceps.';
      when(mockAddExerciseProvider.validateLanguage(text, 'en'))
          .thenAnswer((_) async => true);

      final result = await mockAddExerciseProvider.validateLanguage(text, 'en');

      expect(result, isTrue);
      verify(mockAddExerciseProvider.validateLanguage(text, 'en')).called(1);
    });

    test('German text validated as German', () async {
      const text =
          'Liegestütze sind eine grundlegende Übung zur Stärkung der oberen Körpermuskulatur.';
      when(mockAddExerciseProvider.validateLanguage(text, 'de'))
          .thenAnswer((_) async => true);

      final result = await mockAddExerciseProvider.validateLanguage(text, 'de');

      expect(result, isTrue);
      verify(mockAddExerciseProvider.validateLanguage(text, 'de')).called(1);
    });

    test('Slovak text validated as Slovak', () async {
      const text =
          'Kliky sú základným cvikom na posilnenie hornej časti tela a tricepsov.';
      when(mockAddExerciseProvider.validateLanguage(text, 'sk'))
          .thenAnswer((_) async => true);

      final result = await mockAddExerciseProvider.validateLanguage(text, 'sk');

      expect(result, isTrue);
      verify(mockAddExerciseProvider.validateLanguage(text, 'sk')).called(1);
    });
  });

  group('Language validation - wrong language', () {
    test('Slovak text validated as English - should throw exception', () async {
      const text =
          'Kliky sú základným cvikom na posilnenie hornej časti tela.';
      when(mockAddExerciseProvider.validateLanguage(text, 'en'))
          .thenThrow(WgerHttpException({
        'text': ['The detected language does not match the expected language.']
      }));

      expect(
            () => mockAddExerciseProvider.validateLanguage(text, 'en'),
        throwsA(isA<WgerHttpException>()),
      );

      verify(mockAddExerciseProvider.validateLanguage(text, 'en')).called(1);
    });

    test('English text validated as German - should throw exception', () async {
      const text =
          'Push-ups are a common exercise for strengthening the upper body.';
      when(mockAddExerciseProvider.validateLanguage(text, 'de'))
          .thenThrow(WgerHttpException({
        'text': ['The detected language does not match the expected language.']
      }));

      expect(
            () => mockAddExerciseProvider.validateLanguage(text, 'de'),
        throwsA(isA<WgerHttpException>()),
      );

      verify(mockAddExerciseProvider.validateLanguage(text, 'de')).called(1);
    });

    test('German text validated as Slovak - should throw exception', () async {
      const text =
          'Liegestütze sind eine klassische Übung zur Verbesserung der Kraft.';
      when(mockAddExerciseProvider.validateLanguage(text, 'sk'))
          .thenThrow(WgerHttpException({
        'text': ['The detected language does not match the expected language.']
      }));

      expect(
            () => mockAddExerciseProvider.validateLanguage(text, 'sk'),
        throwsA(isA<WgerHttpException>()),
      );

      verify(mockAddExerciseProvider.validateLanguage(text, 'sk')).called(1);
    });
  });
}
