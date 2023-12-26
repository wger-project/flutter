import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/models/exercises/exercise_base_data.dart';
import 'package:wger/providers/exercises.dart';

import '../../test_data/exercises.dart';
import '../fixtures/fixture_reader.dart';
import '../measurements/measurement_provider_test.mocks.dart';

void main() {
  late MockWgerBaseProvider mockBaseProvider;
  late ExercisesProvider provider;

  const String exerciseBaseInfoUrl = 'exercisebaseinfo';

  final Uri tExerciseBaseInfoUri = Uri(
    scheme: 'http',
    host: 'localhost',
    path: 'api/v2/$exerciseBaseInfoUrl/9/',
  );

  final Map<String, dynamic> tExerciseInfoMap = jsonDecode(
    fixture('exercises/exercisebaseinfo_response.json'),
  );

  setUp(() {
    mockBaseProvider = MockWgerBaseProvider();
    provider = ExercisesProvider(mockBaseProvider);
    provider.exerciseBases = getTestExerciseBases();
    provider.languages = [tLanguage1, tLanguage2, tLanguage3];

    // Mock base info response
    when(
      mockBaseProvider.makeUrl(exerciseBaseInfoUrl, id: 9),
    ).thenReturn(tExerciseBaseInfoUri);
    when(mockBaseProvider.fetch(tExerciseBaseInfoUri))
        .thenAnswer((_) => Future.value(tExerciseInfoMap));
  });

  group('Correctly loads and parses data from the server', () {
    test('test that fetchAndSetExerciseBase finds an existing base', () async {
      // arrange and act
      final base = await provider.fetchAndSetExerciseBase(1);

      // assert
      verifyNever(provider.baseProvider.fetch(tExerciseBaseInfoUri));
      expect(base.id, 1);
    });

    test('test that fetchAndSetExerciseBase fetches a new base', () async {
      // arrange and act
      final base = await provider.fetchAndSetExerciseBase(9);

      // assert
      verify(provider.baseProvider.fetch(tExerciseBaseInfoUri));
      expect(base.id, 9);
    });

    test('Load the readExerciseBaseFromBaseInfo parse method', () {
      // arrange

      // arrange and act
      final base =
          provider.readExerciseBaseFromBaseInfo(ExerciseBaseData.fromJson(tExerciseInfoMap));

      // assert
      expect(base.id, 9);
      expect(base.uuid, '1b020b3a-3732-4c7e-92fd-a0cec90ed69b');
      expect(base.categoryId, 10);
      expect(base.equipment.map((e) => e.name), ['Kettlebell']);
      expect(base.muscles.map((e) => e.name), [
        'Biceps femoris',
        'Brachialis',
        'Obliquus externus abdominis',
      ]);
      expect(base.musclesSecondary.map((e) => e.name), [
        'Biceps femoris',
        'Brachialis',
        'Obliquus externus abdominis',
      ]);
      expect(base.images.map((e) => e.uuid), [
        '1f5d2b2f-d4ea-4eeb-9377-56176465e08d',
        'ab645585-26ef-4992-a9ec-15425687ece9',
        'd8aa5990-bb47-4111-9823-e2fbd98fe07f',
        '49a159e1-1e00-409a-81c9-b4d4489fbd67'
      ]);
      expect(base.videos.map((v) => v.uuid), ['63e996e9-a772-4ca5-9d09-8b4be03f6be4']);

      final exercise1 = base.translations[0];
      expect(exercise1.name, '2 Handed Kettlebell Swing');
      expect(exercise1.languageObj.shortName, 'en');
      expect(exercise1.notes[0].comment, "it's important to do the exercise correctly");
      expect(exercise1.notes[1].comment, 'put a lot of effort into this exercise');
      expect(exercise1.notes[2].comment, 'have fun');
      expect(exercise1.aliases[0].alias, 'double handed kettlebell');
      expect(exercise1.aliases[1].alias, 'Kettlebell russian style');
      expect(base.translations[1].name, 'Kettlebell Con Dos Manos');
      expect(base.translations[2].name, 'Zweihändiges Kettlebell');
    });
  });
}
