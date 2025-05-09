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

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:wger/exceptions/http_exception.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/shared_preferences.dart';
import 'package:wger/models/workouts/base_config.dart';
import 'package:wger/models/workouts/day.dart';
import 'package:wger/models/workouts/day_data.dart';
import 'package:wger/models/workouts/log.dart';
import 'package:wger/models/workouts/repetition_unit.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/models/workouts/session.dart';
import 'package:wger/models/workouts/session_api.dart';
import 'package:wger/models/workouts/slot.dart';
import 'package:wger/models/workouts/slot_entry.dart';
import 'package:wger/models/workouts/weight_unit.dart';
import 'package:wger/providers/base_provider.dart';
import 'package:wger/providers/exercises.dart';

class RoutinesProvider with ChangeNotifier {
  final _logger = Logger('RoutinesProvider');

  static const _routinesUrlPath = 'routine';
  static const _routinesStructureSubpath = 'structure';
  static const _routinesLogsSubpath = 'logs';
  static const _routinesDateSequenceDisplaySubpath = 'date-sequence-display';
  static const _routinesDateSequenceGymSubpath = 'date-sequence-gym';
  static const _daysUrlPath = 'day';
  static const _slotsUrlPath = 'slot';
  static const _slotEntriesUrlPath = 'slot-entry';
  static const _logsUrlPath = 'workoutlog';
  static const _sessionUrlPath = 'workoutsession';
  static const _weightUnitUrlPath = 'setting-weightunit';
  static const _repetitionUnitUrlPath = 'setting-repetitionunit';
  static const _routineConfigSets = 'sets-config';
  static const _routineConfigMaxSets = 'max-sets-config';
  static const _routineConfigWeights = 'weight-config';
  static const _routineConfigMaxWeights = 'max-weight-config';
  static const _routineConfigRepetitions = 'repetitions-config';
  static const _routineConfigMaxRepetitions = 'max-repetitions-config';
  static const _routineConfigRir = 'rir-config';
  static const _routineConfigMaxRir = 'rest-config';
  static const _routineConfigRestTime = 'rest-config';
  static const _routineConfigMaxRestTime = 'max-rest-config';

  Routine? activeRoutine;
  late ExercisesProvider _exerciseProvider;
  final WgerBaseProvider baseProvider;
  List<Routine> _routines = [];
  List<WeightUnit> _weightUnits = [];
  List<RepetitionUnit> _repetitionUnits = [];

  RoutinesProvider(
    this.baseProvider,
    ExercisesProvider exercises,
    List<Routine> entries, {
    List<WeightUnit>? weightUnits,
    List<RepetitionUnit>? repetitionUnits,
  }) {
    _exerciseProvider = exercises;
    _routines = entries;
    _weightUnits = weightUnits ?? [];
    _repetitionUnits = repetitionUnits ?? [];
  }

  List<Routine> get items {
    return [..._routines];
  }

  List<WeightUnit> get weightUnits {
    return [..._weightUnits];
  }

  set weightUnits(List<WeightUnit> weightUnits) {
    _weightUnits = weightUnits;
  }

  /// Clears all lists
  void clear() {
    activeRoutine = null;
    _routines = [];
    _weightUnits = [];
    _repetitionUnits = [];
  }

  /// Return the default weight unit (kg)
  WeightUnit get defaultWeightUnit {
    return _weightUnits.firstWhere((element) => element.id == WEIGHT_UNIT_KG);
  }

  WeightUnit findWeightUnitById(int id) => _weightUnits.firstWhere((element) => element.id == id);

  List<RepetitionUnit> get repetitionUnits {
    return [..._repetitionUnits];
  }

  set repetitionUnits(List<RepetitionUnit> repetitionUnits) {
    _repetitionUnits = repetitionUnits;
  }

  RepetitionUnit findRepetitionUnitById(int id) =>
      _repetitionUnits.firstWhere((element) => element.id == id);

  /// Return the default weight unit (reps)
  RepetitionUnit get defaultRepetitionUnit {
    return _repetitionUnits.firstWhere((element) => element.id == REP_UNIT_REPETITIONS_ID);
  }

  List<Routine> getPlans() {
    return _routines;
  }

