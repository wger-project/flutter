import 'package:flutter_test/flutter_test.dart';
import 'package:wger/models/exercises/exercise.dart';

import '../../test_data/exercises.dart';

void main() {
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

    test('getTranslation returns an empty placeholder when there are no translations', () {
      // arrange: an exercise can briefly have no translations during the
      // initial sync, or ship without any. getTranslation must not throw.
      const exercise = Exercise(id: 1, uuid: 'uuid', category: testCategoryArms);

      // act
      final translation = exercise.getTranslation('de-AT');

      // assert
      expect(translation.name, '');
      expect(translation.language.shortName, 'de');
    });
  });
}
