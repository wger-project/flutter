import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/exceptions/no_such_entry_exception.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/language.dart';
import 'package:wger/models/exercises/muscle.dart';
import 'package:wger/providers/exercises.dart';

import '../fixtures/fixture_reader.dart';
import '../measurements/measurement_provider_test.mocks.dart';

main() {
  late MockWgerBaseProvider mockBaseProvider;
  late ExercisesProvider provider;

  String categoryUrl = 'exercisecategory';
  String muscleUrl = 'muscle';
  String equipmentUrl = 'equipment';
  String languageUrl = 'language';

  Uri tCategoryEntriesUri = Uri(
    scheme: 'http',
    host: 'localhost',
    path: 'api/v2/' + categoryUrl + '/',
  );

  Uri tMuscleEntriesUri = Uri(
    scheme: 'http',
    host: 'localhost',
    path: 'api/v2/' + muscleUrl + '/',
  );

  Uri tEquipmentEntriesUri = Uri(
    scheme: 'http',
    host: 'localhost',
    path: 'api/v2/' + equipmentUrl + '/',
  );

  Uri tLanguageEntriesUri = Uri(
    scheme: 'http',
    host: 'localhost',
    path: 'api/v2/' + languageUrl + '/',
  );

  final category1 = ExerciseCategory(id: 1, name: 'Arms');
  final muscle1 = Muscle(id: 1, name: 'Biceps brachii', isFront: true);
  final equipment1 = Equipment(id: 1, name: 'Barbell');
  final language1 = Language(id: 1, shortName: 'de', fullName: 'Deutsch');

  Map<String, dynamic> tCategoryMap = jsonDecode(fixture('exercise_category_entries.json'));
  Map<String, dynamic> tMuscleMap = jsonDecode(fixture('exercise_muscles_entries.json'));
  Map<String, dynamic> tEquipmentMap = jsonDecode(fixture('exercise_equipment_entries.json'));
  Map<String, dynamic> tLanguageMap = jsonDecode(fixture('exercise_language_entries.json'));

  setUp(() {
    mockBaseProvider = MockWgerBaseProvider();
    provider = ExercisesProvider(mockBaseProvider);

    // Mock categories
    when(mockBaseProvider.makeUrl(categoryUrl)).thenReturn(tCategoryEntriesUri);
    when(mockBaseProvider.fetch(tCategoryEntriesUri)).thenAnswer((_) => Future.value(tCategoryMap));

    // Mock muscles
    when(mockBaseProvider.makeUrl(muscleUrl)).thenReturn(tMuscleEntriesUri);
    when(mockBaseProvider.fetch(tMuscleEntriesUri)).thenAnswer((_) => Future.value(tMuscleMap));

    // Mock equipment
    when(mockBaseProvider.makeUrl(equipmentUrl)).thenReturn(tEquipmentEntriesUri);
    when(mockBaseProvider.fetch(tEquipmentEntriesUri))
        .thenAnswer((_) => Future.value(tEquipmentMap));

    // Mock languages
    when(mockBaseProvider.makeUrl(languageUrl)).thenReturn(tLanguageEntriesUri);
    when(mockBaseProvider.fetch(tLanguageEntriesUri)).thenAnswer((_) => Future.value(tLanguageMap));
  });

  group('findCategoryById()', () {
    test('should return a category for an id', () async {
      // arrange
      await provider.fetchAndSetCategories();

      // act
      final result = provider.findCategoryById(1);

      // assert
      expect(result, category1);
    });

    test('should throw a NoResultException if no category is found', () {
      // act & assert
      expect(() => provider.findCategoryById(3), throwsA(isA<NoSuchEntryException>()));
    });
  });

  group('findMuscleById()', () {
    test('should return a muscle for an id', () async {
      // arrange
      await provider.fetchAndSetMuscles();

      // act
      final result = provider.findMuscleById(1);

      // assert
      expect(result, muscle1);
    });

    test('should throw a NoResultException if no muscle is found', () {
      // act & assert
      expect(() => provider.findMuscleById(3), throwsA(isA<NoSuchEntryException>()));
    });
  });

  group('findEquipmentById()', () {
    test('should return an equipment for an id', () async {
      // arrange
      await provider.fetchAndSetEquipment();

      // act
      final result = provider.findEquipmentById(1);

      // assert
      expect(result, equipment1);
    });

    test('should throw a NoResultException if no equipment is found', () {
      // act & assert
      expect(() => provider.findEquipmentById(10), throwsA(isA<NoSuchEntryException>()));
    });
  });

  group('findLanguageById()', () {
    test('should return a language for an id', () async {
      // arrange
      await provider.fetchAndSetLanguages();

      // act
      final result = provider.findLanguageById(1);

      // assert
      expect(result, language1);
    });

    test('should throw a NoResultException if no equipment is found', () {
      // act & assert
      expect(() => provider.findLanguageById(10), throwsA(isA<NoSuchEntryException>()));
    });
  });
}
