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
import 'package:wger/models/exercises/base.dart';
import 'package:wger/models/exercises/translation.dart';
import 'package:wger/models/routines/day.dart';
import 'package:wger/models/routines/log.dart';
import 'package:wger/models/routines/repetition_unit.dart';
import 'package:wger/models/routines/routine.dart';
import 'package:wger/models/routines/session.dart';
import 'package:wger/models/routines/set.dart';
import 'package:wger/models/routines/setting.dart';
import 'package:wger/models/routines/weight_unit.dart';
import 'package:wger/providers/base_provider.dart';
import 'package:wger/providers/exercises.dart';

class RoutineProvider with ChangeNotifier {
  static const _routinesUrlPath = 'workout';
  static const _daysUrlPath = 'day';
  static const _setsUrlPath = 'set';
  static const _settingsUrlPath = 'setting';
  static const _logsUrlPath = 'workoutlog';
  static const _sessionUrlPath = 'workoutsession';
  static const _weightUnitUrlPath = 'setting-weightunit';
  static const _repetitionUnitUrlPath = 'setting-repetitionunit';

  Routine? _currentRoutine;
  final ExercisesProvider _exercises;
  final WgerBaseProvider baseProvider;
  List<Routine> _routines = [];
  List<WeightUnit> _weightUnits = [];
  List<RepetitionUnit> _repetitionUnit = [];

  RoutineProvider(this.baseProvider, ExercisesProvider exercises, List<Routine> entries)
      : _exercises = exercises,
        _routines = entries;

  List<Routine> get items {
    return [..._routines];
  }

  List<WeightUnit> get weightUnits {
    return [..._weightUnits];
  }

  /// Clears all lists
  void clear() {
    _currentRoutine = null;
    _routines = [];
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

  List<Routine> getPlans() {
    return _routines;
  }

  Routine findById(int id) {
    return _routines.firstWhere((workoutPlan) => workoutPlan.id == id);
  }

  int findIndexById(int id) {
    return _routines.indexWhere((workoutPlan) => workoutPlan.id == id);
  }

  /// Set the currently "active" routine
  void setCurrentPlan(int id) {
    _currentRoutine = findById(id);
  }

  /// Returns the currently "active" routine
  Routine? get currentRoutine {
    return _currentRoutine;
  }

  /// Reset the currently "active" routine to null
  void resetCurrentRoutine() {
    _currentRoutine = null;
  }

  /// Returns the current active routine. At the moment this is just
  /// the latest, but this might change in the future.
  Routine? get activeRoutine {
    if (_routines.isNotEmpty) {
      return _routines.first;
    }
    return null;
  }

  /*
   * Routines
   */

  /// Fetches and sets all routines fully, i.e. with all corresponding child
  /// attributes
  Future<void> fetchAndSetAllRoutinesFull() async {
    final data = await baseProvider.fetch(
      baseProvider.makeUrl(
        _routinesUrlPath,
        query: {'ordering': '-creation_date', 'limit': '1000'},
      ),
    );
    for (final entry in data['results']) {
      await fetchAndSetRoutineFull(entry['id']);
    }

    notifyListeners();
  }

  /// Fetches all routines sparsely, i.e. only with the data on the routine
  /// object itself and no child attributes
  Future<void> fetchAndSetAllRoutinesSparse() async {
    final data = await baseProvider.fetch(
      baseProvider.makeUrl(_routinesUrlPath, query: {'limit': '1000'}),
    );
    _routines = [];
    for (final workoutPlanData in data['results']) {
      final plan = Routine.fromJson(workoutPlanData);
      _routines.add(plan);
    }

    _routines.sort((a, b) => b.creationDate.compareTo(a.creationDate));
    notifyListeners();
  }

  /// Fetches a routine sparsely, i.e. only with the data on the plan
  /// object itself and no child attributes
  Future<Routine> fetchAndSetRoutineSparse(int planId) async {
    final fullPlanData = await baseProvider.fetch(
      baseProvider.makeUrl(_routinesUrlPath, id: planId),
    );
    final plan = Routine.fromJson(fullPlanData);
    _routines.add(plan);
    _routines.sort((a, b) => b.creationDate.compareTo(a.creationDate));

    notifyListeners();
    return plan;
  }

  /// Fetches a routine fully, i.e. with all corresponding child attributes
  Future<Routine> fetchAndSetRoutineFull(int routineId) async {
    // Load a list of all settings so that we can search through it
    //
    // This is a bit ugly, but saves us sending lots of requests later on
    final allSettingsData = await baseProvider.fetch(
      baseProvider.makeUrl(_settingsUrlPath, query: {'limit': '1000'}),
    );

    Routine routine;
    try {
      routine = findById(routineId);
    } on StateError {
      routine = await fetchAndSetRoutineSparse(routineId);
    }

    // Days
    final List<Day> days = [];
    final daysData = await baseProvider.fetch(
      baseProvider.makeUrl(_daysUrlPath, query: {'training': routine.id.toString()}),
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

        // Settings
        final List<Setting> settings = [];
        final settingData = allSettingsData['results'].where((s) => s['set'] == workoutSet.id);

        for (final settingEntry in settingData) {
          final workoutSetting = Setting.fromJson(settingEntry);

          workoutSetting.exerciseBase =
              await _exercises.fetchAndSetExerciseBase(workoutSetting.exerciseBaseId);
          workoutSetting.weightUnit = _weightUnits.firstWhere(
            (e) => e.id == workoutSetting.weightUnitId,
          );
          workoutSetting.repetitionUnit = _repetitionUnit.firstWhere(
            (e) => e.id == workoutSetting.repetitionUnitId,
          );
          if (!workoutSet.exerciseBasesIds.contains(workoutSetting.exerciseBaseId)) {
            workoutSet.addExerciseBase(workoutSetting.exerciseBaseObj);
          }

          settings.add(workoutSetting);
        }
        workoutSet.settings = settings;
        sets.add(workoutSet);
      }
      day.sets = sets;
      days.add(day);
    }
    routine.days = days;

    // Logs
    routine.logs = [];

    final logData = await baseProvider.fetchPaginated(baseProvider.makeUrl(
      _logsUrlPath,
      query: {'workout': routineId.toString(), 'limit': '100'},
    ));
    for (final logEntry in logData) {
      try {
        final log = Log.fromJson(logEntry);
        log.weightUnit = _weightUnits.firstWhere((e) => e.id == log.weightUnitId);
        log.repetitionUnit = _repetitionUnit.firstWhere((e) => e.id == log.weightUnitId);
        log.exerciseBase = await _exercises.fetchAndSetExerciseBase(log.exerciseBaseId);
        routine.logs.add(log);
      } catch (e) {
        dev.log('fire! fire!');
        dev.log(e.toString());
      }
    }

    // ... and done
    notifyListeners();
    return routine;
  }

