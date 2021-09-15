import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wger/exceptions/no_such_entry_exception.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/exercises/language.dart';
import 'package:wger/models/exercises/muscle.dart';
import 'package:wger/providers/exercises.dart';

import '../fixtures/fixture_reader.dart';
import '../measurements/measurement_provider_test.mocks.dart';
import '../../test_data/exercises.dart' as data;

main() {
  late MockWgerBaseProvider mockBaseProvider;
  late ExercisesProvider provider;

  String categoryUrl = 'exercisecategory';
  String muscleUrl = 'muscle';
  String equipmentUrl = 'equipment';
  String languageUrl = 'language';
  String exerciseBaseUrl = 'exercise-base';
  String searchExerciseUrl = 'exercise/search';

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

  Uri tSearchByNameUri = Uri(
    scheme: 'http',
    host: 'localhost',
    path: 'api/v2/$searchExerciseUrl/',
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

  group('findByFilters', () {
    test('Filters are null', () async {
      // arrange
      Filters? currentFilters;

      // arrange and act
      await provider.setFilters(currentFilters);

      // assert
      verifyNever(provider.baseProvider.fetch(tSearchByNameUri));
      expect(provider.filteredExercises, isEmpty);
    });

    group('Filters are not null', () {
      late Filters filters;
      setUp(() {
        SharedPreferences.setMockInitialValues({});

        filters = Filters(
          exerciseCategories: FilterCategory<ExerciseCategory>(title: 'Muscle Groups', items: {}),
          equipment: FilterCategory<Equipment>(title: 'Equipment', items: {}),
        );

        provider.exercises = data.getExercise();
      });

      test('Nothing is selected with no search term', () async {
        // arrange
        Filters currentFilters = filters;

        // act
        await provider.setFilters(currentFilters);

        // assert
        verifyNever(provider.baseProvider.fetch(tSearchByNameUri));
        expect(
          provider.filteredExercises,
          data.getExercise(),
        );
      });

      test('A muscle is selected with no search term. Should find results', () async {
        // arrange
        Filters tFilters = filters.copyWith(
          exerciseCategories: filters.exerciseCategories.copyWith(items: {category1: true}),
        );

        // act
        await provider.setFilters(tFilters);

        // assert
        verifyNever(provider.baseProvider.fetch(tSearchByNameUri));
        expect(provider.filteredExercises, [data.getExercise()[0]]);
      });

      test('A muscle is selected with no search term. Should not find results', () async {
        // arragne
        Filters tFilters = filters.copyWith(
          exerciseCategories: filters.exerciseCategories.copyWith(items: {data.category4: true}),
        );

        // act
        await provider.setFilters(tFilters);

        // assert
        verifyNever(provider.baseProvider.fetch(tSearchByNameUri));
        expect(provider.filteredExercises, isEmpty);
      });

      test('An equipment is selected with no search term. Should find results', () async {
        // arragne
        Filters tFilters = filters.copyWith(
          equipment: filters.equipment.copyWith(items: {data.equipment1: true}),
        );

        // act
        await provider.setFilters(tFilters);

        // assert
        verifyNever(provider.baseProvider.fetch(tSearchByNameUri));
        expect(provider.filteredExercises, [data.getExercise()[0]]);
      });

      test('An equipment is selected with no search term. Should not find results', () async {
        // arragne
        Filters tFilters = filters.copyWith(
          equipment: filters.equipment.copyWith(items: {data.equipment3: true}),
        );

        // act
        await provider.setFilters(tFilters);

        // assert
        verifyNever(provider.baseProvider.fetch(tSearchByNameUri));
        expect(provider.filteredExercises, isEmpty);
      });

      test('A muscle and equipment is selected and there is a match', () async {
        // arrange
        Filters tFilters = filters.copyWith(
          exerciseCategories: filters.exerciseCategories.copyWith(items: {data.category2: true}),
          equipment: filters.equipment.copyWith(items: {data.equipment2: true}),
        );

        // act
        await provider.setFilters(tFilters);

        // assert
        verifyNever(provider.baseProvider.fetch(tSearchByNameUri));
        expect(provider.filteredExercises, [data.getExercise()[1]]);
      });

      test('A muscle and equipment is selected but no match', () async {
        // arrange
        Filters tFilters = filters.copyWith(
          exerciseCategories: filters.exerciseCategories.copyWith(items: {data.category2: true}),
          equipment: filters.equipment.copyWith(items: {equipment1: true}),
        );

        // act
        await provider.setFilters(tFilters);

        // assert
        verifyNever(provider.baseProvider.fetch(tSearchByNameUri));
        expect(provider.filteredExercises, isEmpty);
      });

      group('Search term', () {
        late Uri tSearchByNameUri;
        setUp(() {
          String tSearchTerm = 'press';
          String tSearchLanguage = 'en';
          Map<String, dynamic> query = {'term': tSearchTerm, 'language': tSearchLanguage};
          tSearchByNameUri = Uri(
            scheme: 'http',
            host: 'localhost',
            path: 'api/v2/$searchExerciseUrl/',
            queryParameters: query,
          );
          Map<String, dynamic> tSearchResponse =
              jsonDecode(fixture('exercise_search_entries.json'));

          // Mock exercise search
          when(
            mockBaseProvider.makeUrl(
              searchExerciseUrl,
              query: {'term': tSearchTerm, 'language': tSearchLanguage},
            ),
          ).thenReturn(tSearchByNameUri);
          when(mockBaseProvider.fetch(tSearchByNameUri)).thenAnswer((_) async => tSearchResponse);
        });

        test('Should find results from search term', () async {
          // arrange
          Filters tFilters = filters.copyWith(searchTerm: 'press');

          // act
          await provider.setFilters(tFilters);

          // assert
          verify(provider.baseProvider.fetch(tSearchByNameUri)).called(1);
          expect(provider.filteredExercises, [data.getExercise()[0], data.getExercise()[1]]);
        });
        test('Should find items from selection but should filter them by search term', () async {
          // arrange
          Filters tFilters = filters.copyWith(
            searchTerm: 'press',
            exerciseCategories: filters.exerciseCategories.copyWith(items: {data.category3: true}),
          );

          // act
          await provider.setFilters(tFilters);

          // assert
          verify(provider.baseProvider.fetch(tSearchByNameUri)).called(1);
          expect(provider.filteredExercises, isEmpty);
        });
      });
    });
  });
}
