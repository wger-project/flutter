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

import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wger/exceptions/http_exception.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/exercises/translation.dart';
import 'package:wger/models/workouts/day.dart';
import 'package:wger/models/workouts/log.dart';
import 'package:wger/models/workouts/repetition_unit.dart';
import 'package:wger/models/workouts/session.dart';
import 'package:wger/models/workouts/set.dart';
import 'package:wger/models/workouts/setting.dart';
import 'package:wger/models/workouts/weight_unit.dart';
import 'package:wger/models/workouts/workout_plan.dart';
import 'package:wger/providers/base_provider.dart';
import 'package:wger/providers/exercises.dart';

class WorkoutPlansProvider with ChangeNotifier {
  static const _workoutPlansUrlPath = 'workout';
  static const _daysUrlPath = 'day';
  static const _setsUrlPath = 'set';
  static const _settingsUrlPath = 'setting';
  static const _logsUrlPath = 'workoutlog';
  static const _sessionUrlPath = 'workoutsession';
  static const _weightUnitUrlPath = 'setting-weightunit';
  static const _repetitionUnitUrlPath = 'setting-repetitionunit';

  WorkoutPlan? _currentPlan;
  final ExercisesProvider _exercises;
  final WgerBaseProvider baseProvider;
  List<WorkoutPlan> _workoutPlans = [];
  List<WeightUnit> _weightUnits = [];
  List<RepetitionUnit> _repetitionUnit = [];

  WorkoutPlansProvider(
    this.baseProvider,
    ExercisesProvider exercises,
    List<WorkoutPlan> entries,
  )   : _exercises = exercises,
        _workoutPlans = entries;

  List<WorkoutPlan> get items {
    return [..._workoutPlans];
  }

  List<WeightUnit> get weightUnits {
    return [..._weightUnits];
  }

  /// Clears all lists
  void clear() {
    _currentPlan = null;
    _workoutPlans = [];
    _weightUnits = [];
    _repetitionUnit = [];
  }

  /// Return the default weight unit (kg)
  WeightUnit get defaultWeightUnit {
    return _weightUnits.firstWhere((element) => element.id == DEFAULT_WEIGHT_UNIT);
  }

  List<RepetitionUnit> get repetitionUnits {
    return [..._repetitionUnit];
  }

  /// Return the default weight unit (reps)
  RepetitionUnit get defaultRepetitionUnit {
    return _repetitionUnit.firstWhere((element) => element.id == REP_UNIT_REPETITIONS);
  }

