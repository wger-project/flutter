import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:wger/models/exercises/exercise.dart';

import '../../test_data/exercises.dart';
import '../fixtures/fixture_reader.dart';

void main() {
  final Map<String, dynamic> tExerciseInfoMap = jsonDecode(
    fixture('exercises/exercisebaseinfo_response.json'),
  );

  group('Model tests', () {
    test('test getExercise', () async {
      // arrange and act
      final base = getTestExercises()[1];

      // assert
      expect(base.getExercise('en').id, 5);
      expect(base.getExercise('en-UK').id, 5);
      expect(base.getExercise('de').id, 4);
      expect(base.getExercise('de-AT').id, 4);
      expect(base.getExercise('fr').id, 3);
      expect(base.getExercise('fr-FR').id, 3);
      expect(base.getExercise('pt').id, 5); // English again
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
      expect(exercise.variationId, 25);
      expect(exercise.authors, ['Foo Bar']);
      expect(exercise.authorsGlobal, ['Foo Bar', 'tester McTestface', 'Mr. X']);
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
