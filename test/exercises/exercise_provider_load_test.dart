import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/core/locator.dart';
import 'package:wger/database/exercises/exercise_database.dart';
import 'package:wger/models/exercises/exercise.dart';
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

  final Uri tExerciseBaseInfoUri2 = Uri(
    scheme: 'http',
    host: 'localhost',
    path: 'api/v2/$exerciseBaseInfoUrl/1/',
  );

  final Map<String, dynamic> tExerciseInfoMap = jsonDecode(
    fixture('exercises/exercisebaseinfo_response.json'),
  );

  setUpAll(() async {
    // Needs to be configured here, setUp runs on every test, setUpAll only once
    await ServiceLocator().configure();
  });

  setUp(() async {
    WidgetsFlutterBinding.ensureInitialized();
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

    mockBaseProvider = MockWgerBaseProvider();
    provider = ExercisesProvider(
      mockBaseProvider,
      database: ExerciseDatabase.inMemory(NativeDatabase.memory()),
    );
    provider.exercises = getTestExercises();
    provider.languages = [tLanguage1, tLanguage2, tLanguage3];

    // Mock base info response
    when(
      mockBaseProvider.makeUrl(exerciseBaseInfoUrl, id: 9),
    ).thenReturn(tExerciseBaseInfoUri);
    when(
      mockBaseProvider.makeUrl(exerciseBaseInfoUrl, id: 1),
    ).thenReturn(tExerciseBaseInfoUri2);

    when(mockBaseProvider.fetch(tExerciseBaseInfoUri))
        .thenAnswer((_) => Future.value(tExerciseInfoMap));
    when(mockBaseProvider.fetch(tExerciseBaseInfoUri2))
        .thenAnswer((_) => Future.value(tExerciseInfoMap));
  });

  group('Correctly loads and parses data from the server', () {
    test('test that fetchAndSetExerciseBase finds an existing base', () async {
      // arrange and act
      final base = await provider.fetchAndSetExercise(1);

      // assert
      verifyNever(provider.baseProvider.fetch(tExerciseBaseInfoUri2));
      expect(base.id, 1);
    });

    test('test that fetchAndSetExerciseBase fetches a new base', () async {
      // arrange and act
      final base = await provider.fetchAndSetExercise(9);

      // assert
      verify(provider.baseProvider.fetch(tExerciseBaseInfoUri));
      expect(base.id, 9);
    });

    test('Load the readExerciseBaseFromBaseInfo parse method', () {
      // arrange

      // arrange and act
      final exercise = Exercise.fromApiDataJson(
        tExerciseInfoMap,
        const [tLanguage1, tLanguage2, tLanguage3],
      );

      // assert
      expect(exercise.id, 9);
      expect(exercise.uuid, '1b020b3a-3732-4c7e-92fd-a0cec90ed69b');
      expect(exercise.categoryId, 10);
      expect(exercise.equipment.map((e) => e.name), ['Kettlebell']);
      expect(exercise.muscles.map((e) => e.name), [
        'Biceps femoris',
        'Brachialis',
        'Obliquus externus abdominis',
      ]);
      expect(exercise.musclesSecondary.map((e) => e.name), [
        'Biceps femoris',
        'Brachialis',
        'Obliquus externus abdominis',
      ]);
      expect(exercise.images.map((e) => e.uuid), [
        '1f5d2b2f-d4ea-4eeb-9377-56176465e08d',
        'ab645585-26ef-4992-a9ec-15425687ece9',
        'd8aa5990-bb47-4111-9823-e2fbd98fe07f',
        '49a159e1-1e00-409a-81c9-b4d4489fbd67'
      ]);
      expect(exercise.videos.map((v) => v.uuid), ['63e996e9-a772-4ca5-9d09-8b4be03f6be4']);

      final translation1 = exercise.translations[0];
      expect(translation1.name, '2 Handed Kettlebell Swing');
      expect(translation1.languageObj.shortName, 'en');
      expect(translation1.notes[0].comment, "it's important to do the exercise correctly");
      expect(translation1.notes[1].comment, 'put a lot of effort into this exercise');
      expect(translation1.notes[2].comment, 'have fun');
      expect(translation1.aliases[0].alias, 'double handed kettlebell');
      expect(translation1.aliases[1].alias, 'Kettlebell russian style');
      expect(exercise.translations[1].name, 'Kettlebell Con Dos Manos');
      expect(exercise.translations[2].name, 'Zweihändiges Kettlebell');
    });
  });
}
