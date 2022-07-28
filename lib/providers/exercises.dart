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

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wger/exceptions/no_such_entry_exception.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/models/exercises/alias.dart';
import 'package:wger/models/exercises/base.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/comment.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/exercises/image.dart';
import 'package:wger/models/exercises/language.dart';
import 'package:wger/models/exercises/muscle.dart';
import 'package:wger/models/exercises/variation.dart';
import 'package:wger/providers/base_provider.dart';

class ExercisesProvider with ChangeNotifier {
  final WgerBaseProvider baseProvider;
  ExercisesProvider(this.baseProvider);

  static const EXERCISE_CACHE_DAYS = 7;
  static const CACHE_VERSION = 4;
  static const daysToCache = 7;

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
    var out = _exerciseBases
        .where(
          (base) => base.variationId == id,
        )
        .toList();

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
    final categories = await baseProvider.fetch(baseProvider.makeUrl(_categoriesUrlPath));
    try {
      for (final category in categories['results']) {
        _categories.add(ExerciseCategory.fromJson(category));
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> fetchAndSetVariations() async {
    final variations = await baseProvider.fetch(baseProvider.makeUrl(_exerciseVariationsUrlPath));
    try {
      for (final variation in variations['results']) {
        _variations.add(Variation.fromJson(variation));
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> fetchAndSetMuscles() async {
    final muscles = await baseProvider.fetch(baseProvider.makeUrl(_musclesUrlPath));
    try {
      for (final muscle in muscles['results']) {
        _muscles.add(Muscle.fromJson(muscle));
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> fetchAndSetEquipment() async {
    final equipments = await baseProvider.fetch(baseProvider.makeUrl(_equipmentUrlPath));
    try {
      for (final equipment in equipments['results']) {
        _equipment.add(Equipment.fromJson(equipment));
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> fetchAndSetLanguages() async {
    final languageData = await baseProvider.fetch(baseProvider.makeUrl(_languageUrlPath));
    try {
      for (final language in languageData['results']) {
        _languages.add(Language.fromJson(language));
      }
    } catch (error) {
      rethrow;
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

      final newBase = readExerciseBaseFromBaseInfo(baseData);

      // TODO: save to cache. Since we can't easily generate the JSON, perhaps just reload?
      _exerciseBases.add(newBase);
      return newBase;
    }
  }

  /// Parses the response from the exercisebaseinfo endpoint and returns
  /// a full exercise base
  ExerciseBase readExerciseBaseFromBaseInfo(dynamic baseData) {
    final category = ExerciseCategory.fromJson(baseData['category']);
    final musclesPrimary = baseData['muscles'].map((e) => Muscle.fromJson(e)).toList();
    final musclesSecondary = baseData['muscles_secondary'].map((e) => Muscle.fromJson(e)).toList();
    final equipment = baseData['equipment'].map((e) => Equipment.fromJson(e)).toList();
    final images = baseData['images'].map((e) => ExerciseImage.fromJson(e)).toList();

    final List<Exercise> exercises = [];
    for (final exerciseData in baseData['exercises']) {
      final exercise = Exercise.fromJson(exerciseData);
      exercise.alias = exerciseData['aliases']
          .map((e) => Alias(exerciseId: exercise.id!, alias: e['alias']))
          .toList()
          .cast<Alias>();
      exercise.notes =
          exerciseData['notes'].map((e) => Comment.fromJson(e)).toList().cast<Comment>();
      exercise.baseId = baseData['id'];
      exercise.language = findLanguageById(exerciseData['language']);
      exercises.add(exercise);
    }

    final exerciseBase = ExerciseBase(
      id: baseData['id'],
      uuid: baseData['uuid'],
      creationDate: null,
      //creationDate: toDate(baseData['creation_date']),
      musclesSecondary: musclesSecondary.cast<Muscle>(),
      muscles: musclesPrimary.cast<Muscle>(),
      equipment: equipment.cast<Equipment>(),
      category: category,
      images: images.cast<ExerciseImage>(),
      exercises: exercises,
    );

    return exerciseBase;
  }

  /// Checks the required cache version
  ///
  /// This is needed since the content of the exercise cache can change and we need
  /// to invalidate it as a result
  Future<void> checkExerciseCacheVersion() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(PREFS_EXERCISE_CACHE_VERSION)) {
      final cacheVersion = prefs.getInt(PREFS_EXERCISE_CACHE_VERSION);

      // Cache has has a different version, reset
      if (cacheVersion! != CACHE_VERSION) {
        await prefs.remove(PREFS_EXERCISES);
      }
      await prefs.setInt(PREFS_EXERCISE_CACHE_VERSION, CACHE_VERSION);

      // Cache has no version key, reset
    } else {
      await prefs.remove(PREFS_EXERCISES);
      await prefs.setInt(PREFS_EXERCISE_CACHE_VERSION, CACHE_VERSION);
    }
  }

  Future<void> fetchAndSetExercises() async {
    clear();

    //fetchAndSetExerciseBase(9);

    // Load exercises from cache, if available
    final prefs = await SharedPreferences.getInstance();
    await checkExerciseCacheVersion();

    if (prefs.containsKey(PREFS_EXERCISES)) {
      final cacheData = json.decode(prefs.getString(PREFS_EXERCISES)!);
      if (DateTime.parse(cacheData['expiresIn']).isAfter(DateTime.now())) {
        cacheData['equipment'].forEach((e) => _equipment.add(Equipment.fromJson(e)));
        cacheData['muscles'].forEach((e) => _muscles.add(Muscle.fromJson(e)));
        cacheData['categories'].forEach((e) => _categories.add(ExerciseCategory.fromJson(e)));
        cacheData['languages'].forEach((e) => _languages.add(Language.fromJson(e)));
        cacheData['variations'].forEach((e) => _variations.add(Variation.fromJson(e)));
        cacheData['bases'].forEach((e) => _exerciseBases.add(readExerciseBaseFromBaseInfo(e)));

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
    final exerciseBaseData = data[0]['results'];

    _exerciseBases =
        exerciseBaseData.map((e) => readExerciseBaseFromBaseInfo(e)).toList().cast<ExerciseBase>();

    try {
      // Save the result to the cache
      final cacheData = {
        'date': DateTime.now().toIso8601String(),
        'expiresIn':
            DateTime.now().add(const Duration(days: EXERCISE_CACHE_DAYS)).toIso8601String(),
        'equipment': _equipment.map((e) => e.toJson()).toList(),
        'categories': _categories.map((e) => e.toJson()).toList(),
        'muscles': _muscles.map((e) => e.toJson()).toList(),
        'languages': _languages.map((e) => e.toJson()).toList(),
        'variations': _variations.map((e) => e.toJson()).toList(),
        'bases': exerciseBaseData,
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
  Future<List<ExerciseBase>> searchExercise(String name, [String languageCode = 'en']) async {
    if (name.length <= 1) {
      return [];
    }

    // Send the request
    final result = await baseProvider.fetch(
      baseProvider.makeUrl(
        _exerciseSearchPath,
        query: {'term': name, 'language': languageCode},
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
