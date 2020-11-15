import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/exercises/muscle.dart';
import 'package:wger/providers/auth.dart';

class Exercises with ChangeNotifier {
  static const exercisesUrl = '/api/v2/exercise/?language=1&limit=1000';
  static const exerciseCommentUrl = '/api/v2/exercisecomment/';
  static const categoriesUrl = '/api/v2/exercisecategory/';
  static const musclesUrl = '/api/v2/muscle/';
  static const equipmentUrl = '/api/v2/equipment/';

  String _urlExercises;
  String _urlExercisesComment;
  String _urlCategories;
  String _urlMuscles;
  String _urlEquipment;
  List<Exercise> _entries = [];
  List<Category> _categories = [];
  List<Muscle> _muscles = [];
  List<Equipment> _equipment = [];
  Auth _auth;

  Exercises(Auth auth, List<Exercise> entries) {
    this._auth = auth;
    this._entries = entries;
    this._urlExercises = auth.serverUrl + exercisesUrl;
    this._urlExercisesComment = auth.serverUrl + exerciseCommentUrl;
    this._urlCategories = auth.serverUrl + categoriesUrl;
    this._urlMuscles = auth.serverUrl + musclesUrl;
    this._urlEquipment = auth.serverUrl + equipmentUrl;
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
        _categories.add(Category.fromJson(category));
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
    // TODO: Load exercises from cache
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('exerciseData')) {
      final exerciseData = json.decode(prefs.getString('exerciseData'));
    }

    await fetchAndSetCategories();
    await fetchAndSetMuscles();
    await fetchAndSetEquipment();

    final response = await http.get(
      _urlExercises,
      headers: <String, String>{'Authorization': 'Token ${_auth.token}'},
    );
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    final List<Exercise> loadedExercises = [];
    if (loadedExercises == null) {
      return;
    }

    try {
      for (final entry in extractedData['results']) {
        entry['category'] = _categories.firstWhere((cat) => cat.id == entry['category']).toJson();
        entry['muscles'] = entry['muscles']
            .map((e) => _muscles.firstWhere((muscle) => muscle.id == e).toJson())
            .toList();
        entry['muscles_secondary'] = entry['muscles_secondary']
            .map((e) => _muscles.firstWhere((muscle) => muscle.id == e).toJson())
            .toList();
        entry['equipment'] = entry['equipment']
            .map((e) => _equipment.firstWhere((equipment) => equipment.id == e).toJson())
            .toList();
        loadedExercises.add(Exercise.fromJson(entry));
      }

      _entries = loadedExercises;

      final exerciseData = {
        'date': DateTime.now().toIso8601String(),
        'expiresIn': DateTime.now().add(Duration(days: 7)).toIso8601String(),
        'exercises': _entries.map((e) => e.toJson()).toList()
      };
      prefs.setString('exerciseData', json.encode(exerciseData));

      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }
}
