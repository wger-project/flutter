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

class Exercises with ChangeNotifier {
  static const daysToCache = 7;

  static const exercisesUrl = '/api/v2/exerciseinfo/?language=1&limit=1000';
  static const exerciseCommentUrl = '/api/v2/exercisecomment/';
  static const exerciseImagesUrl = '/api/v2/exerciseimage/';
  static const categoriesUrl = '/api/v2/exercisecategory/';
  static const musclesUrl = '/api/v2/muscle/';
  static const equipmentUrl = '/api/v2/equipment/';

  String _urlExercises;
  String _urlCategories;
  String _urlMuscles;
  String _urlEquipment;
  List<Exercise> _entries = [];
  List<ExerciseCategory> _categories = [];
  List<Muscle> _muscles = [];
  List<Equipment> _equipment = [];

  Auth _auth;

  Exercises(Auth auth, List<Exercise> entries) {
    this._auth = auth;
    this._entries = entries;
    if (auth.serverUrl != null) {
      this._urlExercises = auth.serverUrl + exercisesUrl;
      this._urlCategories = auth.serverUrl + categoriesUrl;
      this._urlMuscles = auth.serverUrl + musclesUrl;
      this._urlEquipment = auth.serverUrl + equipmentUrl;
    }
  }

  List<Exercise> get items {
    return [..._entries];
  }

  Exercise findById(int id) {
    return _entries.firstWhere((exercise) => exercise.id == id);
  }

  Future<void> fetchAndSetCategories() async {
    final response = await http.get(_urlCategories);
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
    final response = await http.get(_urlMuscles);
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
    final response = await http.get(_urlEquipment);
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
    final List<Exercise> loadedExercises = [];

    // Load exercises from cache, if available
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('exerciseData')) {
      //if (false) {
      final exerciseData = json.decode(prefs.getString('exerciseData'));
      if (DateTime.parse(exerciseData['expiresIn']).isAfter(DateTime.now())) {
        exerciseData['results'].forEach((e) => _entries.add(Exercise.fromJson(e)));
        log("Read exercise data from cache. Valid till ${exerciseData['expiresIn']}");
        return;
      }
    }

    // Load categories, muscles and equipments
    await fetchAndSetCategories();
    await fetchAndSetMuscles();
    await fetchAndSetEquipment();

    final response = await http.get(_urlExercises);
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    try {
      // Load exercises
      extractedData['results'].forEach((e) => _entries.add(Exercise.fromJson(e)));

      // Save the result to the cache
      final exerciseData = {
        'date': DateTime.now().toIso8601String(),
        'expiresIn': DateTime.now().add(Duration(days: daysToCache)).toIso8601String(),
        'exercises': _entries.map((e) => e.toJson()).toList(),
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
