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

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/exercises/image.dart';
import 'package:wger/models/workouts/day.dart';
import 'package:wger/models/workouts/set.dart';
import 'package:wger/models/workouts/setting.dart';
import 'package:wger/models/workouts/workout_plan.dart';
import 'package:wger/providers/auth.dart';

class WorkoutPlans with ChangeNotifier {
  static const workoutPlansUrl = '/api/v2/workout/';
  static const daysUrl = '/api/v2/day/';

  String _url;
  String _urlDays;
  Auth _auth;
  List<WorkoutPlan> _entries = [];

  WorkoutPlans(Auth auth, List<WorkoutPlan> entries) {
    this._auth = auth;
    this._entries = entries;
    this._url = auth.serverUrl + workoutPlansUrl;
    this._urlDays = auth.serverUrl + daysUrl;
  }

  List<WorkoutPlan> get items {
    return [..._entries];
  }

  WorkoutPlan findById(int id) {
    return _entries.firstWhere((workoutPlan) => workoutPlan.id == id);
  }

  /*
   * Workouts
   */
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
        loadedWorkoutPlans.add(WorkoutPlan.fromJson(entry));
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
            List<ExerciseImage> images = [];

            for (final image in exerciseData['image_list']) {
              images.add(
                ExerciseImage(
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
            daysOfWeek: [1, 3]
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

  Future<WorkoutPlan> addWorkout(WorkoutPlan workout) async {
    try {
      final response = await http.post(
        _url,
        headers: {
          'Authorization': 'Token ${_auth.token}',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(workout.toJson()),
      );
      workout = WorkoutPlan.fromJson(json.decode(response.body));
      _entries.insert(0, workout);
      notifyListeners();
      return workout;
    } catch (error) {
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

  Future<void> deleteWorkout(int id) async {
    final url = '$_url$id/';
    final existingWorkoutIndex = _entries.indexWhere((element) => element.id == id);
    var existingWorkout = _entries[existingWorkoutIndex];
    _entries.removeAt(existingWorkoutIndex);
    notifyListeners();

    final response = await http.delete(
      url,
      headers: {'Authorization': 'Token ${_auth.token}'},
    );
    if (response.statusCode >= 400) {
      _entries.insert(existingWorkoutIndex, existingWorkout);
      notifyListeners();
      //throw HttpException();
    }
    existingWorkout = null;
  }

  /*
   * Days
   */
  Future<Day> addDay(Day day, WorkoutPlan workout) async {
    /*
     * Saves a new day instance to the DB and adds it to the given workout
     */
    day.workoutId = workout.id;
    try {
      final response = await http.post(
        _urlDays,
        headers: {
          'Authorization': 'Token ${_auth.token}',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(day.toJson()),
      );

      // Create the day
      day = Day.fromJson(json.decode(response.body));
      day.sets = [];
      workout.days.insert(0, day);
      notifyListeners();
      return day;
    } catch (error) {
      log(error.missingKeys.toString());
      throw error;
    }
  }
}