  Routine findById(int id) {
    return _routines.firstWhere((routine) => routine.id == id);
  }

  int findIndexById(int id) {
    return _routines.indexWhere((routine) => routine.id == id);
  }

  /// Sets the current active routine. At the moment this is just the latest,
  /// but this might change in the future.
  void setActiveRoutine() {
    if (_routines.isNotEmpty) {
      activeRoutine = _routines.first;
    } else {
      activeRoutine = null;
    }
  }

  /*
   * Routines
   */

  /// Fetches and sets all workout plans fully, i.e. with all corresponding child
  /// attributes
  Future<void> fetchAndSetAllRoutinesFull() async {
    final data = await baseProvider.fetch(
      baseProvider.makeUrl(
        _routinesUrlPath,
        query: {'ordering': '-creation_date', 'limit': '1000', 'is_template': 'false'},
      ),
    );
    for (final entry in data['results']) {
      await fetchAndSetRoutineFull(entry['id']);
    }

    setActiveRoutine();
    notifyListeners();
  }

  /// Fetches all routines sparsely, i.e. only with the data on the object itself
  /// and no child attributes
  Future<void> fetchAndSetAllRoutinesSparse() async {
    final data = await baseProvider.fetch(
      baseProvider.makeUrl(_routinesUrlPath, query: {'limit': '1000', 'is_template': 'false'}),
    );
    _routines = [];
    for (final workoutPlanData in data['results']) {
      final plan = Routine.fromJson(workoutPlanData);
      _routines.add(plan);
    }

    setActiveRoutine();
    notifyListeners();
  }

  Future<void> setExercisesAndUnits(List<DayData> entries) async {
    for (final entry in entries) {
      for (final slot in entry.slots) {
        for (final setConfig in slot.setConfigs) {
          setConfig.exercise = (await _exerciseProvider.fetchAndSetExercise(setConfig.exerciseId))!;

          setConfig.repetitionsUnit = _repetitionUnits.firstWhere(
            (e) => e.id == setConfig.repetitionsUnitId,
          );

          setConfig.weightUnit = _weightUnits.firstWhere(
            (e) => e.id == setConfig.weightUnitId,
          );
        }
      }
    }
  }

  /// Fetches a routine sparsely, i.e. only with the data on the object itself
  /// and no child attributes
  Future<Routine> fetchAndSetRoutineSparse(int planId) async {
    final fullPlanData = await baseProvider.fetch(
      baseProvider.makeUrl(_routinesUrlPath, id: planId),
    );
    final routine = Routine.fromJson(fullPlanData);
    _routines.add(routine);
    _routines.sort((a, b) => b.created.compareTo(a.created));

    setActiveRoutine();
    notifyListeners();
    return routine;
  }

