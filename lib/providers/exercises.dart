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

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:wger/core/locator.dart';
import 'package:wger/database/exercises/exercise_database.dart';
import 'package:wger/exceptions/no_such_entry_exception.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/exercises/exercise_api.dart';
import 'package:wger/models/exercises/language.dart';
import 'package:wger/models/exercises/muscle.dart';
import 'package:wger/providers/base_provider.dart';

class ExercisesProvider with ChangeNotifier {
  final _logger = Logger('ExercisesProvider');

  final WgerBaseProvider baseProvider;
  ExerciseDatabase database;

  ExercisesProvider(this.baseProvider, {ExerciseDatabase? database})
    : database = database ?? locator<ExerciseDatabase>();

  static const EXERCISE_CACHE_DAYS = 7;
  static const CACHE_VERSION = 4;

  static const exerciseUrlPath = 'exercise';
  static const exerciseInfoUrlPath = 'exerciseinfo';

  static const categoriesUrlPath = 'exercisecategory';
  static const musclesUrlPath = 'muscle';
  static const equipmentUrlPath = 'equipment';
  static const languageUrlPath = 'language';

  List<Exercise> exercises = [];

  List<ExerciseCategory> _categories = [];
  List<Muscle> _muscles = [];
  List<Equipment> _equipment = [];
  List<Language> _languages = [];

  Map<int, List<Exercise>> get exerciseByVariation {
    final Map<int, List<Exercise>> variations = {};

    for (final exercise in exercises.where((e) => e.variationId != null)) {
      if (!variations.containsKey(exercise.variationId)) {
        variations[exercise.variationId!] = [];
      }

      variations[exercise.variationId]!.add(exercise);
    }

    return variations;
  }

  List<ExerciseCategory> get categories => [..._categories];

  List<Muscle> get muscles => [..._muscles];

  List<Equipment> get equipment => [..._equipment];

  List<Language> get languages => [..._languages];

  set languages(List<Language> languages) {
    _languages = languages;
  }

  /// Clears all lists
  void clear() {
    _equipment = [];
    _muscles = [];
    _categories = [];
    _languages = [];
    exercises = [];
  }

  /// Find exercise base by ID
  ///
  /// Note: prefer using the async `fetchAndSetExercise` method
  Exercise findExerciseById(int id) {
    return exercises.firstWhere(
      (exercise) => exercise.id == id,
      orElse: () => throw const NoSuchEntryException(),
    );
  }

  /// Find category by ID
  ExerciseCategory findCategoryById(int id) {
    return _categories.firstWhere(
      (cat) => cat.id == id,
      orElse: () => throw const NoSuchEntryException(),
    );
  }

  /// Find equipment by ID
  Equipment findEquipmentById(int id) {
    return _equipment.firstWhere(
      (equipment) => equipment.id == id,
      orElse: () => throw const NoSuchEntryException(),
    );
  }

  /// Find muscle by ID
  Muscle findMuscleById(int id) {
    return _muscles.firstWhere(
      (muscle) => muscle.id == id,
      orElse: () => throw const NoSuchEntryException(),
    );
  }

  /// Find language by ID
  Language findLanguageById(int id) {
    return _languages.firstWhere(
      (language) => language.id == id,
      orElse: () => throw const NoSuchEntryException(),
    );
  }

  Future<void> fetchAndSetCategoriesFromApi() async {
    _logger.info('Loading exercise categories from API');
    final categories = await baseProvider.fetchPaginated(baseProvider.makeUrl(categoriesUrlPath));
    for (final category in categories) {
      _categories.add(ExerciseCategory.fromJson(category));
    }
  }

  Future<void> fetchAndSetMusclesFromApi() async {
    _logger.info('Loading muscles from API');
    final muscles = await baseProvider.fetchPaginated(baseProvider.makeUrl(musclesUrlPath));

    for (final muscle in muscles) {
      _muscles.add(Muscle.fromJson(muscle));
    }
  }

  Future<void> fetchAndSetEquipmentsFromApi() async {
    _logger.info('Loading equipment from API');
    final equipments = await baseProvider.fetchPaginated(baseProvider.makeUrl(equipmentUrlPath));

    for (final equipment in equipments) {
      _equipment.add(Equipment.fromJson(equipment));
    }
  }

  Future<void> fetchAndSetLanguagesFromApi() async {
    _logger.info('Loading languages from API');

    final languageData = await baseProvider.fetchPaginated(baseProvider.makeUrl(languageUrlPath));

    for (final language in languageData) {
      _languages.add(Language.fromJson(language));
    }
  }

