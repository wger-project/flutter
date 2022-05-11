import 'package:flutter_test/flutter_test.dart';

import '../../test_data/exercises.dart';

void main() {
  group('Model tests', () {
    test('test getExercise', () async {
      // arrange and act
      final base = getTestExerciseBases()[0];

      // assert
      expect(base.getExercise('en').id, 2);
      expect(base.getExercise('en-UK').id, 2);
      expect(base.getExercise('de').id, 1);
      expect(base.getExercise('de-AT').id, 1);
      expect(base.getExercise('fr').id, 3);
      expect(base.getExercise('fr-FR').id, 3);
      expect(base.getExercise('pt').id, 2); // English again
    });
  });
}
