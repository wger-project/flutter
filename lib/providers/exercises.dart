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
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wger/exceptions/http_exception.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/exercises/muscle.dart';
import 'package:wger/providers/auth.dart';
import 'package:wger/providers/base_provider.dart';

class ExercisesProvider extends WgerBaseProvider with ChangeNotifier {
  ExercisesProvider(AuthProvider auth, List<Exercise> entries, [http.Client? client])
      : _exercises = entries,
        super(auth, client);

  static const daysToCache = 7;

  static const exerciseInfoUrlPath = 'exerciseinfo';
  static const exerciseSearchPath = 'exercise/search';

  static const exerciseCommentUrlPath = 'exercisecomment';
  static const exerciseImagesUrlPath = 'exerciseimage';
  static const categoriesUrlPath = 'exercisecategory';
  static const musclesUrlPath = 'muscle';
  static const equipmentUrlPath = 'equipment';

  final List<Exercise> _exercises;
  final List<ExerciseCategory> _categories = [];
  final List<Muscle> _muscles = [];
  final List<Equipment> _equipment = [];

  List<Exercise> get items {
    return [..._exercises];
  }

  /// Returns an exercise
  Exercise findById(int exerciseId) {
    return _exercises.firstWhere((exercise) => exercise.id == exerciseId);
  }

  Future<void> fetchAndSetCategories() async {
    final response = await client.get(makeUrl(categoriesUrlPath));
    final categories = json.decode(response.body) as Map<String, dynamic>;
    try {
      for (final category in categories['results']) {
        _categories.add(ExerciseCategory.fromJson(category));
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> fetchAndSetMuscles() async {
    final response = await client.get(makeUrl(musclesUrlPath));
    final muscles = json.decode(response.body) as Map<String, dynamic>;
    try {
      for (final muscle in muscles['results']) {
        _muscles.add(Muscle.fromJson(muscle));
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> fetchAndSetEquipment() async {
    final response = await client.get(makeUrl(equipmentUrlPath));
    final equipments = json.decode(response.body) as Map<String, dynamic>;
    try {
      for (final equipment in equipments['results']) {
        _equipment.add(Equipment.fromJson(equipment));
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
      return findById(exerciseId);
    } on StateError {
      // Get exercise from the server and save to cache

      final data = await fetch(makeUrl(exerciseInfoUrlPath, id: exerciseId));
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
        log("Read ${exerciseData['exercises'].length} exercises from cache. Valid till ${exerciseData['expiresIn']}");
        return;
      }
    }

    // Load categories, muscles and equipments
    await fetchAndSetCategories();
    await fetchAndSetMuscles();
    await fetchAndSetEquipment();

    final response = await client.get(
        makeUrl(
          exerciseInfoUrlPath,
          query: {'limit': '1000'},
        ),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        });
    final exercisesData = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

    try {
      // Load exercises
      exercisesData['results'].forEach((e) => _exercises.add(Exercise.fromJson(e)));

      // Save the result to the cache
      final exerciseData = {
        'date': DateTime.now().toIso8601String(),
        'expiresIn': DateTime.now().add(const Duration(days: daysToCache)).toIso8601String(),
        'exercises': _exercises.map((e) => e.toJson()).toList(),
        'equipment': _equipment.map((e) => e.toJson()).toList(),
        'categories': _categories.map((e) => e.toJson()).toList(),
        'muscles': _muscles.map((e) => e.toJson()).toList(),
      };
      log("Saved ${_exercises.length} exercises from cache. Valid till ${exerciseData['expiresIn']}");

      prefs.setString(PREFS_EXERCISES, json.encode(exerciseData));
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
  Future<List> searchExercise(String name, [String languageCode = 'en']) async {
    if (name.length <= 1) {
      return [];
    }

    // Send the request
    final response = await client.get(
      makeUrl(
        exerciseSearchPath,
        query: {'term': name, 'language': languageCode},
      ),
      headers: <String, String>{
        'Authorization': 'Token ${auth.token}',
        'User-Agent': auth.getAppNameHeader(),
      },
    );

    // Something wrong with our request
    if (response.statusCode >= 400) {
      throw WgerHttpException(response.body);
    }

    // Process the response
    final result = json.decode(utf8.decode(response.bodyBytes))['suggestions'] as List<dynamic>;
    for (final entry in result) {
      entry['exercise_obj'] = await fetchAndSetExercise(entry['data']['id']);
    }
    return result;
  }
}
