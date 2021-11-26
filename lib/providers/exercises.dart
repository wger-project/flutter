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

  static const EXERCISE_CACHE_DAYS = 7;
  static const CACHE_VERSION = 2;

  static const _exerciseInfoUrlPath = 'exerciseinfo';
  static const _exerciseBaseUrlPath = 'exercise-base';
  static const _exerciseUrlPath = 'exercise';
  static const _exerciseSearchPath = 'exercise/search';

  static const _exerciseVariationsUrlPath = 'variation';
  static const _exerciseCommentUrlPath = 'exercisecomment';
  static const _exerciseImagesUrlPath = 'exerciseimage';
  static const _exerciseAliasUrlPath = 'exercisealias';
  static const _categoriesUrlPath = 'exercisecategory';
  static const _musclesUrlPath = 'muscle';
  static const _equipmentUrlPath = 'equipment';
  static const _languageUrlPath = 'language';

  List<ExerciseBase> _exerciseBases = [];
  List<ExerciseCategory> _categories = [];
  List<Muscle> _muscles = [];
  List<Equipment> _equipment = [];
  List<Language> _languages = [];
  List<Variation> _variations = [];

  List<Exercise> _exercises = [];
  set exercises(List<Exercise> exercises) {
    _exercises = exercises;
  }

  Filters? _filters;
  Filters? get filters => _filters;
  Future<void> setFilters(Filters? newFilters) async {
    _filters = newFilters;
    await findByFilters();
  }

  List<Exercise>? _filteredExercises = [];
  List<Exercise>? get filteredExercises => _filteredExercises;
  set filteredExercises(List<Exercise>? newfilteredExercises) {
    _filteredExercises = newfilteredExercises;
    notifyListeners();
  }

  ExercisesProvider(this.baseProvider);

  List<Exercise> get items => [..._exercises];
  List<ExerciseCategory> get categories => [..._categories];

  // Initialize filters for exercises search in exercises list
  void _initFilters() {
    if (_muscles.isEmpty || _equipment.isEmpty || _filters != null) {
      return;
    }

    setFilters(
      Filters(
        exerciseCategories: FilterCategory<ExerciseCategory>(
          title: 'Muscle Groups',
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
      filteredExercises = [];
      return;
    }

    // Filters are initialized and nothing is marked
    if (filters!.isNothingMarked && filters!.searchTerm.length <= 1) {
      filteredExercises = items;
      return;
    }

    filteredExercises = null;

    final filteredItems =
        filters!.searchTerm.length <= 1 ? items : await searchExercise(filters!.searchTerm);

    // Filter by exercise category and equipment (REPLACE WITH HTTP REQUEST)
    filteredExercises = filteredItems.where((exercise) {
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

  List<Exercise> findByCategory(ExerciseCategory? category) {
    if (category == null) {
      return items;
    }
    return items.where((exercise) => exercise.category == category).toList();
  }

  /// Find exercise by ID
  Exercise findExerciseById(int id) {
    return _exercises.firstWhere(
      (exercise) => exercise.id == id,
      orElse: () => throw NoSuchEntryException(),
    );
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
  Future<Exercise> fetchAndSetExercise(int exerciseId) async {
    try {
      return findExerciseById(exerciseId);
    } on NoSuchEntryException {
      // Get exercise from the server and save to cache

      // TODO: do this right (and save to cache)
      final exerciseTranslationData = await baseProvider.fetch(
        baseProvider.makeUrl(
          _exerciseUrlPath,
          id: exerciseId,
        ),
      );
      final exercise = Exercise.fromJson(exerciseTranslationData);

      final exerciseBaseData = await baseProvider.fetch(
        baseProvider.makeUrl(_exerciseBaseUrlPath, id: exercise.baseId),
      );
      final base = ExerciseBase.fromJson(exerciseBaseData);
      //setExerciseBaseData(base, [exercise]);

      /*
      final prefs = await SharedPreferences.getInstance();

      final exerciseTranslationData = await baseProvider.fetch(
        baseProvider.makeUrl(
          _exerciseUrlPath,
          id: exerciseId,
        ),
      );

      final exercise = Exercise.fromJson(exerciseTranslationData);
      final exerciseBaseData = await baseProvider.fetch(
        baseProvider.makeUrl(_exerciseBaseUrlPath, id: exercise.baseId),
      );

      final base = setExerciseBaseData(ExerciseBase.fromJson(exerciseBaseData), [exercise]);

      //exerciseData['exercises'].add(exercise.toJson());
      //prefs.setString(PREFS_EXERCISES, json.encode(exerciseData));
      //log("Saved exercise '${exercise.name}' to cache.");

       */
      return exercise;
    }
  }

  List<ExerciseBase> mapImages(dynamic data, List<ExerciseBase> bases) {
    final List<ExerciseImage> images =
        data.map<ExerciseImage>((e) => ExerciseImage.fromJson(e)).toList();
    for (final b in bases) {
      b.images = images.where((image) => image.exerciseBaseId == b.id).toList();
    }
    return bases;
  }

  List<ExerciseBase> setBaseData(dynamic data, List<Exercise> exercises) {
    try {
      final bases = data.map<ExerciseBase>((e) {
        final base = ExerciseBase.fromJson(e);
        base.category = findCategoryById(base.categoryId);
        base.muscles = base.musclesIds.map((e) => findMuscleById(e)).toList();
        base.musclesSecondary = base.musclesSecondaryIds.map((e) => findMuscleById(e)).toList();
        base.equipment = base.equipmentIds.map((e) => findEquipmentById(e)).toList();
        return base;
      });
      return bases.toList();
    } catch (e) {
      rethrow;
    }
  }

  List<dynamic> mapBases(List<ExerciseBase> bases, List<Exercise> exercises) {
    try {
      List<Exercise> out = [];
      for (var base in bases) {
        final filteredExercises = exercises.where((e) => e.baseId == base.id);
        for (final exercise in filteredExercises) {
          exercise.base = base;
          base.exercises.add(exercise);
          out.add(exercise);
        }
      }
      return [bases, out];
    } catch (e) {
      rethrow;
    }
  }

  List<Exercise> mapLanguages(List<Exercise> exercises) {
    for (final exercise in exercises) {
      exercise.language = findLanguageById(exercise.languageId);
    }
    return exercises;
  }

  List<Exercise> mapAliases(dynamic data, List<Exercise> exercises) {
    final List<Alias> alias = data.map<Alias>((e) => Alias.fromJson(e)).toList();
    for (final e in alias) {
      exercises.firstWhere((exercise) => exercise.id == e.exerciseId).alias.add(e);
    }
    return exercises;
  }

  List<Exercise> mapComments(dynamic data, List<Exercise> exercises) {
    List<Comment> comments = data.map<Comment>((e) => Comment.fromJson(e)).toList();
    comments.forEach((e) {
      exercises.firstWhere((exercise) => exercise.id == e.exerciseId).tips.add(e);
    });
    return exercises;
  }

  /// Checks the required cache version
  ///
  /// This is needed since the content of the exercise cache can change and we need
  /// to invalidate it as a result
  Future<void> checkExerciseCacheVersion() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(PREFS_EXERCISE_CACHE_VERSION)) {
      final cacheVersion = prefs.getInt(PREFS_EXERCISE_CACHE_VERSION);
      if (cacheVersion! != CACHE_VERSION) {
        prefs.remove(PREFS_EXERCISES);
      }
      prefs.setInt(PREFS_EXERCISE_CACHE_VERSION, CACHE_VERSION);
    } else {
      prefs.remove(PREFS_EXERCISES);
      prefs.setInt(PREFS_EXERCISE_CACHE_VERSION, CACHE_VERSION);
    }
  }

  Future<void> fetchAndSetExercises() async {
    clear();
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

        _exercises =
            cacheData['exercise-translations'].map<Exercise>((e) => Exercise.fromJson(e)).toList();
        _exercises = mapComments(cacheData['exercise-comments'], _exercises);
        _exercises = mapAliases(cacheData['exercise-alias'], _exercises);
        _exercises = mapLanguages(_exercises);

        _exerciseBases = setBaseData(cacheData['bases'], _exercises);
        _exerciseBases = mapImages(cacheData['exercise-images'], _exerciseBases);
        final out = mapBases(_exerciseBases, _exercises);
        _exerciseBases = out[0];
        _exercises = out[1];

        _initFilters();
        log("Read ${_exerciseBases.length} exercises from cache. Valid till ${cacheData['expiresIn']}");
        return;
      }
    }

    // Load categories, muscles, equipment and languages
    final data = await Future.wait<dynamic>([
      baseProvider.fetch(baseProvider.makeUrl(_exerciseBaseUrlPath, query: {'limit': '1000'})),
      baseProvider.fetch(baseProvider.makeUrl(_exerciseUrlPath, query: {'limit': '1000'})),
      baseProvider.fetch(baseProvider.makeUrl(_exerciseCommentUrlPath, query: {'limit': '1000'})),
      baseProvider.fetch(baseProvider.makeUrl(_exerciseAliasUrlPath, query: {'limit': '1000'})),
      baseProvider.fetch(baseProvider.makeUrl(_exerciseImagesUrlPath, query: {'limit': '1000'})),
      fetchAndSetCategories(),
      fetchAndSetMuscles(),
      fetchAndSetEquipment(),
      fetchAndSetLanguages(),
      fetchAndSetVariations(),
    ]);
    final exerciseBaseData = data[0]['results'];
    final exerciseData = data[1]['results'];
    final commentsData = data[2]['results'];
    final aliasData = data[3]['results'];
    final imageData = data[4]['results'];

    // Load exercise
    _exercises = exerciseData.map<Exercise>((e) => Exercise.fromJson(e)).toList();
    _exercises = mapComments(commentsData, _exercises);
    _exercises = mapAliases(aliasData, _exercises);
    _exercises = mapLanguages(_exercises);

    _exerciseBases = setBaseData(exerciseBaseData, _exercises);
    _exerciseBases = mapImages(imageData, _exerciseBases);

    final out = mapBases(_exerciseBases, _exercises);
    _exerciseBases = out[0];
    _exercises = out[1];

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
        'exercise-translations': exerciseData,
        'exercise-comments': commentsData,
        'exercise-alias': aliasData,
        'exercise-images': imageData,
      };
      log("Saved ${_exercises.length} exercises to cache. Valid till ${cacheData['expiresIn']}");

      prefs.setString(PREFS_EXERCISES, json.encode(cacheData));
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
  Future<List<Exercise>> searchExercise(String name, [String languageCode = 'en']) async {
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
    return await Future.wait(
      (result['suggestions'] as List).map<Future<Exercise>>(
        (entry) => fetchAndSetExercise(entry['data']['id']),
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
