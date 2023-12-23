/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wger/core/locator.dart';
import 'package:wger/database/exercise_DB/exercise_database.dart';
import 'package:wger/exceptions/no_such_entry_exception.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/models/exercises/alias.dart';
import 'package:wger/models/exercises/base.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/comment.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/exercise_base_data.dart';
import 'package:wger/models/exercises/image.dart';
import 'package:wger/models/exercises/language.dart';
import 'package:wger/models/exercises/muscle.dart';
import 'package:wger/models/exercises/translation.dart';
import 'package:wger/models/exercises/variation.dart';
import 'package:wger/models/exercises/video.dart';
import 'package:wger/providers/base_provider.dart';

class ExercisesProvider with ChangeNotifier {
  final WgerBaseProvider baseProvider;

  ExercisesProvider(this.baseProvider);

  static const EXERCISE_CACHE_DAYS = 7;
  static const CACHE_VERSION = 4;

  static const _exerciseBaseInfoUrlPath = 'exercisebaseinfo';
  static const _exerciseSearchPath = 'exercise/search';

  static const _exerciseVariationsUrlPath = 'variation';
  static const _categoriesUrlPath = 'exercisecategory';
  static const _musclesUrlPath = 'muscle';
  static const _equipmentUrlPath = 'equipment';
  static const _languageUrlPath = 'language';

  List<ExerciseBase> _exerciseBases = [];

  set exerciseBases(List<ExerciseBase> exercisesBases) {
    _exerciseBases = exercisesBases;
  }

  List<ExerciseCategory> _categories = [];
  List<Muscle> _muscles = [];
  List<Equipment> _equipment = [];
  List<Language> _languages = [];
  List<Variation> _variations = [];

  Filters? _filters;

  Filters? get filters => _filters;

  Future<void> setFilters(Filters? newFilters) async {
    _filters = newFilters;
    await findByFilters();
  }

  List<ExerciseBase> _filteredExerciseBases = [];

  List<ExerciseBase> get filteredExerciseBases => _filteredExerciseBases;

  set filteredExerciseBases(List<ExerciseBase> newFilteredExercises) {
    _filteredExerciseBases = newFilteredExercises;
    notifyListeners();
  }

  Map<int, List<ExerciseBase>> get exerciseBasesByVariation {
    final Map<int, List<ExerciseBase>> variations = {};

    for (final base in _exerciseBases.where((e) => e.variationId != null)) {
      if (!variations.containsKey(base.variationId)) {
        variations[base.variationId!] = [];
      }

      variations[base.variationId]!.add(base);
    }

    return variations;
  }

  List<ExerciseBase> get bases => [..._exerciseBases];

  List<ExerciseCategory> get categories => [..._categories];

  List<Muscle> get muscles => [..._muscles];

  List<Equipment> get equipment => [..._equipment];

  List<Language> get languages => [..._languages];

  set languages(List<Language> languages) {
    _languages = languages;
  }

