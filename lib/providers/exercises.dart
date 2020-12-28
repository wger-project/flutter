/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/exercises/muscle.dart';
import 'package:wger/providers/auth.dart';
import 'package:wger/providers/base_provider.dart';

class Exercises extends WgerBaseProvider with ChangeNotifier {
  static const daysToCache = 7;

  static const _exercisesUrlPath = 'exerciseinfo';
  static const _exerciseCommentUrlPath = 'exercisecomment';
  static const _exerciseImagesUrlPath = 'exerciseimage';
  static const _categoriesUrlPath = 'exercisecategory';
  static const _musclesUrlPath = 'muscle';
  static const _equipmentUrlPath = 'equipment';

  List<Exercise> _exercises = [];
  List<ExerciseCategory> _categories = [];
  List<Muscle> _muscles = [];
  List<Equipment> _equipment = [];

  Exercises(Auth auth, List<Exercise> entries, [http.Client client])
      : this._exercises = entries,
        super(auth, client);

  List<Exercise> get items {
    return [..._exercises];
  }

  Exercise findById(int id) {
    return _exercises.firstWhere((exercise) => exercise.id == id);
  }

  Future<void> fetchAndSetCategories() async {
    final response = await client.get(makeUrl(_categoriesUrlPath));
    final categories = json.decode(response.body) as Map<String, dynamic>;
    try {
      for (final category in categories['results']) {
        _categories.add(ExerciseCategory.fromJson(category));
      }
    } catch (error) {
      throw (error);
    }
  }

  Future<void> fetchAndSetMuscles() async {
    final response = await client.get(makeUrl(_musclesUrlPath));
    final muscles = json.decode(response.body) as Map<String, dynamic>;
    try {
      for (final muscle in muscles['results']) {
        _muscles.add(Muscle.fromJson(muscle));
      }
    } catch (error) {
      throw (error);
    }
  }

  Future<void> fetchAndSetEquipment() async {
    final response = await client.get(makeUrl(_equipmentUrlPath));
    final equipments = json.decode(response.body) as Map<String, dynamic>;
    try {
      for (final equipment in equipments['results']) {
        _equipment.add(Equipment.fromJson(equipment));
      }
    } catch (error) {
      throw (error);
    }
  }

  Future<void> fetchAndSetExercises() async {
    // Load exercises from cache, if available
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('exerciseData')) {
      final exerciseData = json.decode(prefs.getString('exerciseData'));
      if (DateTime.parse(exerciseData['expiresIn']).isAfter(DateTime.now())) {
        exerciseData['exercises'].forEach((e) => _exercises.add(Exercise.fromJson(e)));
        exerciseData['equipment'].forEach((e) => _equipment.add(Equipment.fromJson(e)));
        exerciseData['muscles'].forEach((e) => _muscles.add(Muscle.fromJson(e)));
        exerciseData['categories'].forEach((e) => _categories.add(ExerciseCategory.fromJson(e)));
        log("Read exercise data from cache. Valid till ${exerciseData['expiresIn']}");
        return;
      }
    }

    // Load categories, muscles and equipments
    await fetchAndSetCategories();
    await fetchAndSetMuscles();
    await fetchAndSetEquipment();

    final response = await client.get(makeUrl(
      _exercisesUrlPath,
      query: {'language': '1', 'limit': '1000'}, // TODO: read the language ID from the locale
    ));
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    try {
      // Load exercises
      extractedData['results'].forEach((e) => _exercises.add(Exercise.fromJson(e)));

      // Save the result to the cache
      final exerciseData = {
        'date': DateTime.now().toIso8601String(),
        'expiresIn': DateTime.now().add(Duration(days: daysToCache)).toIso8601String(),
        'exercises': _exercises.map((e) => e.toJson()).toList(),
        'equipment': _equipment.map((e) => e.toJson()).toList(),
        'categories': _categories.map((e) => e.toJson()).toList(),
        'muscles': _muscles.map((e) => e.toJson()).toList(),
      };

      prefs.setString('exerciseData', json.encode(exerciseData));
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }
}