  Future<void> fetchAndSetAllExercises() async {
    _logger.info('Loading all exercises from API');
    final exerciseData = await baseProvider.fetchPaginated(
      baseProvider.makeUrl(exerciseUrlPath, query: {'limit': API_MAX_PAGE_SIZE}),
    );
    final exerciseIds = exerciseData.map<int>((e) => e['id'] as int).toSet();

    for (final exerciseId in exerciseIds) {
      await handleUpdateExerciseFromApi(database, exerciseId);
    }
  }

  /// Returns the exercise with the given ID
  ///
  /// If the exercise is not known locally, it is fetched from the server.
  Future<Exercise?> fetchAndSetExercise(int exerciseId) async {
    // _logger.finer('Fetching exercise $exerciseId');
    try {
      final exercise = findExerciseById(exerciseId);

      // _logger.finer('Found $exerciseId in provider list');

      // Note: no await since we don't care for the updated data right now. It
      // will be written to the db whenever the request finishes and we will get
      // the updated exercise the next time
      handleUpdateExerciseFromApi(database, exerciseId);

      return exercise;
    } on NoSuchEntryException {
      // _logger.finer('Exercise not found locally, fetching from the API');
      return handleUpdateExerciseFromApi(database, exerciseId);
    }
  }

  /// Handles updates to exercises from the server to the local database
  ///
  /// The current logic is:
  /// Is the exercise known locally:
  /// -> no: fetch and add to the DB
  /// -> yes: Do we need to re-fetch?
  ///    -> no: just return what we have in the DB
  ///    -> yes: fetch data and update if necessary
  Future<Exercise> handleUpdateExerciseFromApi(ExerciseDatabase database, int exerciseId) async {
    Exercise exercise;

    // NOTE: this should not be necessary anymore. We had a bug that would
    //       create duplicate entries in the database and should be fixed now.
    //       However, we keep it here for now to be on the safe side.
    //       In the future this can be replaced by a .getSingleOrNull()
    final exerciseResult = await (database.select(
      database.exercises,
    )..where((e) => e.id.equals(exerciseId))).get();

    ExerciseTable? exerciseDb;
    if (exerciseResult.isNotEmpty) {
      exerciseDb = exerciseResult.first;
    }

    // Note that this shouldn't happen anymore...
    if (exerciseResult.length > 1) {
      _logger.warning('Found ${exerciseResult.length} entries for exercise $exerciseId in the db');
    }

    // Exercise is already known locally
    if (exerciseDb != null) {
      final nextFetch = exerciseDb.lastFetched.add(const Duration(days: EXERCISE_CACHE_DAYS));
      exercise = Exercise.fromApiDataString(exerciseDb.data, _languages);

      // Fetch and update
      if (nextFetch.isBefore(DateTime.now())) {
        _logger.fine(
          'Re-fetching exercise $exerciseId from API since last fetch was ${exerciseDb.lastFetched}',
        );

        final apiData = await baseProvider.fetch(
          baseProvider.makeUrl(exerciseInfoUrlPath, id: exerciseId),
        );
        final exerciseApiData = ExerciseApiData.fromJson(apiData);

        // There have been changes on the server, update
        if (exerciseApiData.lastUpdateGlobal.isAfter(exerciseDb.lastUpdate)) {
          exercise = Exercise.fromApiData(exerciseApiData, _languages);

          await (database.update(database.exercises)..where((e) => e.id.equals(exerciseId))).write(
            ExercisesCompanion(
              data: Value(jsonEncode(apiData)),
              lastUpdate: Value(exercise.lastUpdateGlobal!),
              lastFetched: Value(DateTime.now()),
            ),
          );
          // Update last fetched date, otherwise we'll keep hitting the API
        } else {
          await (database.update(database.exercises)..where((e) => e.id.equals(exerciseId))).write(
            ExercisesCompanion(lastFetched: Value(DateTime.now())),
          );
        }
      }
      // New exercise, fetch and insert to DB
    } else {
      _logger.fine('New exercise $exerciseId, fetching from API');
      final exerciseData = await baseProvider.fetch(
        baseProvider.makeUrl(exerciseInfoUrlPath, id: exerciseId),
      );
      exercise = Exercise.fromApiDataJson(exerciseData, _languages);

      if (exerciseDb == null) {
        await database
            .into(database.exercises)
            .insert(
              ExercisesCompanion.insert(
                id: exercise.id!,
                data: jsonEncode(exerciseData),
                lastUpdate: exercise.lastUpdateGlobal!,
                lastFetched: DateTime.now(),
              ),
            );
        _logger.finer('Saved exercise ${exercise.id!} to db cache');
      }
    }

    // Either update or add the exercise to local list
    final index = exercises.indexWhere((exercise) => exercise.id == exerciseId);
    if (index != -1) {
      exercises[index] = exercise;
    } else {
      exercises.add(exercise);
    }

    return exercise;
  }
}
