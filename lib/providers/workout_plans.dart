import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/exercises/image.dart' as img;
import 'package:wger/models/workouts/day.dart';
import 'package:wger/models/workouts/set.dart';
import 'package:wger/models/workouts/setting.dart';
import 'package:wger/models/workouts/workout_plan.dart';
import 'package:wger/providers/auth.dart';

class WorkoutPlans with ChangeNotifier {
  static const workoutPlansUrl = '/api/v2/workout/';

  String _url;
  Auth _auth;
  List<WorkoutPlan> _entries = [];

  WorkoutPlans(Auth auth, List<WorkoutPlan> entries) {
    this._auth = auth;
    this._entries = entries;
    this._url = auth.serverUrl + workoutPlansUrl;
  }

  List<WorkoutPlan> get items {
    return [..._entries];
  }

  WorkoutPlan findById(int id) {
    return _entries.firstWhere((workoutPlan) => workoutPlan.id == id);
  }

  Future<void> fetchAndSetWorkouts() async {
    final response = await http.get(
      _url,
      headers: <String, String>{'Authorization': 'Token ${_auth.token}'},
    );
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    final List<WorkoutPlan> loadedWorkoutPlans = [];
    if (loadedWorkoutPlans == null) {
      return;
    }

    try {
      for (final entry in extractedData['results']) {
        loadedWorkoutPlans.add(WorkoutPlan(
          id: entry['id'],
          description: entry['comment'],
          creationDate: DateTime.parse(entry['creation_date']),
        ));
      }

      _entries = loadedWorkoutPlans;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<WorkoutPlan> fetchAndSetFullWorkout(int workoutId) async {
    String url = _auth.serverUrl + '/api/v2/workout/$workoutId/canonical_representation/';
    final response = await http.get(
      url,
      headers: <String, String>{'Authorization': 'Token ${_auth.token}'},
    );
    final extractedData = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

    try {
      WorkoutPlan workout = _entries.firstWhere((element) => element.id == workoutId);

      List<Day> days = [];
      for (final entry in extractedData['day_list']) {
        List<Set> sets = [];

        for (final set in entry['set_list']) {
          List<Setting> settings = [];

          for (final exerciseData in set['exercise_list']) {
            List<img.Image> images = [];

            for (final image in exerciseData['image_list']) {
              images.add(
                img.Image(
                  url: _auth.serverUrl + image["image"],
                  isMain: image['is_main'],
                ),
              );
            }

            // TODO: why are there exercises without a creation_date????
            // Update the database
            Exercise exercise = Exercise(
              id: exerciseData['obj']['id'],
              uuid: exerciseData['obj']['uuid'],
              creationDate: exerciseData['obj']['creation_date'] != null
                  ? DateTime.parse(exerciseData['obj']['creation_date'])
                  : null,
              name: exerciseData['obj']['name'],
              description: exerciseData['obj']['description'],
              images: images,
            );

            // Settings
            settings.add(
              Setting(
                id: exerciseData['setting_obj_list'][0]['id'],
                comment: exerciseData['setting_obj_list'][0]['comment'],
                reps: exerciseData['setting_obj_list'][0]['reps'],
                //weight: setting['setting_obj_list'][0]['weight'] == null
                //    ? ''
                //  : setting['setting_obj_list'][0]['weight'],
                repsText: exerciseData['setting_text'],
                exercise: exercise,
              ),
            );
          }

          // Sets
          sets.add(Set(
            id: set['obj']['id'],
            sets: set['obj']['sets'],
            order: set['obj']['order'],
            settings: settings,
          ));
        }

        // Days
        days.add(Day(
          id: entry['obj']['id'],
          description: entry['obj']['description'],
          sets: sets,
          daysOfWeek: [1, 3],
          //daysOfWeek: entry['obj']['day'],
        ));
      }
      workout.days = days;
      notifyListeners();

      return workout;
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(WorkoutPlan product) async {
    final productsUrl =
        'https://flutter-shop-a2335.firebaseio.com/products.json?auth=${_auth.token}';
    try {
      final response = await http.post(
        productsUrl,
        body: json.encode(
          {
            'description': product.description,
          },
        ),
      );
      final newProduct = WorkoutPlan(
        id: json.decode(response.body)['name'],
        creationDate: json.decode(response.body)['creation_date'],
        description: product.description,
      );
      _entries.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(int id, WorkoutPlan newProduct) async {
    final prodIndex = _entries.indexWhere((element) => element.id == id);
    if (prodIndex >= 0) {
      final url = 'https://flutter-shop-a2335.firebaseio.com/products/$id.json?auth=${_auth.token}';
      await http.patch(url,
          body: json.encode({
            'description': newProduct.description,
          }));
      _entries[prodIndex] = newProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(int id) async {
    final url = 'https://flutter-shop-a2335.firebaseio.com/products/$id.json?auth=${_auth.token}';
    final existingProductIndex = _entries.indexWhere((element) => element.id == id);
    var existingProduct = _entries[existingProductIndex];
    _entries.removeAt(existingProductIndex);
    notifyListeners();

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _entries.insert(existingProductIndex, existingProduct);
      notifyListeners();
      //throw HttpException();
    }
    existingProduct = null;
  }
}
