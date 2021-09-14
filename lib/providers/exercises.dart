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
import 'package:wger/models/exercises/base.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/exercises/exercise2.dart';
import 'package:wger/models/exercises/muscle.dart';
import 'package:wger/providers/base_provider.dart';

class ExercisesProvider with ChangeNotifier {
  final WgerBaseProvider baseProvider;

  static const daysToCache = 7;

  static const _exerciseInfoUrlPath = 'exerciseinfo';
  static const _exerciseBaseUrlPath = 'exercise-base';
  static const _exerciseTranslationUrlPath = 'exercise-translation';
  static const _exerciseSearchPath = 'exercise/search';

  static const _exerciseCommentUrlPath = 'exercisecomment';
  static const _exerciseImagesUrlPath = 'exerciseimage';
  static const _categoriesUrlPath = 'exercisecategory';
  static const _musclesUrlPath = 'muscle';
  static const _equipmentUrlPath = 'equipment';

  List<Exercise> _exercises = [];
  List<ExerciseCategory> _categories = [];
  List<Muscle> _muscles = [];
  List<Equipment> _equipment = [];

  Filters? _filters;
  Filters? get filters => _filters;
  set filters(Filters? newFilters) {
    _filters = newFilters;
    this._findByFilters();
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

  // Initialze filters for exersices search in exersices list
  void _initFilters() {
    if (_muscles.isEmpty || _equipment.isEmpty || _filters != null) return;

    filters = Filters(
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
    );
  }

  Future<void> _findByFilters() async {
    // Filters not initalized
    if (filters == null) filteredExercises = [];

    // Filters are initialized and nothing is marked
    if (filters!.isNothingMarked && filters!.searchTerm.length <= 1) filteredExercises = items;

    filteredExercises = null;

    final filteredItems =
        filters!.searchTerm.length <= 1 ? items : await searchExercise(filters!.searchTerm);

    // Filter by exercise category and equipment (REPLACE WITH HTTP REQUEST)
    filteredExercises = filteredItems.where((exercise) {
      final bool isInAnyCategory =
          filters!.exerciseCategories.selected.contains(exercise.categoryObj);

      final bool doesContainAnyEquipment = filters!.equipment.selected.any(
        (selectedEquipment) => exercise.equipment.contains(selectedEquipment),
      );

      return (isInAnyCategory || filters!.exerciseCategories.selected.length == 0) &&
          (doesContainAnyEquipment || filters!.equipment.selected.length == 0);
    }).toList();
  }

  List<Exercise> findByCategory(ExerciseCategory? category) {
    if (category == null) return this.items;
    return this.items.where((exercise) => exercise.categoryObj == category).toList();
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

  /// Find category by ID
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

  Future<void> fetchAndSetCategories() async {
    final categories = await baseProvider.fetch(baseProvider.makeUrl(_categoriesUrlPath));
    try {
      for (final category in categories['results']) {
        _categories.add(ExerciseCategory.fromJson(category));
      }
    } catch (error) {
      throw (error);
    }
  }

  Future<void> fetchAndSetMuscles() async {
    final muscles = await baseProvider.fetch(baseProvider.makeUrl(_musclesUrlPath));
    try {
      for (final muscle in muscles['results']) {
        _muscles.add(Muscle.fromJson(muscle));
      }
    } catch (error) {
      throw (error);
    }
  }

  Future<void> fetchAndSetEquipment() async {
    final equipments = await baseProvider.fetch(baseProvider.makeUrl(_equipmentUrlPath));
    try {
      for (final equipment in equipments['results']) {
        _equipment.add(Equipment.fromJson(equipment));
      }
    } catch (error) {
      throw (error);
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
    } on StateError {
      // Get exercise from the server and save to cache

      final data =
          await baseProvider.fetch(baseProvider.makeUrl(_exerciseInfoUrlPath, id: exerciseId));
      final exercise = Exercise.fromJson(data);
      _exercises.add(exercise);
      final prefs = await SharedPreferences.getInstance();
      final exerciseData = json.decode(prefs.getString(PREFS_EXERCISES)!);
      exerciseData['exercises'].add(exercise.toJson());
      prefs.setString(PREFS_EXERCISES, json.encode(exerciseData));
      log("Saved exercise '${exercise.name}' to cache.");
      return exercise;
    }
  }

  Future<void> fetchAndSetExercisesTEST() async {
    // Load categories, muscles and equipments
    await fetchAndSetCategories();
    await fetchAndSetMuscles();
    await fetchAndSetEquipment();

    final exercisesData = await baseProvider.fetch(
      baseProvider.makeUrl(_exerciseBaseUrlPath, query: {'limit': '10'}),
    );

    exercisesData['results'].forEach((e) async {
      var base = ExerciseBase.fromJson(e);

      base.category = findCategoryById(base.categoryId);
      base.muscles = base.musclesIds.map((e) => findMuscleById(e)).toList();
      base.musclesSecondary = base.musclesSecondaryIds.map((e) => findMuscleById(e)).toList();
      base.equipment = base.equipmentIds.map((e) => findEquipmentById(e)).toList();

      final exerciseTranslationData = await baseProvider.fetch(
        baseProvider.makeUrl(
          _exerciseTranslationUrlPath,
          query: {'limit': '10', 'exercise_base': base.id.toString()},
        ),
      );

      exerciseTranslationData['results'].forEach((e) async {
        base.exercises.add(Exercise2.fromJson(e));
      });
    });
  }

  Future<void> fetchAndSetExercises() async {
    // Load exercises from cache, if available
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(PREFS_EXERCISES)) {
      final exerciseData = json.decode(prefs.getString(PREFS_EXERCISES)!);
      if (DateTime.parse(exerciseData['expiresIn']).isAfter(DateTime.now())) {
        exerciseData['exercises'].forEach((e) => _exercises.add(Exercise.fromJson(e)));
        exerciseData['equipment'].forEach((e) => _equipment.add(Equipment.fromJson(e)));
        exerciseData['muscles'].forEach((e) => _muscles.add(Muscle.fromJson(e)));
        exerciseData['categories'].forEach((e) => _categories.add(ExerciseCategory.fromJson(e)));
        _initFilters();
        log("Read ${exerciseData['exercises'].length} exercises from cache. Valid till ${exerciseData['expiresIn']}");
        return;
      }
    }

    // Load categories, muscles and equipments
    await fetchAndSetCategories();
    await fetchAndSetMuscles();
    await fetchAndSetEquipment();

    final exercisesData = await baseProvider.fetch(
      baseProvider.makeUrl(_exerciseInfoUrlPath, query: {'limit': '1000'}),
    );

    try {
      // Load exercises
      exercisesData['results'].forEach((e) => _exercises.add(Exercise.fromJson(e)));

      // Save the result to the cache
      final exerciseData = {
        'date': DateTime.now().toIso8601String(),
        'expiresIn': DateTime.now().add(Duration(days: daysToCache)).toIso8601String(),
        'exercises': _exercises.map((e) => e.toJson()).toList(),
        'equipment': _equipment.map((e) => e.toJson()).toList(),
        'categories': _categories.map((e) => e.toJson()).toList(),
        'muscles': _muscles.map((e) => e.toJson()).toList(),
      };
      log("Saved ${_exercises.length} exercises from cache. Valid till ${exerciseData['expiresIn']}");

      prefs.setString(PREFS_EXERCISES, json.encode(exerciseData));
      _initFilters();
      notifyListeners();
    } on MissingRequiredKeysException catch (error) {
      log(error.missingKeys.toString());
      throw (error);
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
    final isExersiceCategoryMarked = exerciseCategories.items.values.any((isMarked) => isMarked);
    final isEquipmentMarked = equipment.items.values.any((isMarked) => isMarked);
    return !isExersiceCategoryMarked && !isEquipmentMarked;
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
