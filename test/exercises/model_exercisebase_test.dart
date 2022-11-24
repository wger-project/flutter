import 'package:flutter_test/flutter_test.dart';

import '../../test_data/exercises.dart';

void main() {
  group('Model tests', () {
    test('test getExercise', () async {
      // arrange and act
      final base = getTestExerciseBases()[1];

      // assert
      expect(base.getExercise('en').id, 5);
      expect(base.getExercise('en-UK').id, 5);
      expect(base.getExercise('de').id, 4);
      expect(base.getExercise('de-AT').id, 4);
      expect(base.getExercise('fr').id, 3);
      expect(base.getExercise('fr-FR').id, 3);
      expect(base.getExercise('pt').id, 5); // English again
    });
  });
}
