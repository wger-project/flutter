import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/providers/exercises.dart';

import '../../test_data/exercises.dart';
import '../fixtures/fixture_reader.dart';
import '../measurements/measurement_provider_test.mocks.dart';

main() {
  late MockWgerBaseProvider mockBaseProvider;
  late ExercisesProvider provider;

  const String exerciseBaseInfoUrl = 'exercisebaseinfo';

  final Uri tExerciseBaseInfoUri = Uri(
    scheme: 'http',
    host: 'localhost',
    path: 'api/v2/$exerciseBaseInfoUrl/9/',
  );

  final Map<String, dynamic> tExerciseBaseInfoMap = jsonDecode(
    fixture('exercises/exercisebaseinfo_response.json'),
  );

  setUp(() {
    mockBaseProvider = MockWgerBaseProvider();
    provider = ExercisesProvider(mockBaseProvider);
    provider.exerciseBases = getTestExerciseBases();

    // Mock base info response
    when(
      mockBaseProvider.makeUrl(exerciseBaseInfoUrl, id: 9),
    ).thenReturn(tExerciseBaseInfoUri);
    when(mockBaseProvider.fetch(tExerciseBaseInfoUri))
        .thenAnswer((_) => Future.value(tExerciseBaseInfoMap));
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
      final base = provider.readExerciseBaseFromBaseInfo(tExerciseBaseInfoMap);

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
        'Anterior deltoid',
        'Trapezius',
      ]);
      expect(base.images.map((e) => e.uuid), [
        '1f5d2b2f-d4ea-4eeb-9377-56176465e08d',
        'ab645585-26ef-4992-a9ec-15425687ece9',
        'd8aa5990-bb47-4111-9823-e2fbd98fe07f',
        '49a159e1-1e00-409a-81c9-b4d4489fbd67'
      ]);

      expect(base.exercises[0].name, '2 Handed Kettlebell Swing');
      expect(base.exercises[1].name, 'Kettlebell Con Dos Manos');
      expect(base.exercises[2].name, 'Zweihändiges Kettlebell');
    });
  });
}
