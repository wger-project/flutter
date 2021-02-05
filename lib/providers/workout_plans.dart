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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/exercises/image.dart';
import 'package:wger/models/http_exception.dart';
import 'package:wger/models/workouts/day.dart';
import 'package:wger/models/workouts/log.dart';
import 'package:wger/models/workouts/repetition_unit.dart';
import 'package:wger/models/workouts/set.dart';
import 'package:wger/models/workouts/setting.dart';
import 'package:wger/models/workouts/weight_unit.dart';
import 'package:wger/models/workouts/workout_plan.dart';
import 'package:wger/providers/auth.dart';
import 'package:wger/providers/base_provider.dart';

class WorkoutPlans extends WgerBaseProvider with ChangeNotifier {
  static const DAYS_TO_CACHE = 10;

  static const _workoutPlansUrlPath = 'workout';
  static const _daysUrlPath = 'day';
  static const _setsUrlPath = 'set';
  static const _settingsUrlPath = 'setting';
  static const _logsUrlPath = 'workoutlog';
  static const _sessionUrlPath = 'workoutsession';
  static const _weightUnitUrlPath = 'setting-weightunit';
  static const _repetitionUnitUrlPath = 'setting-repetitionunit';

  WorkoutPlan _currentPlan;
  List<WorkoutPlan> _workoutPlans = [];
  List<WeightUnit> _weightUnits = [];
  List<RepetitionUnit> _repetitionUnit = [];

  WorkoutPlans(Auth auth, List<WorkoutPlan> entries, [http.Client client])
      : this._workoutPlans = entries,
        super(auth, client);

  List<WorkoutPlan> get items {
    return [..._workoutPlans];
  }

  List<WeightUnit> get weightUnits {
    return [..._weightUnits];
  }

  /// Return the default weight unit (kg)
  WeightUnit get defaultWeightUnit {
    return _weightUnits.firstWhere((element) => element.id == 1);
  }

  List<RepetitionUnit> get repetitionUnits {
    return [..._repetitionUnit];
  }

  /// Return the default weight unit (reps)
  RepetitionUnit get defaultRepetitionUnit {
    return _repetitionUnit.firstWhere((element) => element.id == 1);
  }

  WorkoutPlan findById(int id) {
    return _workoutPlans.firstWhere((workoutPlan) => workoutPlan.id == id);
  }

  int findIndexById(int id) {
    return _workoutPlans.indexWhere((workoutPlan) => workoutPlan.id == id);
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

  Future<void> setAllFullWorkouts() async {
    for (var plan in _workoutPlans) {
      setFullWorkout(plan.id);
    }
  }

  Future<WorkoutPlan> setFullWorkout(int workoutId) async {
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
      final logData = await fetch(makeUrl(_logsUrlPath, query: {'workout': workoutId.toString()}));
      for (final entry in logData['results']) {
        workout.logs.add(Log.fromJson(entry));
      }
      notifyListeners();

      return workout;
    } catch (error) {
      throw (error);
    }
  }

  Future<WorkoutPlan> postWorkout(WorkoutPlan workout) async {
    final data = await post(workout.toJson(), makeUrl(_workoutPlansUrlPath));
    final plan = WorkoutPlan.fromJson(data);
    _workoutPlans.insert(0, plan);
    notifyListeners();
    return plan;
  }

  Future<WorkoutPlan> patchWorkout(WorkoutPlan workout) async {
    final data = await patch(workout.toJson(), makeUrl(_workoutPlansUrlPath, id: workout.id));
    final plan = WorkoutPlan.fromJson(data);
    _workoutPlans[findIndexById(plan.id)] = plan;
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

  /// Fetch and set weight units for workout (kg, lb, plate, etc.)
  Future<void> fetchAndSetRepetitionUnits() async {
    final response = await client.get(makeUrl(_repetitionUnitUrlPath));
    final units = json.decode(response.body) as Map<String, dynamic>;
    try {
      for (final unit in units['results']) {
        _repetitionUnit.add(RepetitionUnit.fromJson(unit));
      }
    } catch (error) {
      throw (error);
    }
  }

  /// Fetch and set weight units for workout (kg, lb, plate, etc.)
  Future<void> fetchAndSetWeightUnits() async {
    final response = await client.get(makeUrl(_weightUnitUrlPath));
    final units = json.decode(response.body) as Map<String, dynamic>;
    try {
      for (final unit in units['results']) {
        _weightUnits.add(WeightUnit.fromJson(unit));
      }
    } catch (error) {
      throw (error);
    }
  }

  Future<void> fetchAndSetUnits() async {
    // Load units from cache, if available
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('workoutUnits')) {
      final workoutData = json.decode(prefs.getString('workoutUnits'));
      if (DateTime.parse(workoutData['expiresIn']).isAfter(DateTime.now())) {
        workoutData['repetitionUnits']
            .forEach((e) => _repetitionUnit.add(RepetitionUnit.fromJson(e)));
        workoutData['weightUnit'].forEach((e) => _weightUnits.add(WeightUnit.fromJson(e)));
        log("Read workout units data from cache. Valid till ${workoutData['expiresIn']}");
        return;
      }
    }

    // Load units
    await fetchAndSetWeightUnits();
    await fetchAndSetRepetitionUnits();

    // Save the result to the cache
    final exerciseData = {
      'date': DateTime.now().toIso8601String(),
      'expiresIn': DateTime.now().add(Duration(days: DAYS_TO_CACHE)).toIso8601String(),
      'repetitionUnits': _repetitionUnit.map((e) => e.toJson()).toList(),
      'weightUnit': _weightUnits.map((e) => e.toJson()).toList(),
    };
    prefs.setString('workoutUnits', json.encode(exerciseData));
    notifyListeners();
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
   * Sets
   */
  Future<Set> addSet(Set workoutSet) async {
    final data = await post(workoutSet.toJson(), makeUrl(_setsUrlPath));
    final set = Set.fromJson(data);
    //_workoutPlans.insert(0, plan);
    notifyListeners();
    return set;
  }

  /*
   * Setting
   */
  Future<Setting> addSetting(Setting workoutSetting) async {
    final data = await post(workoutSetting.toJson(), makeUrl(_settingsUrlPath));
    final setting = Setting.fromJson(data);
    //_workoutPlans.insert(0, plan);
    notifyListeners();
    return setting;
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
