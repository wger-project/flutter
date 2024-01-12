import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wger/database/exercises/exercise_database.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/misc.dart';
import 'package:wger/models/exercises/exercise_api.dart';
import 'package:wger/models/exercises/muscle.dart';
import 'package:wger/providers/exercises.dart';

import '../../test_data/exercises.dart';
import '../fixtures/fixture_reader.dart';
import '../measurements/measurement_provider_test.mocks.dart';

void main() {
  late MockWgerBaseProvider mockBaseProvider;
  late ExercisesProvider provider;
  late ExerciseDatabase database;

  const String categoryUrl = 'exercisecategory';
  const String exerciseBaseInfoUrl = 'exercisebaseinfo';
  const String muscleUrl = 'muscle';
  const String equipmentUrl = 'equipment';
  const String languageUrl = 'language';

  final Uri tCategoryEntriesUri = Uri(
    scheme: 'http',
    host: 'localhost',
    path: 'api/v2/$categoryUrl/',
  );

  final Uri tExerciseInfoUri = Uri(
    scheme: 'http',
    host: 'localhost',
    path: 'api/v2/$exerciseBaseInfoUrl/',
  );

  final Uri tExerciseInfoDetailUri = Uri(
    scheme: 'http',
    host: 'localhost',
    path: 'api/v2/$exerciseBaseInfoUrl/9/',
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

  const muscle1 = Muscle(id: 1, name: 'Biceps brachii', nameEn: 'Biceps', isFront: true);
  const muscle2 = Muscle(id: 2, name: 'Anterior deltoid', nameEn: 'Biceps', isFront: true);
  const muscle3 = Muscle(id: 4, name: 'Biceps femoris', nameEn: 'Hamstrings', isFront: false);

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
  final Map<String, dynamic> tExerciseBaseInfoMap = jsonDecode(
    fixture('exercises/exercisebaseinfo_response.json'),
  );

  setUp(() {
    mockBaseProvider = MockWgerBaseProvider();
    provider = ExercisesProvider(
      mockBaseProvider,
      database: ExerciseDatabase.inMemory(NativeDatabase.memory()),
    );
    database = ExerciseDatabase.inMemory(NativeDatabase.memory());

    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

    // Mock categories
    when(mockBaseProvider.makeUrl(categoryUrl)).thenReturn(tCategoryEntriesUri);
    when(mockBaseProvider.fetchPaginated(tCategoryEntriesUri))
        .thenAnswer((_) => Future.value(tCategoryMap['results']));

    // Mock muscles
    when(mockBaseProvider.makeUrl(muscleUrl)).thenReturn(tMuscleEntriesUri);
    when(mockBaseProvider.fetchPaginated(tMuscleEntriesUri))
        .thenAnswer((_) => Future.value(tMuscleMap['results']));

    // Mock equipment
    when(mockBaseProvider.makeUrl(equipmentUrl)).thenReturn(tEquipmentEntriesUri);
    when(mockBaseProvider.fetchPaginated(tEquipmentEntriesUri))
        .thenAnswer((_) => Future.value(tEquipmentMap['results']));

    // Mock languages
    when(mockBaseProvider.makeUrl(languageUrl, query: anyNamed('query')))
        .thenReturn(tLanguageEntriesUri);
    when(mockBaseProvider.fetchPaginated(tLanguageEntriesUri)).thenAnswer(
      (_) => Future.value(tLanguageMap['results']),
    );

    // Mock base info response
    when(mockBaseProvider.makeUrl(exerciseBaseInfoUrl)).thenReturn(tExerciseInfoUri);
    when(mockBaseProvider.fetch(tExerciseInfoUri)).thenAnswer(
      (_) => Future.value(tExerciseBaseInfoMap),
    );

    when(mockBaseProvider.makeUrl(exerciseBaseInfoUrl, id: 9)).thenReturn(tExerciseInfoDetailUri);
    when(mockBaseProvider.fetch(tExerciseInfoDetailUri)).thenAnswer(
      (_) => Future.value(tExerciseBaseInfoMap),
    );
  });

  tearDown(() async {
    await database.close();
  });

  group('Muscles', () {
    test('that fetched data from the API is written to the DB', () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();
      await provider.initCacheTimesLocalPrefs();

      // Act
      await provider.fetchAndSetMuscles(database);

      // Assert
      final updateTime = DateTime.parse(prefs.getString(PREFS_LAST_UPDATED_MUSCLES)!);
      final valid = DateTime.now().add(const Duration(days: ExercisesProvider.EXERCISE_CACHE_DAYS));
      expect(updateTime.isSameDayAs(valid), true);

      final muscles = await database.select(database.muscles).get();

      verify(mockBaseProvider.fetchPaginated(any));

      expect(muscles[0].id, 2);
      expect(muscles[0].data, muscle2);

      expect(muscles[1].id, 1);
      expect(muscles[1].data, muscle1);

      expect(muscles[2].id, 4);
      expect(muscles[2].data, muscle3);

      expect(provider.muscles.length, 3);
      expect(provider.muscles[0], muscle2);
      expect(provider.muscles[1], muscle1);
      expect(provider.muscles[2], muscle3);
    });

    test('that if there is already valid data in the DB, the API is not hit', () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();
      await provider.initCacheTimesLocalPrefs();

      final valid = DateTime.now().add(const Duration(days: 1));
      prefs.setString(PREFS_LAST_UPDATED_MUSCLES, valid.toIso8601String());

      await database
          .into(database.muscles)
          .insert(MusclesCompanion.insert(id: muscle1.id, data: muscle1));
      await database
          .into(database.muscles)
          .insert(MusclesCompanion.insert(id: muscle2.id, data: muscle2));

      // Act
      await provider.fetchAndSetMuscles(database);

      // Assert
      final updateTime = DateTime.parse(prefs.getString(PREFS_LAST_UPDATED_MUSCLES)!);
      expect(updateTime.isSameDayAs(valid), true);

      expect(provider.muscles.length, 2);
      expect(provider.muscles[0], muscle1);
      expect(provider.muscles[1], muscle2);

      verifyNever(mockBaseProvider.fetchPaginated(any));
    });
  });

  group('Languages', () {
    test('that fetched data from the API is written to the DB', () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();
      await provider.initCacheTimesLocalPrefs();

      // Act
      await provider.fetchAndSetLanguages(database);

      // Assert
      final updateTime = DateTime.parse(prefs.getString(PREFS_LAST_UPDATED_LANGUAGES)!);
      final valid = DateTime.now().add(const Duration(days: ExercisesProvider.EXERCISE_CACHE_DAYS));
      expect(updateTime.isSameDayAs(valid), true);

      final languages = await database.select(database.languages).get();

      verify(mockBaseProvider.fetchPaginated(any));

      expect(languages[0].id, tLanguage1.id);
      expect(languages[0].data, tLanguage1);

      expect(languages[1].id, tLanguage2.id);
      expect(languages[1].data, tLanguage2);

      expect(languages[2].id, tLanguage4.id);
      expect(languages[2].data, tLanguage4);

      expect(languages[3].id, tLanguage3.id);
      expect(languages[3].data, tLanguage3);

      expect(provider.languages.length, 5);
      expect(provider.languages[0], tLanguage1);
      expect(provider.languages[1], tLanguage2);
      expect(provider.languages[2], tLanguage4);
      expect(provider.languages[3], tLanguage3);
    });

    test('that if there is already valid data in the DB, the API is not hit', () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();
      await provider.initCacheTimesLocalPrefs();

      final valid = DateTime.now().add(const Duration(days: 1));
      prefs.setString(PREFS_LAST_UPDATED_LANGUAGES, valid.toIso8601String());

      await database
          .into(database.languages)
          .insert(LanguagesCompanion.insert(id: tLanguage1.id, data: tLanguage1));
      await database
          .into(database.languages)
          .insert(LanguagesCompanion.insert(id: tLanguage2.id, data: tLanguage2));

      // Act
      await provider.fetchAndSetLanguages(database);

      // Assert
      final updateTime = DateTime.parse(prefs.getString(PREFS_LAST_UPDATED_LANGUAGES)!);
      expect(updateTime.isSameDayAs(valid), true);

      expect(provider.languages.length, 2);
      expect(provider.languages[0], tLanguage1);
      expect(provider.languages[1], tLanguage2);

      verifyNever(mockBaseProvider.fetchPaginated(any));
    });
  });
  group('Categories', () {
    test('that fetched data from the API is written to the DB', () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();
      await provider.initCacheTimesLocalPrefs();

      // Act
      await provider.fetchAndSetCategories(database);

      // Assert
      final updateTime = DateTime.parse(prefs.getString(PREFS_LAST_UPDATED_CATEGORIES)!);
      final valid = DateTime.now().add(const Duration(days: ExercisesProvider.EXERCISE_CACHE_DAYS));
      expect(updateTime.isSameDayAs(valid), true);

      final categories = await database.select(database.categories).get();

      verify(mockBaseProvider.fetchPaginated(any));

      expect(categories[0].id, tCategory1.id);
      expect(categories[0].data, tCategory1);

      expect(categories[1].id, tCategory2.id);
      expect(categories[1].data, tCategory2);

      expect(provider.categories.length, 2);
      expect(provider.categories[0], tCategory1);
      expect(provider.categories[1], tCategory2);
    });

    test('that if there is already valid data in the DB, the API is not hit', () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();
      await provider.initCacheTimesLocalPrefs();

      final valid = DateTime.now().add(const Duration(days: 1));
      prefs.setString(PREFS_LAST_UPDATED_CATEGORIES, valid.toIso8601String());

      await database
          .into(database.categories)
          .insert(CategoriesCompanion.insert(id: tCategory1.id, data: tCategory1));
      await database
          .into(database.categories)
          .insert(CategoriesCompanion.insert(id: tCategory2.id, data: tCategory2));

      // Act
      await provider.fetchAndSetCategories(database);

      // Assert
      final updateTime = DateTime.parse(prefs.getString(PREFS_LAST_UPDATED_CATEGORIES)!);
      expect(updateTime.isSameDayAs(valid), true);

      expect(provider.categories.length, 2);
      expect(provider.categories[0], tCategory1);
      expect(provider.categories[1], tCategory2);

      verifyNever(mockBaseProvider.fetchPaginated(any));
    });
  });

  group('Equipment', () {
    test('that fetched data from the API is written to the DB', () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();
      await provider.initCacheTimesLocalPrefs();

      // Act
      await provider.fetchAndSetEquipments(database);

      // Assert
      final updateTime = DateTime.parse(prefs.getString(PREFS_LAST_UPDATED_EQUIPMENT)!);
      final valid = DateTime.now().add(const Duration(days: ExercisesProvider.EXERCISE_CACHE_DAYS));
      expect(updateTime.isSameDayAs(valid), true);

      final equipmentList = await database.select(database.equipments).get();

      verify(mockBaseProvider.fetchPaginated(any));

      expect(equipmentList[0].id, tEquipment1.id);
      expect(equipmentList[0].data, tEquipment1);

      expect(equipmentList[1].id, tEquipment2.id);
      expect(equipmentList[1].data, tEquipment2);

      expect(provider.equipment.length, 4);
      expect(provider.equipment[0], tEquipment1);
      expect(provider.equipment[1], tEquipment2);
      expect(provider.equipment[2], tEquipment3);
      expect(provider.equipment[3], tEquipment4);
    });

    test('that if there is already valid data in the DB, the API is not hit', () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();
      await provider.initCacheTimesLocalPrefs();

      final valid = DateTime.now().add(const Duration(days: 1));
      prefs.setString(PREFS_LAST_UPDATED_EQUIPMENT, valid.toIso8601String());

      await database
          .into(database.equipments)
          .insert(EquipmentsCompanion.insert(id: tEquipment1.id, data: tEquipment1));
      await database
          .into(database.equipments)
          .insert(EquipmentsCompanion.insert(id: tCategory2.id, data: tEquipment2));

      // Act
      await provider.fetchAndSetEquipments(database);

      // Assert
      final updateTime = DateTime.parse(prefs.getString(PREFS_LAST_UPDATED_EQUIPMENT)!);
      expect(updateTime.isSameDayAs(valid), true);

      expect(provider.equipment.length, 2);
      expect(provider.equipment[0], tEquipment1);
      expect(provider.equipment[1], tEquipment2);

      verifyNever(mockBaseProvider.fetchPaginated(any));
    });
  });

  group('Exercises', () {
    test('that if there is already valid data in the DB, the API is not hit', () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();
      await provider.initCacheTimesLocalPrefs();
      final valid = DateTime.now().add(const Duration(days: 1));
      prefs.setString(PREFS_LAST_UPDATED_LANGUAGES, valid.toIso8601String());

      await database.into(database.exercises).insert(
            ExercisesCompanion.insert(
              id: tExerciseBaseInfoMap['id'],
              data: json.encode(tExerciseBaseInfoMap),
              lastUpdate: DateTime.parse(tExerciseBaseInfoMap['last_update_global']),
              lastFetched: DateTime.now(),
            ),
          );
      await database
          .into(database.languages)
          .insert(LanguagesCompanion.insert(id: tLanguage1.id, data: tLanguage1));
      await database
          .into(database.languages)
          .insert(LanguagesCompanion.insert(id: tLanguage2.id, data: tLanguage2));
      await database
          .into(database.languages)
          .insert(LanguagesCompanion.insert(id: tLanguage3.id, data: tLanguage3));

      // Act
      await provider.fetchAndSetLanguages(database);
      await provider.setExercisesFromDatabase(database);

      // Assert
      expect(provider.exercises.length, 1);
      expect(provider.exercises.first.id, 9);
      expect(provider.exercises.first.uuid, '1b020b3a-3732-4c7e-92fd-a0cec90ed69b');
      verifyNever(mockBaseProvider.fetchPaginated(any));
    });

    test('fetching a known exercise - no API refresh', () async {
      // Arrange
      provider.languages = testLanguages;
      await database.into(database.exercises).insert(
            ExercisesCompanion.insert(
              id: tExerciseBaseInfoMap['id'],
              data: json.encode(tExerciseBaseInfoMap),
              lastUpdate: DateTime.parse(tExerciseBaseInfoMap['last_update_global']),
              lastFetched: DateTime.now().subtract(const Duration(hours: 1)),
            ),
          );

      // Assert
      expect(provider.exercises.length, 0);

      // Act
      await provider.handleUpdateExerciseFromApi(database, 9);

      // Assert
      expect(provider.exercises.length, 1);
      expect(provider.exercises.first.id, 9);
      expect(provider.exercises.first.uuid, '1b020b3a-3732-4c7e-92fd-a0cec90ed69b');
      verifyNever(mockBaseProvider.fetch(any));
    });

    test('fetching a known exercise - needed API refresh - no new data', () async {
      // Arrange
      provider.languages = testLanguages;
      await database.into(database.exercises).insert(
            ExercisesCompanion.insert(
              id: tExerciseBaseInfoMap['id'],
              data: json.encode(tExerciseBaseInfoMap),
              lastUpdate: DateTime.parse(tExerciseBaseInfoMap['last_update_global']),
              lastFetched: DateTime.now().subtract(const Duration(days: 10)),
            ),
          );

      // Assert
      expect(provider.exercises.length, 0);

      // Act
      await provider.handleUpdateExerciseFromApi(database, 9);
      final exerciseDb = await (database.select(database.exercises)..where((e) => e.id.equals(9)))
          .getSingleOrNull();

      // Assert
      verify(mockBaseProvider.fetch(any));
      expect(provider.exercises.length, 1);
      expect(provider.exercises.first.id, 9);
      expect(provider.exercises.first.uuid, '1b020b3a-3732-4c7e-92fd-a0cec90ed69b');
      expect(exerciseDb!.lastFetched.isSameDayAs(DateTime.now()), true);
    });

    test('fetching a known exercise - needed API refresh - new data from API', () async {
      // Arrange
      provider.languages = testLanguages;
      final newData = Map.from(tExerciseBaseInfoMap);
      newData['uuid'] = 'bf6d5557-1c49-48fd-922e-75d11f81d4eb';

      await database.into(database.exercises).insert(
            ExercisesCompanion.insert(
              id: newData['id'],
              data: json.encode(newData),
              lastUpdate: DateTime(2023, 1, 1),
              lastFetched: DateTime.now().subtract(const Duration(days: 10)),
            ),
          );

      // Assert
      expect(provider.exercises.length, 0);

      // Act
      await provider.handleUpdateExerciseFromApi(database, 9);
      final exerciseDb = await (database.select(database.exercises)..where((e) => e.id.equals(9)))
          .getSingleOrNull();
      final exerciseData = ExerciseApiData.fromString(exerciseDb!.data);

      // Assert
      verify(mockBaseProvider.fetch(any));
      expect(provider.exercises.length, 1);
      expect(provider.exercises.first.id, 9);
      expect(provider.exercises.first.uuid, '1b020b3a-3732-4c7e-92fd-a0cec90ed69b');
      expect(exerciseDb.lastFetched.isSameDayAs(DateTime.now()), true);
      expect(exerciseData.uuid, '1b020b3a-3732-4c7e-92fd-a0cec90ed69b');
    });
  });
}