  Future<Routine> addRoutine(Routine routine) async {
    final data = await baseProvider.post(routine.toJson(), baseProvider.makeUrl(_routinesUrlPath));
    final plan = Routine.fromJson(data);
    _routines.insert(0, plan);
    notifyListeners();
    return plan;
  }

  Future<void> editRoutine(Routine routine) async {
    await baseProvider.patch(
        routine.toJson(), baseProvider.makeUrl(_routinesUrlPath, id: routine.id));
    notifyListeners();
  }

  Future<void> deleteRoutine(int id) async {
    final existingRoutineIndex = _routines.indexWhere((element) => element.id == id);
    final existingRoutine = _routines[existingRoutineIndex];
    _routines.removeAt(existingRoutineIndex);
    notifyListeners();

    final response = await baseProvider.deleteRequest(_routinesUrlPath, id);

    if (response.statusCode >= 400) {
      _routines.insert(existingRoutineIndex, existingRoutine);
      notifyListeners();
      throw WgerHttpException(response.body);
    }
  }

  Future<Map<String, dynamic>> fetchLogData(Routine routine, ExerciseBase base) async {
    final data = await baseProvider.fetch(
      baseProvider.makeUrl(
        _routinesUrlPath,
        id: routine.id,
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
        dev.log("Read workout units data from cache. Valid till ${unitData['expiresIn']}");
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
  Future<Day> addDay(Day day, Routine routine) async {
    /*
     * Saves a new day instance to the DB and adds it to the given workout
     */
    day.routineId = routine.id!;
    final data = await baseProvider.post(day.toJson(), baseProvider.makeUrl(_daysUrlPath));
    day = Day.fromJson(data);
    day.sets = [];
    routine.days.insert(0, day);
    notifyListeners();
    return day;
  }

  Future<void> editDay(Day day) async {
    await baseProvider.patch(day.toJson(), baseProvider.makeUrl(_daysUrlPath, id: day.id));
    notifyListeners();
  }

  Future<void> deleteDay(Day day) async {
    await baseProvider.deleteRequest(_daysUrlPath, day.id!);
    for (final workout in _routines) {
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

    for (final workout in _routines) {
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
    final data = await baseProvider.post(session.toJson(), baseProvider.makeUrl(_sessionUrlPath));
    final newSession = WorkoutSession.fromJson(data);
    notifyListeners();
    return newSession;
  }

  /*
   * Logs
   */
  Future<Log> addLog(Log log) async {
    final data = await baseProvider.post(log.toJson(), baseProvider.makeUrl(_logsUrlPath));
    final newLog = Log.fromJson(data);

    log.id = newLog.id;
    log.weightUnit = _weightUnits.firstWhere((e) => e.id == log.weightUnitId);
    log.repetitionUnit = _repetitionUnit.firstWhere((e) => e.id == log.weightUnitId);
    log.exerciseBase = await _exercises.fetchAndSetExerciseBase(log.exerciseBaseId);

    final plan = findById(log.routineId);
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
    for (final workout in _routines) {
      workout.logs.removeWhere((element) => element.id == log.id);
    }
    notifyListeners();
  }
}