  List<WorkoutPlan> getPlans() {
    return _workoutPlans;
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
  WorkoutPlan? get currentPlan {
    return _currentPlan;
  }

  /// Reset the currently "active" workout plan to null
  void resetCurrentPlan() {
    _currentPlan = null;
  }

  /// Returns the current active workout plan. At the moment this is just
  /// the latest, but this might change in the future.
  WorkoutPlan? get activePlan {
    if (_workoutPlans.isNotEmpty) {
      return _workoutPlans.first;
    }
    return null;
  }

  /*
   * Workouts
   */

  /// Fetches and sets all workout plans fully, i.e. with all corresponding child
  /// attributes
  Future<void> fetchAndSetAllPlansFull() async {
    final data = await baseProvider.fetch(
      baseProvider.makeUrl(
        _workoutPlansUrlPath,
        query: {'ordering': '-creation_date', 'limit': '1000'},
      ),
    );
    for (final entry in data['results']) {
      await fetchAndSetWorkoutPlanFull(entry['id']);
    }

    notifyListeners();
  }

  /// Fetches all workout plan sparsely, i.e. only with the data on the plan
  /// object itself and no child attributes
  Future<void> fetchAndSetAllPlansSparse() async {
    final data = await baseProvider.fetch(
      baseProvider.makeUrl(_workoutPlansUrlPath, query: {'limit': '1000'}),
    );
    _workoutPlans = [];
    for (final workoutPlanData in data['results']) {
      final plan = WorkoutPlan.fromJson(workoutPlanData);
      _workoutPlans.add(plan);
    }

    _workoutPlans.sort((a, b) => b.creationDate.compareTo(a.creationDate));
    notifyListeners();
  }

  /// Fetches a workout plan sparsely, i.e. only with the data on the plan
  /// object itself and no child attributes
  Future<WorkoutPlan> fetchAndSetPlanSparse(int planId) async {
    final fullPlanData = await baseProvider.fetch(
      baseProvider.makeUrl(_workoutPlansUrlPath, id: planId),
    );
    final plan = WorkoutPlan.fromJson(fullPlanData);
    _workoutPlans.add(plan);
    _workoutPlans.sort((a, b) => b.creationDate.compareTo(a.creationDate));

    notifyListeners();
    return plan;
  }

  /// Fetches a workout plan fully, i.e. with all corresponding child attributes
  Future<WorkoutPlan> fetchAndSetWorkoutPlanFull(int workoutId) async {
    // Load a list of all settings so that we can search through it
    //
    // This is a bit ugly, but saves us sending lots of requests later on
    final allSettingsData = await baseProvider.fetch(
      baseProvider.makeUrl(_settingsUrlPath, query: {'limit': '1000'}),
    );

    WorkoutPlan plan;
    try {
      plan = findById(workoutId);
    } on StateError {
      plan = await fetchAndSetPlanSparse(workoutId);
    }

    // Days
    final List<Day> days = [];
    final daysData = await baseProvider.fetch(
      baseProvider.makeUrl(_daysUrlPath, query: {'training': plan.id.toString()}),
    );
    for (final dayEntry in daysData['results']) {
      final day = Day.fromJson(dayEntry);

      // Sets
      final List<Set> sets = [];
      final setData = await baseProvider.fetch(
        baseProvider.makeUrl(_setsUrlPath, query: {'exerciseday': day.id.toString()}),
      );
      for (final setEntry in setData['results']) {
        final workoutSet = Set.fromJson(setEntry);

        fetchComputedSettings(workoutSet); // request!

        final List<Setting> settings = [];
        final settingData = allSettingsData['results'].where((s) => s['set'] == workoutSet.id);

        for (final settingEntry in settingData) {
          final workoutSetting = Setting.fromJson(settingEntry);

          workoutSetting.exercise = await _exercises.fetchAndSetExercise(workoutSetting.exerciseId);
          workoutSetting.weightUnit = _weightUnits.firstWhere(
            (e) => e.id == workoutSetting.weightUnitId,
          );
          workoutSetting.repetitionUnit = _repetitionUnit.firstWhere(
            (e) => e.id == workoutSetting.repetitionUnitId,
          );
          if (!workoutSet.exerciseBasesIds.contains(workoutSetting.exerciseId)) {
            workoutSet.addExerciseBase(workoutSetting.exerciseObj);
          }

          settings.add(workoutSetting);
        }
        workoutSet.settings = settings;
        sets.add(workoutSet);
      }
      day.sets = sets;
      days.add(day);
    }
    plan.days = days;

    // Logs
    plan.logs = [];

    final logData = await baseProvider.fetchPaginated(baseProvider.makeUrl(
      _logsUrlPath,
      query: {'workout': workoutId.toString(), 'limit': '100'},
    ));
    for (final logEntry in logData) {
      try {
        final log = Log.fromJson(logEntry);
        log.weightUnit = _weightUnits.firstWhere((e) => e.id == log.weightUnitId);
        log.repetitionUnit = _repetitionUnit.firstWhere((e) => e.id == log.weightUnitId);
        log.exerciseBase = await _exercises.fetchAndSetExercise(log.exerciseBaseId);
        plan.logs.add(log);
      } catch (e) {
        dev.log('fire! fire!');
        dev.log(e.toString());
      }
    }

    // ... and done
    notifyListeners();
    return plan;
  }

  Future<WorkoutPlan> addWorkout(WorkoutPlan workout) async {
    final data = await baseProvider.post(
      workout.toJson(),
      baseProvider.makeUrl(_workoutPlansUrlPath),
    );
    final plan = WorkoutPlan.fromJson(data);
    _workoutPlans.insert(0, plan);
    notifyListeners();
    return plan;
  }

  Future<void> editWorkout(WorkoutPlan workout) async {
    await baseProvider.patch(
      workout.toJson(),
      baseProvider.makeUrl(_workoutPlansUrlPath, id: workout.id),
    );
    notifyListeners();
  }

  Future<void> deleteWorkout(int id) async {
    final existingWorkoutIndex = _workoutPlans.indexWhere((element) => element.id == id);
    final existingWorkout = _workoutPlans[existingWorkoutIndex];
    _workoutPlans.removeAt(existingWorkoutIndex);
    notifyListeners();

    final response = await baseProvider.deleteRequest(_workoutPlansUrlPath, id);

    if (response.statusCode >= 400) {
      _workoutPlans.insert(existingWorkoutIndex, existingWorkout);
      notifyListeners();
      throw WgerHttpException(response.body);
    }
  }

  Future<Map<String, dynamic>> fetchLogData(
    WorkoutPlan workout,
    Exercise base,
  ) async {
    final data = await baseProvider.fetch(
      baseProvider.makeUrl(
        _workoutPlansUrlPath,
        id: workout.id,
        objectMethod: 'log_data',
        query: {'id': base.id.toString()},
      ),
    );
    return data;
  }

  /// Fetch and set weight units for workout (kg, lb, plate, etc.)
  Future<void> fetchAndSetRepetitionUnits() async {
    final response =
        await baseProvider.fetchPaginated(baseProvider.makeUrl(_repetitionUnitUrlPath));
    for (final unit in response) {
      _repetitionUnit.add(RepetitionUnit.fromJson(unit));
    }
  }

  /// Fetch and set weight units for workout (kg, lb, plate, etc.)
  Future<void> fetchAndSetWeightUnits() async {
    final response = await baseProvider.fetchPaginated(baseProvider.makeUrl(_weightUnitUrlPath));
    for (final unit in response) {
      _weightUnits.add(WeightUnit.fromJson(unit));
    }
  }

  Future<void> fetchAndSetUnits() async {
    // Load units from cache, if available
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('workoutUnits')) {
      final unitData = json.decode(prefs.getString('workoutUnits')!);
      if (DateTime.parse(unitData['expiresIn']).isAfter(DateTime.now())) {
        unitData['repetitionUnits'].forEach(
          (e) => _repetitionUnit.add(RepetitionUnit.fromJson(e)),
        );
        unitData['weightUnit'].forEach(
          (e) => _weightUnits.add(WeightUnit.fromJson(e)),
        );
        dev.log(
          "Read workout units data from cache. Valid till ${unitData['expiresIn']}",
        );
        return;
      }
    }

    // Load units
    await fetchAndSetWeightUnits();
    await fetchAndSetRepetitionUnits();

    // Save the result to the cache
    final exerciseData = {
      'date': DateTime.now().toIso8601String(),
      'expiresIn': DateTime.now().add(const Duration(days: DAYS_TO_CACHE)).toIso8601String(),
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
    day.workoutId = workout.id!;
    final data = await baseProvider.post(
      day.toJson(),
      baseProvider.makeUrl(_daysUrlPath),
    );
    day = Day.fromJson(data);
    day.sets = [];
    workout.days.insert(0, day);
    notifyListeners();
    return day;
  }

  Future<void> editDay(Day day) async {
    await baseProvider.patch(
      day.toJson(),
      baseProvider.makeUrl(_daysUrlPath, id: day.id),
    );
    notifyListeners();
  }

  Future<void> deleteDay(Day day) async {
    await baseProvider.deleteRequest(_daysUrlPath, day.id!);
    for (final workout in _workoutPlans) {
      workout.days.removeWhere((element) => element.id == day.id);
    }
    notifyListeners();
  }

  /*
   * Sets
   */
  Future<Set> addSet(Set workoutSet) async {
    final data = await baseProvider.post(
      workoutSet.toJson(),
      baseProvider.makeUrl(_setsUrlPath),
    );
    final set = Set.fromJson(data);
    notifyListeners();
    return set;
  }

  Future<void> editSet(Set workoutSet) async {
    await baseProvider.patch(
      workoutSet.toJson(),
      baseProvider.makeUrl(_setsUrlPath, id: workoutSet.id),
    );
    notifyListeners();
  }

  Future<List<Set>> reorderSets(List<Set> sets, int startIndex) async {
    for (int i = startIndex; i < sets.length; i++) {
      sets[i].order = i;
      await baseProvider.patch(
        sets[i].toJson(),
        baseProvider.makeUrl(_setsUrlPath, id: sets[i].id),
      );
    }
    notifyListeners();
    return sets;
  }

  Future<void> fetchComputedSettings(Set workoutSet) async {
    final data = await baseProvider.fetch(
      baseProvider.makeUrl(
        _setsUrlPath,
        id: workoutSet.id,
        objectMethod: 'computed_settings',
      ),
    );

    final List<Setting> settings = [];
    data['results'].forEach((e) {
      final Setting workoutSetting = Setting.fromJson(e);

      workoutSetting.weightUnitObj = _weightUnits.firstWhere(
        (unit) => unit.id == workoutSetting.weightUnitId,
      );
      workoutSetting.repetitionUnitObj = _repetitionUnit.firstWhere(
        (unit) => unit.id == workoutSetting.repetitionUnitId,
      );
      settings.add(workoutSetting);
    });

    workoutSet.settingsComputed = settings;
    notifyListeners();
  }

  Future<String> fetchSmartText(Set workoutSet, Translation exercise) async {
    final data = await baseProvider.fetch(
      baseProvider.makeUrl(
        _setsUrlPath,
        id: workoutSet.id,
        objectMethod: 'smart_text',
        query: {'exercise': exercise.id.toString()},
      ),
    );

    return data['results'];
  }

  Future<void> deleteSet(Set workoutSet) async {
    await baseProvider.deleteRequest(_setsUrlPath, workoutSet.id!);

    for (final workout in _workoutPlans) {
      for (final day in workout.days) {
        day.sets.removeWhere((element) => element.id == workoutSet.id);
      }
    }
    notifyListeners();
  }

  /*
   * Setting
   */
  Future<Setting> addSetting(Setting workoutSetting) async {
    final data = await baseProvider.post(
      workoutSetting.toJson(),
      baseProvider.makeUrl(_settingsUrlPath),
    );
    final setting = Setting.fromJson(data);
    notifyListeners();
    return setting;
  }

  /*
   * Sessions
   */
  Future<dynamic> fetchSessionData() async {
    final data = await baseProvider.fetch(
      baseProvider.makeUrl(_sessionUrlPath),
    );
    return data;
  }

  Future<WorkoutSession> addSession(WorkoutSession session) async {
    final data = await baseProvider.post(
      session.toJson(),
      baseProvider.makeUrl(_sessionUrlPath),
    );
    final newSession = WorkoutSession.fromJson(data);
    notifyListeners();
    return newSession;
  }

  /*
   * Logs
   */
  Future<Log> addLog(Log log) async {
    final data = await baseProvider.post(
      log.toJson(),
      baseProvider.makeUrl(_logsUrlPath),
    );
    final newLog = Log.fromJson(data);

    log.id = newLog.id;
    log.weightUnit = _weightUnits.firstWhere((e) => e.id == log.weightUnitId);
    log.repetitionUnit = _repetitionUnit.firstWhere((e) => e.id == log.weightUnitId);
    log.exerciseBase = await _exercises.fetchAndSetExercise(log.exerciseBaseId);

    final plan = findById(log.workoutPlan);
    plan.logs.add(log);
    notifyListeners();
    return newLog;
  }

  /*Future<void> editLog(Log log) async {
    await patch(log.toJson(), makeUrl(_logsUrlPath, id: log.id));
    notifyListeners();
  }*/

  Future<void> deleteLog(Log log) async {
    await baseProvider.deleteRequest(_logsUrlPath, log.id!);
    for (final workout in _workoutPlans) {
      workout.logs.removeWhere((element) => element.id == log.id);
    }
    notifyListeners();
  }
}