  /// Fetches a workout plan fully, i.e. with all corresponding child attributes
  Future<Routine> fetchAndSetRoutineFull(int routineId) async {
    // Fetch structure and computed data
    final results = await Future.wait([
      baseProvider.fetch(
        baseProvider.makeUrl(
          _routinesUrlPath,
          objectMethod: _routinesStructureSubpath,
          id: routineId,
        ),
      ),
      baseProvider.fetch(
        baseProvider.makeUrl(
          _routinesUrlPath,
          id: routineId,
          objectMethod: _routinesDateSequenceDisplaySubpath,
        ),
      ),
      baseProvider.fetch(
        baseProvider.makeUrl(
          _routinesUrlPath,
          id: routineId,
          objectMethod: _routinesDateSequenceGymSubpath,
        ),
      ),
      baseProvider.fetch(
        baseProvider.makeUrl(
          _routinesUrlPath,
          id: routineId,
          objectMethod: _routinesLogsSubpath,
        ),
      ),
    ]);

    final routine = Routine.fromJson(results[0] as Map<String, dynamic>);
    final dayData = results[1] as List<dynamic>;
    final dayDataGym = results[2] as List<dynamic>;
    final sessionData = results[3] as List<dynamic>;

    /*
     * Set exercise, repetition and weight unit objects
     *
     * note that setExercisesAndUnits modifies the list in-place
     */
    final dayDataEntriesDisplay = dayData.map((entry) => DayData.fromJson(entry)).toList();
    await setExercisesAndUnits(dayDataEntriesDisplay);

    final dayDataEntriesGym = dayDataGym.map((entry) => DayData.fromJson(entry)).toList();
    await setExercisesAndUnits(dayDataEntriesGym);

    final sessionDataEntries =
        sessionData.map((entry) => WorkoutSessionApi.fromJson(entry)).toList();

    for (final day in routine.days) {
      for (final slot in day.slots) {
        for (final slotEntry in slot.entries) {
          slotEntry.exerciseObj =
              (await _exerciseProvider.fetchAndSetExercise(slotEntry.exerciseId))!;
          if (slotEntry.repetitionUnitId != null) {
            slotEntry.repetitionUnitObj = _repetitionUnits.firstWhere(
              (e) => e.id == slotEntry.repetitionUnitId,
            );
          }
          if (slotEntry.weightUnitId != null) {
            slotEntry.weightUnitObj = _weightUnits.firstWhere(
              (e) => e.id == slotEntry.weightUnitId,
            );
          }
        }
      }
    }

    routine.dayData = dayDataEntriesDisplay;
    routine.dayDataGym = dayDataEntriesGym;

    // Logs
    routine.sessions = List<WorkoutSessionApi>.of(sessionDataEntries);
    for (final session in routine.sessions) {
      for (final log in session.logs) {
        if (log.weightUnitId != null) {
          log.weightUnit = _weightUnits.firstWhere((e) => e.id == log.weightUnitId);
        }
        if (log.repetitionsUnitId != null) {
          log.repetitionUnit = _repetitionUnits.firstWhere((e) => e.id == log.repetitionsUnitId);
        }
        log.exerciseBase = (await _exerciseProvider.fetchAndSetExercise(log.exerciseId))!;
      }
    }

    // ... and done
    final routineIndex = _routines.indexWhere((r) => r.id == routineId);
    if (routineIndex != -1) {
      _routines[routineIndex] = routine;
    } else {
      _routines.add(routine);
    }

    setActiveRoutine();
    notifyListeners();
    return routine;
  }

  Future<Routine> addRoutine(Routine routine) async {
    final data = await baseProvider.post(
      routine.toJson(),
      baseProvider.makeUrl(_routinesUrlPath),
    );
    final plan = Routine.fromJson(data);
    _routines.insert(0, plan);
    notifyListeners();
    return plan;
  }

  Future<void> editRoutine(Routine routine) async {
    await baseProvider.patch(
      routine.toJson(),
      baseProvider.makeUrl(_routinesUrlPath, id: routine.id),
    );
    await fetchAndSetRoutineFull(routine.id!);
  }

  Future<void> deleteRoutine(int id) async {
    final routineIndex = _routines.indexWhere((element) => element.id == id);
    final routine = _routines[routineIndex];
    _routines.removeAt(routineIndex);
    notifyListeners();

    final response = await baseProvider.deleteRequest(_routinesUrlPath, id);

    if (response.statusCode >= 400) {
      _routines.insert(routineIndex, routine);
      notifyListeners();
      throw WgerHttpException(response.body);
    }
  }

