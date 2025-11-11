import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:wger/database/exercises/exercise_database.dart';
import 'package:wger/exceptions/no_such_entry_exception.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/shared_preferences.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/muscle.dart';
import 'package:wger/providers/exercises.dart';

import '../../test_data/exercises.dart' as data;
import '../../test_data/exercises.dart';
import '../fixtures/fixture_reader.dart';
import '../measurements/measurement_provider_test.mocks.dart';

void main() {
  late MockWgerBaseProvider mockBaseProvider;
  late ExercisesProvider provider;

  const String categoryUrl = 'exercisecategory';
  const String exerciseInfoUrl = 'exerciseinfo';
  const String muscleUrl = 'muscle';
  const String equipmentUrl = 'equipment';
  const String languageUrl = 'language';
  const String searchExerciseUrl = 'exercise/search';

  final Uri tCategoryEntriesUri = Uri(
    scheme: 'http',
    host: 'localhost',
    path: 'api/v2/$categoryUrl/',
  );

  final Uri tExerciseInfoUri = Uri(
    scheme: 'http',
    host: 'localhost',
    path: 'api/v2/$exerciseInfoUrl/1/',
  );

  final Uri tMuscleEntriesUri = Uri(
    scheme: 'http',
    host: 'localhost',
    path: 'api/v2/$muscleUrl/',
  );

  final Uri tEquipmentEntriesUri = Uri(
    scheme: 'http',
    host: 'localhost',
    path: 'api/v2/$equipmentUrl/',
  );

  final Uri tLanguageEntriesUri = Uri(
    scheme: 'http',
    host: 'localhost',
    path: 'api/v2/$languageUrl/',
  );

  final Uri tSearchByNameUri = Uri(
    scheme: 'http',
    host: 'localhost',
    path: 'api/v2/$searchExerciseUrl/',
  );

  const category1 = ExerciseCategory(id: 1, name: 'Arms');
  const muscle1 = Muscle(id: 1, name: 'Biceps brachii', nameEn: 'Biceps', isFront: true);

  final Map<String, dynamic> tCategoryMap = jsonDecode(
    fixture('exercises/category_entries.json'),
  );
  final Map<String, dynamic> tMuscleMap = jsonDecode(
    fixture('exercises/muscles_entries.json'),
  );
  final Map<String, dynamic> tEquipmentMap = jsonDecode(
    fixture('exercises/equipment_entries.json'),
  );
  final Map<String, dynamic> tLanguageMap = jsonDecode(
    fixture('exercises/language_entries.json'),
  );
  final Map<String, dynamic> tExerciseInfoMap = jsonDecode(
    fixture('exercises/exerciseinfo_response.json'),
  );

  setUpAll(() {
    // Needs to be configured here, setUp runs on every test, setUpAll only once
    //await ServiceLocator().configure();
  });

  setUp(() {
    mockBaseProvider = MockWgerBaseProvider();
    provider = ExercisesProvider(
      mockBaseProvider,
      database: ExerciseDatabase.inMemory(NativeDatabase.memory()),
    );
    provider.languages = [...testLanguages];

    /// Replacement for SharedPreferences.setMockInitialValues()
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

    // Mock categories
    when(mockBaseProvider.makeUrl(categoryUrl)).thenReturn(tCategoryEntriesUri);
    when(
      mockBaseProvider.fetchPaginated(tCategoryEntriesUri),
    ).thenAnswer((_) => Future.value(tCategoryMap['results']));

    // Mock muscles
    when(mockBaseProvider.makeUrl(muscleUrl)).thenReturn(tMuscleEntriesUri);
    when(
      mockBaseProvider.fetchPaginated(tMuscleEntriesUri),
    ).thenAnswer((_) => Future.value(tMuscleMap['results']));

    // Mock equipment
    when(mockBaseProvider.makeUrl(equipmentUrl)).thenReturn(tEquipmentEntriesUri);
    when(
      mockBaseProvider.fetchPaginated(tEquipmentEntriesUri),
    ).thenAnswer((_) => Future.value(tEquipmentMap['results']));

    // Mock languages
    when(
      mockBaseProvider.makeUrl(languageUrl, query: anyNamed('query')),
    ).thenReturn(tLanguageEntriesUri);
    when(
      mockBaseProvider.fetchPaginated(tLanguageEntriesUri),
    ).thenAnswer((_) => Future.value(tLanguageMap['results']));

    // Mock base info response
    when(mockBaseProvider.makeUrl(exerciseInfoUrl, id: 1)).thenReturn(tExerciseInfoUri);
    when(mockBaseProvider.makeUrl(exerciseInfoUrl, id: 2)).thenReturn(tExerciseInfoUri);
    when(
      mockBaseProvider.fetch(tExerciseInfoUri),
    ).thenAnswer((_) => Future.value(tExerciseInfoMap));
  });

  group('findCategoryById()', () {
    test('should return a category for an id', () async {
      // arrange
      await provider.fetchAndSetCategoriesFromApi();

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
      await provider.fetchAndSetMusclesFromApi();

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
      await provider.fetchAndSetEquipmentsFromApi();

      // act
      final result = provider.findEquipmentById(1);

      // assert
      expect(result, tEquipment1);
    });

    test('should throw a NoResultException if no equipment is found', () {
      // act & assert
      expect(() => provider.findEquipmentById(10), throwsA(isA<NoSuchEntryException>()));
    });
  });

  group('findLanguageById()', () {
    test('should return a language for an id', () async {
      // arrange
      await provider.fetchAndSetLanguagesFromApi();

      // act
      final result = provider.findLanguageById(1);

      // assert
      expect(result, tLanguage1);
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

        provider.exercises = data.getTestExercises();
      });

      test('Nothing is selected with no search term', () async {
        // arrange
        final Filters currentFilters = filters;

        // act
        await provider.setFilters(currentFilters);

        // assert
        verifyNever(provider.baseProvider.fetch(tSearchByNameUri));

        expect(provider.filteredExercises, data.getTestExercises());
      });

      test('A muscle is selected with no search term. Should find results', () async {
        // arrange
        final Filters tFilters = filters.copyWith(
          exerciseCategories: filters.exerciseCategories.copyWith(items: {data.tCategory1: true}),
        );

        // act
        await provider.setFilters(tFilters);

        // assert
        verifyNever(provider.baseProvider.fetch(tSearchByNameUri));
        expect(provider.filteredExercises, [data.getTestExercises()[0]]);
      });

      test('A muscle is selected with no search term. Should not find results', () async {
        // arrange
        final Filters tFilters = filters.copyWith(
          exerciseCategories: filters.exerciseCategories.copyWith(items: {data.tCategory5: true}),
        );

        // act
        await provider.setFilters(tFilters);

        // assert
        verifyNever(provider.baseProvider.fetch(tSearchByNameUri));
        expect(provider.filteredExercises, isEmpty);
      });

      test('An equipment is selected with no search term. Should find results', () async {
        // arrange
        final Filters tFilters = filters.copyWith(
          equipment: filters.equipment.copyWith(items: {data.tEquipment1: true}),
        );

        // act
        await provider.setFilters(tFilters);

        // assert
        verifyNever(provider.baseProvider.fetch(tSearchByNameUri));
        expect(provider.filteredExercises, [data.getTestExercises()[0]]);
      });

      test('An equipment is selected with no search term. Should not find results', () async {
        // arrange
        final Filters tFilters = filters.copyWith(
          equipment: filters.equipment.copyWith(items: {data.tEquipment3: true}),
        );

        // act
        await provider.setFilters(tFilters);

        // assert
        verifyNever(provider.baseProvider.fetch(tSearchByNameUri));
        expect(provider.filteredExercises, isEmpty);
      });

      test('A muscle and equipment is selected and there is a match', () async {
        // arrange
        final Filters tFilters = filters.copyWith(
          exerciseCategories: filters.exerciseCategories.copyWith(items: {data.tCategory2: true}),
          equipment: filters.equipment.copyWith(items: {data.tEquipment2: true}),
        );

        // act
        await provider.setFilters(tFilters);

        // assert
        verifyNever(provider.baseProvider.fetch(tSearchByNameUri));
        expect(provider.filteredExercises, [data.getTestExercises()[1]]);
      });

      test('A muscle and equipment is selected but no match', () async {
        // arrange
        final Filters tFilters = filters.copyWith(
          exerciseCategories: filters.exerciseCategories.copyWith(items: {data.tCategory2: true}),
          equipment: filters.equipment.copyWith(items: {tEquipment1: true}),
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
          const String tSearchTerm = 'press';
          const String tSearchLanguage = 'en';
          final Map<String, dynamic> query = {'term': tSearchTerm, 'language': tSearchLanguage};
          tSearchByNameUri = Uri(
            scheme: 'http',
            host: 'localhost',
            path: 'api/v2/$searchExerciseUrl/',
            queryParameters: query,
          );
          final Map<String, dynamic> tSearchResponse = jsonDecode(
            fixture('exercises/exercise_search_entries.json'),
          );

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
          final Filters tFilters = filters.copyWith(searchTerm: 'press');

          // act
          await provider.setFilters(tFilters);

          // assert
          verify(provider.baseProvider.fetch(tSearchByNameUri)).called(1);
          expect(
            provider.filteredExercises,
            [data.getTestExercises()[0], data.getTestExercises()[1]],
          );
        });
        test('Should find items from selection but should filter them by search term', () async {
          // arrange
          final Filters tFilters = filters.copyWith(
            searchTerm: 'press',
            exerciseCategories: filters.exerciseCategories.copyWith(items: {data.tCategory3: true}),
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

  group('local prefs', () {
    test('initCacheTimesLocalPrefs correctly initalises the cache values', () async {
      // arrange
      const initValue = '2023-01-01T00:00:00.000';
      final prefs = PreferenceHelper.asyncPref;

      // act
      await provider.initCacheTimesLocalPrefs();

      // assert
      expect(await prefs.getString(PREFS_LAST_UPDATED_MUSCLES), initValue);
      expect(await prefs.getString(PREFS_LAST_UPDATED_EQUIPMENT), initValue);
      expect(await prefs.getString(PREFS_LAST_UPDATED_CATEGORIES), initValue);
      expect(await prefs.getString(PREFS_LAST_UPDATED_LANGUAGES), initValue);
    });

    test('calling initCacheTimesLocalPrefs again does nothing', () async {
      // arrange
      final prefs = PreferenceHelper.asyncPref;
      const newValue = '2023-10-10T01:18:35.000';

      // act
      await provider.initCacheTimesLocalPrefs();
      await prefs.setString(PREFS_LAST_UPDATED_MUSCLES, newValue);
      await prefs.setString(PREFS_LAST_UPDATED_EQUIPMENT, newValue);
      await prefs.setString(PREFS_LAST_UPDATED_CATEGORIES, newValue);
      await prefs.setString(PREFS_LAST_UPDATED_LANGUAGES, newValue);
      await provider.initCacheTimesLocalPrefs();

      // Assert
      expect(await prefs.getString(PREFS_LAST_UPDATED_MUSCLES), newValue);
      expect(await prefs.getString(PREFS_LAST_UPDATED_EQUIPMENT), newValue);
      expect(await prefs.getString(PREFS_LAST_UPDATED_CATEGORIES), newValue);
      expect(await prefs.getString(PREFS_LAST_UPDATED_LANGUAGES), newValue);
    });

    test('calling initCacheTimesLocalPrefs with forceInit replaces the date', () async {
      // arrange
      final prefs = PreferenceHelper.asyncPref;
      const initValue = '2023-01-01T00:00:00.000';
      const newValue = '2023-10-10T01:18:35.000';

      // act
      await provider.initCacheTimesLocalPrefs();
      await prefs.setString(PREFS_LAST_UPDATED_MUSCLES, newValue);
      await prefs.setString(PREFS_LAST_UPDATED_EQUIPMENT, newValue);
      await prefs.setString(PREFS_LAST_UPDATED_CATEGORIES, newValue);
      await prefs.setString(PREFS_LAST_UPDATED_LANGUAGES, newValue);
      await provider.initCacheTimesLocalPrefs(forceInit: true);

      // Assert
      expect(await prefs.getString(PREFS_LAST_UPDATED_MUSCLES), initValue);
      expect(await prefs.getString(PREFS_LAST_UPDATED_EQUIPMENT), initValue);
      expect(await prefs.getString(PREFS_LAST_UPDATED_CATEGORIES), initValue);
      expect(await prefs.getString(PREFS_LAST_UPDATED_LANGUAGES), initValue);
    });
  });
}
