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

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/exercises/image.dart';
import 'package:wger/models/http_exception.dart';
import 'package:wger/models/workouts/day.dart';
import 'package:wger/models/workouts/log.dart';
import 'package:wger/models/workouts/set.dart';
import 'package:wger/models/workouts/setting.dart';
import 'package:wger/models/workouts/workout_plan.dart';
import 'package:wger/providers/auth.dart';
import 'package:wger/providers/base_provider.dart';

class WorkoutPlans extends WgerBaseProvider with ChangeNotifier {
  static const _workoutPlansUrlPath = 'workout';
  static const _daysUrlPath = 'day';
  static const _logsUrlPath = 'workoutlog';
  static const _sessionUrlPath = 'workoutsession';

  WorkoutPlan _currentPlan;
  List<WorkoutPlan> _workoutPlans = [];

  WorkoutPlans(Auth auth, List<WorkoutPlan> entries, [http.Client client])
      : this._workoutPlans = entries,
        super(auth, client);

  List<WorkoutPlan> get items {
    return [..._workoutPlans];
  }

  WorkoutPlan findById(int id) {
    return _workoutPlans.firstWhere((workoutPlan) => workoutPlan.id == id);
  }

  /// Set the currently "active" workout plan
  void setCurrentPlan(int id) {
    _currentPlan = findById(id);
  }

  /// Returns the currently "active" workout plan
  WorkoutPlan get currentPlan {
    return _currentPlan;
  }

  /// Reset the currently "active" workout plan to null
  void resetCurrentPlan() {
    _currentPlan = null;
  }

  /// Returns the current active workout plan. At the moment this is just
  /// the latest, but this might change in the future.
  WorkoutPlan get activePlan {
    return _workoutPlans.first;
  }

  /*
   * Workouts
   */
  Future<void> fetchAndSetWorkouts() async {
    final data = await fetch(makeUrl(_workoutPlansUrlPath, query: {'ordering': '-creation_date'}));
    final List<WorkoutPlan> loadedWorkoutPlans = [];

    for (final entry in data['results']) {
      loadedWorkoutPlans.add(WorkoutPlan.fromJson(entry));
    }

    _workoutPlans = loadedWorkoutPlans;
    notifyListeners();
  }

  Future<WorkoutPlan> fetchAndSetFullWorkout(int workoutId) async {
    final data = await fetch(makeUrl(
      _workoutPlansUrlPath,
      id: workoutId,
      objectMethod: 'canonical_representation',
    ));

    try {
      WorkoutPlan workout = _workoutPlans.firstWhere((element) => element.id == workoutId);

      List<Day> days = [];
      for (final entry in data['day_list']) {
        List<Set> sets = [];

        for (final set in entry['set_list']) {
          List<Setting> settings = [];
          List<Exercise> exercises = [];

          for (final exerciseData in set['exercise_list']) {
            List<ExerciseImage> images = [];

            for (final image in exerciseData['image_list']) {
              images.add(
                ExerciseImage(
                  url: auth.serverUrl + image["image"],
                  isMain: image['is_main'],
                ),
              );
            }

            Exercise exercise = Exercise(
              id: exerciseData['obj']['id'],
              uuid: exerciseData['obj']['uuid'],
              creationDate: DateTime.parse(exerciseData['obj']['creation_date']),
              name: exerciseData['obj']['name'],
              description: exerciseData['obj']['description'],
              images: images,
            );
            exercises.add(exercise);

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
            exercises: exercises,
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

      // Logs
      final logData = await fetch(makeUrl(_logsUrlPath));
      for (final entry in logData['results']) {
        workout.logs.add(Log.fromJson(entry));
      }
      notifyListeners();

      return workout;
    } catch (error) {
      throw (error);
    }
  }

  Future<WorkoutPlan> addWorkout(WorkoutPlan workout) async {
    final data = await post(workout.toJson(), makeUrl(_workoutPlansUrlPath));
    final plan = WorkoutPlan.fromJson(data);
    _workoutPlans.insert(0, plan);
    notifyListeners();
    return plan;
  }

  Future<void> deleteWorkout(int id) async {
    final existingWorkoutIndex = _workoutPlans.indexWhere((element) => element.id == id);
    var existingWorkout = _workoutPlans[existingWorkoutIndex];
    _workoutPlans.removeAt(existingWorkoutIndex);
    notifyListeners();

    final response = await deleteRequest(_workoutPlansUrlPath, id);

    if (response.statusCode >= 400) {
      _workoutPlans.insert(existingWorkoutIndex, existingWorkout);
      notifyListeners();
      throw WgerHttpException(response.body);
    }
    existingWorkout = null;
  }

  Future<dynamic> fetchLogData(WorkoutPlan workout, Exercise exercise) async {
    final data = await fetch(
      makeUrl(
        _workoutPlansUrlPath,
        id: workout.id,
        objectMethod: 'log_data',
        query: {'id': exercise.id.toString()},
      ),
    );
    return data;
  }

  /*
   * Days
   */
  Future<Day> addDay(Day day, WorkoutPlan workout) async {
    /*
     * Saves a new day instance to the DB and adds it to the given workout
     */
    day.workoutId = workout.id;
    final data = await post(day.toJson(), makeUrl(_daysUrlPath));
    day = Day.fromJson(data);
    day.sets = [];
    workout.days.insert(0, day);
    notifyListeners();
    return day;
  }

  /*
   * Sessions
   */
  Future<dynamic> fetchSessionData() async {
    final data = await fetch(
      makeUrl(_sessionUrlPath),
    );
    return data;
  }
}