  // Initialize filters for exercises search in exercises list
  void _initFilters() {
    if (_muscles.isEmpty || _equipment.isEmpty || _filters != null) {
      return;
    }

    setFilters(
      Filters(
        exerciseCategories: FilterCategory<ExerciseCategory>(
          title: 'Category',
          items: Map.fromEntries(
            _categories.map(
              (category) => MapEntry<ExerciseCategory, bool>(category, false),
            ),
          ),
        ),
        equipment: FilterCategory<Equipment>(
          title: 'Equipment',
          items: Map.fromEntries(
            _equipment.map(
              (singleEquipment) => MapEntry<Equipment, bool>(singleEquipment, false),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> findByFilters() async {
    // Filters not initialized
    if (filters == null) {
      filteredExerciseBases = [];
      return;
    }

    // Filters are initialized and nothing is marked
    if (filters!.isNothingMarked && filters!.searchTerm.length <= 1) {
      filteredExerciseBases = _exerciseBases;
      return;
    }

    filteredExerciseBases = [];

    List<ExerciseBase> filteredItems = _exerciseBases;
    if (filters!.searchTerm.length > 1) {
      filteredItems = await searchExercise(filters!.searchTerm);
    }

    // Filter by exercise category and equipment (REPLACE WITH HTTP REQUEST)
    filteredExerciseBases = filteredItems.where((exercise) {
      final bool isInAnyCategory = filters!.exerciseCategories.selected.contains(exercise.category);

      final bool doesContainAnyEquipment = filters!.equipment.selected.any(
        (selectedEquipment) => exercise.equipment.contains(selectedEquipment),
      );

      return (isInAnyCategory || filters!.exerciseCategories.selected.isEmpty) &&
          (doesContainAnyEquipment || filters!.equipment.selected.isEmpty);
    }).toList();
  }

  /// Clears all lists
  void clear() {
    _equipment = [];
    _muscles = [];
    _categories = [];
    _languages = [];
    _exerciseBases = [];
  }

  /// Find exercise base by ID
  ExerciseBase findExerciseBaseById(int id) {
    return _exerciseBases.firstWhere(
      (base) => base.id == id,
      orElse: () => throw NoSuchEntryException(),
    );
  }

  /// Find exercise bases by variation IDs
  ///
  /// exerciseIdToExclude: the ID of the exercise to exclude from the list of
  /// returned exercises. Since this is typically called by one exercise, we are
  /// not interested in seeing that same exercise returned in the list of variations.
  /// If this parameter is not passed, all exercises are returned.
  List<ExerciseBase> findExerciseBasesByVariationId(int id, {int? exerciseBaseIdToExclude}) {
    var out = _exerciseBases.where((base) => base.variationId == id).toList();

    if (exerciseBaseIdToExclude != null) {
      out = out.where((e) => e.id != exerciseBaseIdToExclude).toList();
    }
    return out;
  }

  /// Find category by ID
  ExerciseCategory findCategoryById(int id) {
    return _categories.firstWhere(
      (cat) => cat.id == id,
      orElse: () => throw NoSuchEntryException(),
    );
  }

  /// Find equipment by ID
  Equipment findEquipmentById(int id) {
    return _equipment.firstWhere(
      (equipment) => equipment.id == id,
      orElse: () => throw NoSuchEntryException(),
    );
  }

  /// Find muscle by ID
  Muscle findMuscleById(int id) {
    return _muscles.firstWhere(
      (muscle) => muscle.id == id,
      orElse: () => throw NoSuchEntryException(),
    );
  }

  /// Find language by ID
  Language findLanguageById(int id) {
    return _languages.firstWhere(
      (language) => language.id == id,
      orElse: () => throw NoSuchEntryException(),
    );
  }

  Future<void> fetchAndSetCategories() async {
    final categories = await baseProvider.fetchPaginated(baseProvider.makeUrl(_categoriesUrlPath));
    for (final category in categories) {
      _categories.add(ExerciseCategory.fromJson(category));
    }
  }

  Future<void> fetchAndSetVariations() async {
    final variations =
        await baseProvider.fetchPaginated(baseProvider.makeUrl(_exerciseVariationsUrlPath));
    for (final variation in variations) {
      _variations.add(Variation.fromJson(variation));
    }
  }

  Future<void> fetchAndSetMuscles() async {
    final muscles = await baseProvider.fetchPaginated(baseProvider.makeUrl(_musclesUrlPath));

    for (final muscle in muscles) {
      _muscles.add(Muscle.fromJson(muscle));
    }
  }

  Future<void> fetchAndSetEquipment() async {
    final equipments = await baseProvider.fetchPaginated(baseProvider.makeUrl(_equipmentUrlPath));

    for (final equipment in equipments) {
      _equipment.add(Equipment.fromJson(equipment));
    }
  }

  Future<void> fetchAndSetLanguages() async {
    final languageData = await baseProvider.fetchPaginated(baseProvider.makeUrl(_languageUrlPath));

    for (final language in languageData) {
      _languages.add(Language.fromJson(language));
    }
  }

  /// Returns the exercise with the given ID
  ///
  /// If the exercise is not known locally, it is fetched from the server.
  /// This method is called when a workout is first loaded, after that the
  /// regular not-async getById method can be used
  Future<ExerciseBase> fetchAndSetExerciseBase(int exerciseBaseId) async {
    try {
      return findExerciseBaseById(exerciseBaseId);
    } on NoSuchEntryException {
      final baseData = await baseProvider.fetch(
        baseProvider.makeUrl(_exerciseBaseInfoUrlPath, id: exerciseBaseId),
      );

      final newBase = readExerciseBaseFromBaseInfo(ExerciseBaseData.fromJson(baseData));

      // TODO: save to cache. Since we can't easily generate the JSON, perhaps just reload?
      _exerciseBases.add(newBase);
      return newBase;
    }
  }

  /// Parses the response from the exercisebaseinfo endpoint and returns
  /// a full exercise base
  ExerciseBase readExerciseBaseFromBaseInfo(ExerciseBaseData baseData) {
    final List<Translation> exercises = [];
    for (final exerciseData in baseData.exercises) {
      final exercise = Translation(
        id: exerciseData.id,
        uuid: exerciseData.uuid,
        name: exerciseData.name,
        description: exerciseData.description,
        baseId: baseData.id,
      );
      exercise.aliases = exerciseData.aliases
          .map((e) => Alias(exerciseId: exercise.id ?? 0, alias: e.alias))
          .toList()
          .cast<Alias>();
      exercise.notes = exerciseData.notes;
      exercise.language = findLanguageById(exerciseData.languageId);
      exercises.add(exercise);
    }

    final exerciseBase = ExerciseBase(
      id: baseData.id,
      uuid: baseData.uuid,
      created: null,
      //creationDate: toDate(baseData['creation_date']),
      musclesSecondary: baseData.muscles,
      muscles: baseData.muscles,
      equipment: baseData.equipment,
      category: baseData.category,
      images: baseData.images,
      exercises: exercises,
      videos: baseData.videos,
    );

    return exerciseBase;
  }

  /// Checks the required cache version
  ///
  /// This is needed since the content of the exercise cache can change and we need
  /// to invalidate it as a result
  Future<void> checkExerciseCacheVersion() async {
    final prefs = await SharedPreferences.getInstance();
    final database = locator<ExerciseDatabase>();
    if (prefs.containsKey(PREFS_EXERCISE_CACHE_VERSION)) {
      final cacheVersion = prefs.getInt(PREFS_EXERCISE_CACHE_VERSION);

      // Cache has has a different version, reset
      if ((cacheVersion ?? 0) != CACHE_VERSION) {
        database.delete(database.exerciseTableItems).go();
        await prefs.remove(PREFS_EXERCISES);
      }
      await prefs.setInt(PREFS_EXERCISE_CACHE_VERSION, CACHE_VERSION);

      // Cache has no version key, reset
    } else {
      await prefs.remove(PREFS_EXERCISES);
      database.delete(database.exerciseTableItems).go();
      await prefs.setInt(PREFS_EXERCISE_CACHE_VERSION, CACHE_VERSION);
    }
  }

  Future<void> fetchAndSetExercises() async {
    clear();

    // Load exercises from cache, if available
    final database = locator<ExerciseDatabase>();

    // Only uncomment if need to delete the table, (only for testing purposes).
    // await database.delete(database.exerciseTableItems).go();
    // Fetch the list of rows from ExercisesDataTable. ExerciseTable is the Type of the Row
    final List<ExerciseTable> items = await database.select(database.exerciseTableItems).get();

    final prefs = await SharedPreferences.getInstance();
    await checkExerciseCacheVersion();
    final cacheData = json.decode(prefs.getString(PREFS_EXERCISES) ?? '{}');

    if (items.isNotEmpty) {
      if (DateTime.parse(cacheData['expiresIn']).isAfter(DateTime.now())) {
        for (final element in items) {
          if (element.equipment != null) {
            _equipment.add(element.equipment!);
          }
          if (element.muscle != null) {
            _muscles.add(element.muscle!);
          }
          if (element.variation != null) {
            _variations.add(element.variation!);
          }
          if (element.language != null) {
            _languages.add(element.language!);
          }
          if (element.category != null) {
            _categories.add(element.category!);
          }
          if (element.exercisebase != null) {
            _exerciseBases.add(element.exercisebase!);
          }
        }
        _initFilters();
        log("Read ${_exerciseBases.length} exercises from cache. Valid till ${cacheData['expiresIn']}");
        return;
      }
    }

    // Load categories, muscles, equipment and languages
    final data = await Future.wait<dynamic>([
      baseProvider.fetch(baseProvider.makeUrl(_exerciseBaseInfoUrlPath, query: {'limit': '1000'})),
      fetchAndSetCategories(),
      fetchAndSetMuscles(),
      fetchAndSetEquipment(),
      fetchAndSetLanguages(),
      fetchAndSetVariations(),
    ]);
    final List<dynamic> exerciseData = data[0]['results'];

    final List<ExerciseBaseData> exerciseBaseData =
        exerciseData.map((e) => ExerciseBaseData.fromJson(e)).toList();

    _exerciseBases =
        exerciseBaseData.map((e) => readExerciseBaseFromBaseInfo(e)).toList().cast<ExerciseBase>();
    try {
      // Save the result to the cache
      for (int i = 0; i < _exerciseBases.length; i++) {
        await database.into(database.exerciseTableItems).insert(
              ExerciseTableItemsCompanion.insert(
                category: (i < _categories.length) ? Value(_categories[i]) : const Value(null),
                equipment: (i < _equipment.length) ? Value(_equipment[i]) : const Value(null),
                exercisebase:
                    (i < _exerciseBases.length) ? Value(_exerciseBases[i]) : const Value(null),
                muscle: (i < _muscles.length) ? Value(_muscles[i]) : const Value(null),
                variation: (i < _variations.length) ? Value(_variations[i]) : const Value(null),
                language: (i < _languages.length) ? Value(_languages[i]) : const Value(null),
              ),
            );
      }
      // final List<ExerciseTable> items = await database.select(database.exerciseTableItems).get();
      final cacheData = {
        'expiresIn':
            DateTime.now().add(const Duration(days: EXERCISE_CACHE_DAYS)).toIso8601String(),
      };
      log("Saved ${_exerciseBases.length} exercises to cache. Valid till ${cacheData['expiresIn']}");

      await prefs.setString(PREFS_EXERCISES, json.encode(cacheData));
      _initFilters();
      notifyListeners();
    } on MissingRequiredKeysException catch (error) {
      log(error.missingKeys.toString());
      rethrow;
    }
  }

  /// Searches for an exercise
  ///
  /// We could do this locally, but the server has better text searching capabilities
  /// with postgresql.
  Future<List<ExerciseBase>> searchExercise(String name,
      {String languageCode = LANGUAGE_SHORT_ENGLISH, bool searchEnglish = false}) async {
    if (name.length <= 1) {
      return [];
    }

    final languages = [languageCode];
    if (searchEnglish && languageCode != LANGUAGE_SHORT_ENGLISH) {
      languages.add(LANGUAGE_SHORT_ENGLISH);
    }

    // Send the request
    final result = await baseProvider.fetch(
      baseProvider.makeUrl(
        _exerciseSearchPath,
        query: {'term': name, 'language': languages.join(',')},
      ),
    );

    // Process the response
    return Future.wait(
      (result['suggestions'] as List).map<Future<ExerciseBase>>(
        (entry) => fetchAndSetExerciseBase(entry['data']['base_id']),
      ),
    );
  }
}

class FilterCategory<T> {
  bool isExpanded;
  final Map<T, bool> items;
  final String title;

  List<T> get selected => [...items.keys].where((key) => items[key]!).toList();

  FilterCategory({
    required this.title,
    required this.items,
    this.isExpanded = false,
  });

  FilterCategory<T> copyWith({
    bool? isExpanded,
    Map<T, bool>? items,
    String? title,
  }) {
    return FilterCategory<T>(
      isExpanded: isExpanded ?? this.isExpanded,
      items: items ?? this.items,
      title: title ?? this.title,
    );
  }
}

class Filters {
  final FilterCategory<ExerciseCategory> exerciseCategories;
  final FilterCategory<Equipment> equipment;
  String searchTerm;

  Filters({
    required this.exerciseCategories,
    required this.equipment,
    this.searchTerm = '',
    bool doesNeedUpdate = false,
  }) : _doesNeedUpdate = doesNeedUpdate;

  List<FilterCategory> get filterCategories => [exerciseCategories, equipment];

  bool get isNothingMarked {
    final isExerciseCategoryMarked = exerciseCategories.items.values.any((isMarked) => isMarked);
    final isEquipmentMarked = equipment.items.values.any((isMarked) => isMarked);
    return !isExerciseCategoryMarked && !isEquipmentMarked;
  }

  bool _doesNeedUpdate = false;

  bool get doesNeedUpdate => _doesNeedUpdate;

  void markNeedsUpdate() {
    _doesNeedUpdate = true;
  }

  void markUpdated() {
    _doesNeedUpdate = false;
  }

  Filters copyWith({
    FilterCategory<ExerciseCategory>? exerciseCategories,
    FilterCategory<Equipment>? equipment,
    String? searchTerm,
    bool? doesNeedUpdate,
  }) {
    return Filters(
      exerciseCategories: exerciseCategories ?? this.exerciseCategories,
      equipment: equipment ?? this.equipment,
      searchTerm: searchTerm ?? this.searchTerm,
      doesNeedUpdate: doesNeedUpdate ?? this._doesNeedUpdate,
    );
  }
}