  /// Fetch and set weight units for workout (kg, lb, plate, etc.)
  Future<void> fetchAndSetRepetitionUnits() async {
    final response =
        await baseProvider.fetchPaginated(baseProvider.makeUrl(_repetitionUnitUrlPath));
    for (final unit in response) {
      _repetitionUnits.add(RepetitionUnit.fromJson(unit));
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
    final prefs = PreferenceHelper.asyncPref;
    if (await prefs.containsKey(PREFS_WORKOUT_UNITS)) {
      final unitData = json.decode((await prefs.getString(PREFS_WORKOUT_UNITS))!);
      if (DateTime.parse(unitData['expiresIn']).isAfter(DateTime.now())) {
        unitData['repetitionUnits'].forEach(
          (e) => _repetitionUnits.add(RepetitionUnit.fromJson(e)),
        );
        unitData['weightUnit'].forEach(
          (e) => _weightUnits.add(WeightUnit.fromJson(e)),
        );
        _logger.info("Read workout units data from cache. Valid till ${unitData['expiresIn']}");
        return;
      }
    }

    // Load units
    await fetchAndSetWeightUnits();
    await fetchAndSetRepetitionUnits();

    // Save the result to the cache
    final cacheData = {
      'date': DateTime.now().toIso8601String(),
      'expiresIn': DateTime.now().add(const Duration(days: DAYS_TO_CACHE)).toIso8601String(),
      'repetitionUnits': _repetitionUnits.map((e) => e.toJson()).toList(),
      'weightUnit': _weightUnits.map((e) => e.toJson()).toList(),
    };
    prefs.setString(PREFS_WORKOUT_UNITS, json.encode(cacheData));
    notifyListeners();
  }

  /*
   * Days
   */
  Future<Day> addDay(Day day) async {
    /*
     * Saves a new day instance to the DB and adds it to the given workout
     */
    final data = await baseProvider.post(
      day.toJson(),
      baseProvider.makeUrl(_daysUrlPath),
    );
    day = Day.fromJson(data);

    fetchAndSetRoutineFull(day.routineId);

    return day;
  }

  Future<void> editDay(Day day) async {
    await baseProvider.patch(
      day.toJson(),
      baseProvider.makeUrl(_daysUrlPath, id: day.id),
    );

    fetchAndSetRoutineFull(day.routineId);
  }

  Future<void> editDays(List<Day> days) async {
    if (days.isEmpty) {
      return;
    }

    for (final day in days) {
      await baseProvider.patch(
        day.toJson(),
        baseProvider.makeUrl(_daysUrlPath, id: day.id),
      );
    }

    await fetchAndSetRoutineFull(days.first.routineId);
  }

  Future<void> deleteDay(int dayId) async {
    await baseProvider.deleteRequest(_daysUrlPath, dayId);
    final routine = _routines.firstWhere((routine) => routine.days.any((day) => day.id == dayId));

    fetchAndSetRoutineFull(routine.id!);
  }

  /*
   * Sets
   */
  Future<Slot> addSlot(Slot slot, int routineId) async {
    final data = await baseProvider.post(
      slot.toJson(),
      baseProvider.makeUrl(_slotsUrlPath),
    );
    final newSlot = Slot.fromJson(data);

    await fetchAndSetRoutineFull(routineId);

    return newSlot;
  }

  Future<void> deleteSlot(int slotId, int routineId) async {
    await baseProvider.deleteRequest(_slotsUrlPath, slotId);

    await fetchAndSetRoutineFull(routineId);
  }

  Future<void> editSlot(Slot slot, int routineId) async {
    await baseProvider.patch(
      slot.toJson(),
      baseProvider.makeUrl(_slotsUrlPath, id: slot.id),
    );

    await fetchAndSetRoutineFull(routineId);
  }

  Future<void> editSlots(List<Slot> slots, int routineId) async {
    for (final slot in slots) {
      await baseProvider.patch(
        slot.toJson(),
        baseProvider.makeUrl(_slotsUrlPath, id: slot.id),
      );
    }

    await fetchAndSetRoutineFull(routineId);
  }

  Future<SlotEntry> addSlotEntry(SlotEntry entry, int routineId) async {
    final data = await baseProvider.post(
      entry.toJson(),
      baseProvider.makeUrl(_slotEntriesUrlPath),
    );
    final newEntry = SlotEntry.fromJson(data);
    await fetchAndSetRoutineFull(routineId);

    return newEntry;
  }

  Future<void> deleteSlotEntry(int id, int routineId) async {
    await baseProvider.deleteRequest(_slotEntriesUrlPath, id);

    await fetchAndSetRoutineFull(routineId);
  }

  Future<void> editSlotEntry(SlotEntry entry, int routineId) async {
    await baseProvider.patch(
      entry.toJson(),
      baseProvider.makeUrl(_slotEntriesUrlPath, id: entry.id),
    );

    await fetchAndSetRoutineFull(routineId);
  }

  String getConfigUrl(ConfigType type) {
    switch (type) {
      case ConfigType.sets:
        return _routineConfigSets;
      case ConfigType.maxSets:
        return _routineConfigMaxSets;
      case ConfigType.weight:
        return _routineConfigWeights;
      case ConfigType.maxWeight:
        return _routineConfigMaxWeights;
      case ConfigType.repetitions:
        return _routineConfigRepetitions;
      case ConfigType.maxRepetitions:
        return _routineConfigMaxRepetitions;
      case ConfigType.rir:
        return _routineConfigRir;
      case ConfigType.maxRir:
        return _routineConfigMaxRir;
      case ConfigType.rest:
        return _routineConfigRestTime;
      case ConfigType.maxRest:
        return _routineConfigMaxRestTime;
    }
  }

  Future<BaseConfig> editConfig(BaseConfig config, ConfigType type) async {
    final data = await baseProvider.patch(
      config.toJson(),
      baseProvider.makeUrl(getConfigUrl(type), id: config.id),
    );

    notifyListeners();
    return BaseConfig.fromJson(data);
  }

  Future<BaseConfig> addConfig(BaseConfig config, ConfigType type) async {
    final data = await baseProvider.post(
      config.toJson(),
      baseProvider.makeUrl(getConfigUrl(type)),
    );
    notifyListeners();
    return BaseConfig.fromJson(data);
  }

  Future<void> deleteConfig(int id, ConfigType type) async {
    await baseProvider.deleteRequest(getConfigUrl(type), id);
    notifyListeners();
  }

  Future<void> handleConfig(SlotEntry entry, String input, ConfigType type) async {
    final configs = entry.getConfigsByType(type);
    final config = configs.isNotEmpty ? configs.first : null;
    final value = input.isNotEmpty ? num.parse(input) : null;

    if (value == null && config != null) {
      // Value removed, delete entry
      configs.removeWhere((c) => c.id! == config.id!);
      await deleteConfig(config.id!, type);
    } else if (config != null) {
      // Update existing value
      configs.first.value = value!;
      await editConfig(configs.first, type);
    } else if (value != null && config == null) {
      // Create new config
      configs.add(
        await addConfig(
          BaseConfig.firstIteration(value, entry.id!),
          type,
        ),
      );
    }
  }

  /*
   * Sessions
   */
  Future<List<WorkoutSession>> fetchSessionData() async {
    final data = await baseProvider.fetchPaginated(
      baseProvider.makeUrl(_sessionUrlPath),
    );
    final sessions = data.map((entry) => WorkoutSession.fromJson(entry)).toList();

    notifyListeners();

    return sessions;
  }

  Future<WorkoutSession> addSession(WorkoutSession session, int routineId) async {
    final data = await baseProvider.post(
      session.toJson(),
      baseProvider.makeUrl(_sessionUrlPath),
    );
    final newSession = WorkoutSession.fromJson(data);
    final routine = findById(routineId);
    routine.sessions.add(WorkoutSessionApi(session: newSession));

    notifyListeners();
    return newSession;
  }

  Future<WorkoutSession> editSession(WorkoutSession session) async {
    final data = await baseProvider.patch(
      session.toJson(),
      baseProvider.makeUrl(_sessionUrlPath, id: session.id),
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

    newLog.weightUnit = _weightUnits.firstWhere((e) => e.id == log.weightUnitId);
    newLog.repetitionUnit = _repetitionUnits.firstWhere((e) => e.id == log.weightUnitId);
    newLog.exerciseBase = (await _exerciseProvider.fetchAndSetExercise(log.exerciseId))!;

    final plan = findById(newLog.routineId);

    // If there is no session known locally, just re-fetch everything
    try {
      final session = plan.sessions.firstWhere((element) => element.session.id == newLog.sessionId);
      session.logs.add(newLog);
      notifyListeners();
    } on StateError {
      await fetchAndSetRoutineFull(newLog.routineId);
    }

    return newLog;
  }

  /*Future<void> editLog(Log log) async {
    await patch(log.toJson(), makeUrl(_logsUrlPath, id: log.id));
    notifyListeners();
  }*/

  Future<void> deleteLog(int logId, int routineId) async {
    _logger.fine('Deleting log ${logId}');
    await baseProvider.deleteRequest(_logsUrlPath, logId);
    await fetchAndSetRoutineFull(routineId);
  }
}
