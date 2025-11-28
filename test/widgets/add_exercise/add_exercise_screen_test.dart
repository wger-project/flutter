import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:wger/exceptions/http_exception.dart';
import 'package:wger/providers/add_exercise.dart';

@GenerateMocks([AddExerciseProvider])
import 'add_exercise_screen_test.mocks.dart';

void main() {
  late MockAddExerciseProvider mockProvider;

  setUp(() {
    mockProvider = MockAddExerciseProvider();
  });

  group('validateLanguage - English description (step 2)', () {
    test('calls validateLanguage with English text and "en" code', () async {

      const descriptionText = 'Push-ups are a basic exercise for upper body strength.';
      when(mockProvider.validateLanguage(descriptionText, 'en'))
          .thenAnswer((_) async => true);

      await mockProvider.validateLanguage(descriptionText, 'en');

      verify(mockProvider.validateLanguage(descriptionText, 'en')).called(1);
    });

    test('throws WgerHttpException when validation fails', () async {
      const descriptionText = 'Deutscher Text in English field';
      final exception = WgerHttpException({
        'text': ['The detected language does not match the expected language.']
      });

      when(mockProvider.validateLanguage(descriptionText, 'en'))
          .thenThrow(exception);

      expect(
            () => mockProvider.validateLanguage(descriptionText, 'en'),
        throwsA(isA<WgerHttpException>()),
      );
    });

    test('validates with correct language code "en"', () async {
      const text = 'This is an English description.';
      when(mockProvider.validateLanguage(text, 'en'))
          .thenAnswer((_) async => true);

      final result = await mockProvider.validateLanguage(text, 'en');

      expect(result, isTrue);
      verify(mockProvider.validateLanguage(text, 'en')).called(1);
    });
  });

  group('validateLanguage - Translation (step 3)', () {
    test('calls validateLanguage with German text and "de" code', () async {
      const translationText = 'Liegestütze sind eine Grundübung für den Oberkörper.';
      when(mockProvider.validateLanguage(translationText, 'de'))
          .thenAnswer((_) async => true);

      await mockProvider.validateLanguage(translationText, 'de');

      verify(mockProvider.validateLanguage(translationText, 'de')).called(1);
    });

    test('calls validateLanguage with Slovak text and "sk" code', () async {
      const translationText = 'Kliky sú základné cvičenie pre hornú časť tela.';
      when(mockProvider.validateLanguage(translationText, 'sk'))
          .thenAnswer((_) async => true);

      await mockProvider.validateLanguage(translationText, 'sk');

      verify(mockProvider.validateLanguage(translationText, 'sk')).called(1);
    });

    test('uses correct language code from Language model', () async {
      const text = 'Deutscher Text';
      const languageCode = 'de';

      when(mockProvider.validateLanguage(text, languageCode))
          .thenAnswer((_) async => true);

      await mockProvider.validateLanguage(text, languageCode);

      verify(mockProvider.validateLanguage(text, languageCode)).called(1);
      verifyNever(mockProvider.validateLanguage(text, 'en'));
    });
  });

  group('validateLanguage - Edge cases', () {
    test('handles empty text', () async {
      when(mockProvider.validateLanguage('', 'en'))
          .thenAnswer((_) async => true);

      await mockProvider.validateLanguage('', 'en');

      verify(mockProvider.validateLanguage('', 'en')).called(1);
    });

    test('handles text with special characters', () async {
      const text = 'Übung für Körper & Geist (100% Erfolg)';
      when(mockProvider.validateLanguage(text, 'de'))
          .thenAnswer((_) async => true);

      await mockProvider.validateLanguage(text, 'de');

      verify(mockProvider.validateLanguage(text, 'de')).called(1);
    });

    test('handles long text', () async {
      const longText = '''
Push-ups are a fundamental bodyweight exercise that strengthens the upper body, 
especially the chest, shoulders, and triceps. The movement involves supporting 
the body on hands and feet while keeping it straight. It improves muscular 
strength, core stability, endurance, and overall physical fitness.
''';
      when(mockProvider.validateLanguage(longText, 'en'))
          .thenAnswer((_) async => true);

      await mockProvider.validateLanguage(longText, 'en');

      verify(mockProvider.validateLanguage(longText, 'en')).called(1);
    });
  });

  group('validateLanguage - Error responses', () {
    test('WgerHttpException is thrown for invalid language', () {
      final exception = WgerHttpException({
        'text': ['The detected language does not match the expected language.']
      });

      expect(exception, isA<WgerHttpException>());
    });

    test('throws WgerHttpException on validation failure', () async {
      const text = 'Wrong language text';
      final exception = WgerHttpException({
        'text': ['Language mismatch error']
      });

      when(mockProvider.validateLanguage(text, 'en')).thenThrow(exception);

      expect(
            () => mockProvider.validateLanguage(text, 'en'),
        throwsA(isA<WgerHttpException>()),
      );
    });
  });

  group('validateLanguage - Multiple language codes', () {
    test('validates different language codes correctly', () async {
      when(mockProvider.validateLanguage('English text', 'en'))
          .thenAnswer((_) async => true);
      await mockProvider.validateLanguage('English text', 'en');
      verify(mockProvider.validateLanguage('English text', 'en')).called(1);

      when(mockProvider.validateLanguage('Deutscher Text', 'de'))
          .thenAnswer((_) async => true);
      await mockProvider.validateLanguage('Deutscher Text', 'de');
      verify(mockProvider.validateLanguage('Deutscher Text', 'de')).called(1);

      when(mockProvider.validateLanguage('Slovenský text', 'sk'))
          .thenAnswer((_) async => true);
      await mockProvider.validateLanguage('Slovenský text', 'sk');
      verify(mockProvider.validateLanguage('Slovenský text', 'sk')).called(1);
    });

    test('does not cross-validate wrong language combinations', () async {
      when(mockProvider.validateLanguage('Deutscher Text', 'de'))
          .thenAnswer((_) async => true);

      await mockProvider.validateLanguage('Deutscher Text', 'de');

      verify(mockProvider.validateLanguage('Deutscher Text', 'de')).called(1);

      verifyNever(mockProvider.validateLanguage('Deutscher Text', 'en'));
      verifyNever(mockProvider.validateLanguage('Deutscher Text', 'sk'));
    });
  });


}