import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import '../../test_data/exercises.dart';
import '../fixtures/fixture_reader.dart';

void main() {
  final Map<String, dynamic> tExerciseInfoMap = jsonDecode(
    fixture('exercises/exerciseinfo_response.json'),
  );

  group('Model tests', () {
    test('test getExercise', () {
      // arrange and act
      final base = getTestExercises()[1];

      // assert
      expect(base.getTranslation('en').id, 5);
      expect(base.getTranslation('en-UK').id, 5);
      expect(base.getTranslation('de').id, 4);
      expect(base.getTranslation('de-AT').id, 4);
      expect(base.getTranslation('fr').id, 3);
      expect(base.getTranslation('fr-FR').id, 3);
      expect(base.getTranslation('pt').id, 5); // English again
    });
  });
}
