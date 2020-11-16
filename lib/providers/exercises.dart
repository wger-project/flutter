import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/comment.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/exercises/image.dart' as img;
import 'package:wger/models/exercises/muscle.dart';
import 'package:wger/providers/auth.dart';

class Exercises with ChangeNotifier {
  static const exercisesUrl = '/api/v2/exercise/?language=1&limit=1000';
  static const exerciseCommentUrl = '/api/v2/exercisecomment/';
  static const exerciseImagesUrl = '/api/v2/exerciseimage/';
  static const categoriesUrl = '/api/v2/exercisecategory/';
  static const musclesUrl = '/api/v2/muscle/';
  static const equipmentUrl = '/api/v2/equipment/';

  String _urlExercises;
  String _urlExercisesComment;
  String _urlExercisesImage;
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
    this._urlExercisesImage = auth.serverUrl + exerciseImagesUrl;
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

  Future<List<Comment>> fetchAndSetComments(int exerciseId) async {
    List<Comment> _comments = [];

    final response = await http.get(_urlExercisesComment + '?exercise=$exerciseId');
    final comments = json.decode(response.body) as Map<String, dynamic>;
    try {
      for (final comment in comments['results']) {
        _comments.add(Comment.fromJson(comment));
      }
    } catch (error) {
      throw (error);
    }

    return _comments;
  }

  Future<List<img.Image>> fetchAndSetImages(int exerciseId) async {
    List<img.Image> _comments = [];

    final response = await http.get(_urlExercisesImage + '?exercise=$exerciseId');
    final images = json.decode(response.body) as Map<String, dynamic>;
    try {
      for (final image in images['results']) {
        _comments.add(img.Image.fromJson(image));
      }
    } catch (error) {
      throw (error);
    }

    return _comments;
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
    final List<Exercise> loadedExercises = [];

    // Load exercises from cache, if available
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('exerciseData')) {
      final exerciseData = json.decode(prefs.getString('exerciseData'));
      if (DateTime.parse(exerciseData['expiresIn']).isAfter(DateTime.now())) {
        for (final exercise in exerciseData['exercises']) {
          loadedExercises.add(Exercise.fromJson(exercise));
        }
        _entries = loadedExercises;
        log("Read exercise data from cache. Valid till ${exerciseData['expiresIn']}");
        return;
      }
    }

    // Load categories, muscles and equipments...
    await fetchAndSetCategories();
    await fetchAndSetMuscles();
    await fetchAndSetEquipment();

    final response = await http.get(_urlExercises);
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    // ... and now put all together
    try {
      for (final entry in extractedData['results']) {
        // Load comments for exercise
        final List<Comment> comments = await fetchAndSetComments(entry['id']);

        // Load images for exercise
        final List<img.Image> images = await fetchAndSetImages(entry['id']);

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
        entry['comments'] = comments.map((comment) => comment.toJson()).toList();
        entry['images'] = images.map((image) => image.toJson()).toList();
        loadedExercises.add(Exercise.fromJson(entry));
      }

      // Save the result to the cache
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
