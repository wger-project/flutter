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

import 'dart:async';

import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/database/powersync/database.dart';
import 'package:wger/models/workouts/base_config.dart';
import 'package:wger/models/workouts/day.dart';
import 'package:wger/models/workouts/day_data.dart';
import 'package:wger/models/workouts/repetition_unit.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/models/workouts/session.dart';
import 'package:wger/models/workouts/slot.dart';
import 'package:wger/models/workouts/slot_entry.dart';
import 'package:wger/models/workouts/weight_unit.dart';
import 'package:wger/providers/base_provider.dart';
import 'package:wger/providers/exercise_data.dart';
import 'package:wger/providers/wger_base_riverpod.dart';
import 'package:wger/providers/workout_logs.dart';
import 'package:wger/providers/workout_session.dart';

part 'routines.g.dart';

@riverpod
Stream<List<WeightUnit>> routineWeightUnit(Ref ref) {
  final db = ref.read(driftPowerSyncDatabase);
  return db.select(db.routineWeightUnitTable).watch();
}

@riverpod
Stream<List<RepetitionUnit>> routineRepetitionUnit(Ref ref) {
  final db = ref.read(driftPowerSyncDatabase);
  return db.select(db.routineRepetitionUnitTable).watch();
}

class RoutinesState {
  const RoutinesState({
    this.routines = const [],
  });

  final List<Routine> routines;

  RoutinesState copyWith({
    List<Routine>? routines,
    Routine? activeRoutine,
  }) {
    return RoutinesState(
      routines: routines ?? this.routines,
    );
  }

  /// Returns the current active routine. At the moment this is just
  /// the latest, but this might change in the future.
  Routine? get currentRoutine {
    if (routines.isNotEmpty) {
      return routines.first;
    }
    return null;
  }

  Routine findById(int id) {
    return routines.firstWhere((routine) => routine.id == id);
  }

  /// Return all sessions from all routines
  List<WorkoutSession> get sessions {
    if (routines.isNotEmpty) {
      return routines.expand((routine) => routine.sessions).toList();
    }

    return [];
  }
}

@Riverpod(keepAlive: true)
class RoutinesRiverpod extends _$RoutinesRiverpod {
  final _logger = Logger('RoutinesRiverpod');

  @override
  RoutinesState build() {
    _logger.fine('Building Routines Riverpod notifier');
    return const RoutinesState();
  }

  /*
   * Routines
   */
  Future<void> fetchAllRoutinesSparse() async {
    final repo = ref.read(routinesRepositoryProvider);
    final routines = await repo.fetchAllRoutinesSparseServer();
    state = state.copyWith(routines: routines);
  }

  Future<Routine> addRoutine(Routine routine) async {
    final repo = ref.read(routinesRepositoryProvider);
    final created = await repo.addRoutineServer(routine);
    state = state.copyWith(routines: [created, ...state.routines]);
    return created;
  }

  Future<Routine> fetchAndSetRoutineFull(int routineId) async {
    final repo = ref.read(routinesRepositoryProvider);
    final exercises = await ref.read(exercisesProvider.future);
    final repetitionUnits = await ref.read(routineRepetitionUnitProvider.future);
    final weightUnits = await ref.read(routineWeightUnitProvider.future);
    final sessions = await ref.read(workoutSessionProvider.future);
    final logs = await ref.read(workoutLogProvider.future);

    final routine = await repo.fetchAndSetRoutineFullServer(routineId);

    // Hydrate data
    Future<void> setExercisesAndUnits(List<DayData> entries) async {
      for (final entry in entries) {
        for (final slot in entry.slots) {
          for (final setConfig in slot.setConfigs) {
            final exerciseId = setConfig.exerciseId;
            setConfig.exercise = exercises.firstWhere((e) => e.id == exerciseId);
            setConfig.repetitionsUnit = repetitionUnits.firstWhere(
              (e) => e.id == setConfig.repetitionsUnitId,
            );
            setConfig.weightUnit = weightUnits.firstWhere((e) => e.id == setConfig.weightUnitId);
          }
        }
      }
    }

    setExercisesAndUnits(routine.dayDataGym);
    setExercisesAndUnits(routine.dayData);

    // Update state
    final updatedRoutines = [...state.routines];
    final index = updatedRoutines.indexWhere((r) => r.id == routineId);
    if (index != -1) {
      updatedRoutines[index] = routine;
    } else {
      updatedRoutines.add(routine);
    }
    state = state.copyWith(routines: updatedRoutines);

    return routine;
  }

  Future<void> deleteRoutine(int routineId) async {
    final repo = ref.read(routinesRepositoryProvider);
    await repo.deleteRoutineServer(routineId);

    final routineIndex = state.routines.indexWhere((element) => element.id == routineId);
    state.routines.removeAt(routineIndex);
  }

  Future<void> editRoutine(Routine routine) async {
    final repo = ref.read(routinesRepositoryProvider);
    final updatedRoutine = await repo.editRoutineServer(routine);

    final updatedRoutines = [...state.routines];
    final index = updatedRoutines.indexWhere((r) => r.id == routine.id);
    if (index != -1) {
      updatedRoutines[index] = updatedRoutine;
      state = state.copyWith(routines: updatedRoutines);
    }
  }

  /*
   * Days
   */
  Future<Day> addDay(Day day) async {
    final repo = ref.read(routinesRepositoryProvider);
    final newDay = await repo.addDayServer(day);
    await repo.fetchAndSetRoutineFullServer(day.routineId);

    return newDay;
  }

  Future<void> editDay(Day day) async {
    final repo = ref.read(routinesRepositoryProvider);
    await repo.editDayServer(day);
    await repo.fetchAndSetRoutineFullServer(day.routineId);
  }

  Future<void> editDays(List<Day> days) async {
    final repo = ref.read(routinesRepositoryProvider);
    for (final day in days) {
      await repo.editDayServer(day);
    }
  }

  Future<void> deleteDay(int dayId, int routineId) async {
    final repo = ref.read(routinesRepositoryProvider);
    await repo.deleteDayServer(dayId);
    await repo.fetchAndSetRoutineFullServer(routineId);
  }

  /*
   * Slots
   */
  Future<Slot> addSlot(Slot slot, int routineId) async {
    final repo = ref.read(routinesRepositoryProvider);
    final newSlot = await repo.addSlotServer(slot);
    await repo.fetchAndSetRoutineFullServer(routineId);
    return newSlot;
  }

  Future<void> deleteSlot(int slotId, int routineId) async {
    final repo = ref.read(routinesRepositoryProvider);
    await repo.deleteSlotServer(slotId);
    await repo.fetchAndSetRoutineFullServer(routineId);
  }

  Future<void> editSlot(Slot slot, int routineId) async {
    final repo = ref.read(routinesRepositoryProvider);
    await repo.editSlotServer(slot);
    await repo.fetchAndSetRoutineFullServer(routineId);
  }

  Future<void> editSlots(List<Slot> slots, int routineId) async {
    final repo = ref.read(routinesRepositoryProvider);
    for (final slot in slots) {
      await repo.editSlotServer(slot);
    }

    await repo.fetchAndSetRoutineFullServer(routineId);
  }

  /*
   * Slot entries
   */
  Future<SlotEntry> addSlotEntry(SlotEntry entry, int routineId) async {
    final repo = ref.read(routinesRepositoryProvider);
    final newEntry = await repo.addSlotEntryServer(entry);
    await repo.fetchAndSetRoutineFullServer(routineId);

    return newEntry;
  }

  Future<void> deleteSlotEntry(int id, int routineId) async {
    final repo = ref.read(routinesRepositoryProvider);
    await repo.deleteSlotEntryServer(id);

    await repo.fetchAndSetRoutineFullServer(routineId);
  }

  Future<void> editSlotEntry(SlotEntry entry, int routineId) async {
    final repo = ref.read(routinesRepositoryProvider);
    await repo.editSlotEntryServer(entry);

    await repo.fetchAndSetRoutineFullServer(routineId);
  }

  /*
   * Configs
   */
  Future<void> editConfig(SlotEntry entry, num? value, ConfigType type, int routineId) async {
    final repo = ref.read(routinesRepositoryProvider);
    await repo.handleConfigServer(entry, value, type);
    await repo.fetchAndSetRoutineFullServer(routineId);
  }

  Future<BaseConfig> addConfig(BaseConfig config, ConfigType type) async {
    final repo = ref.read(routinesRepositoryProvider);
    return repo.addConfigServer(config, type);
  }

  Future<void> deleteConfig(int id, ConfigType type) async {
    final repo = ref.read(routinesRepositoryProvider);
    await repo.deleteConfigServer(id, type);
  }

  Future<void> handleConfig(SlotEntry entry, num? value, ConfigType type) async {
    final repo = ref.read(routinesRepositoryProvider);
    await repo.handleConfigServer(entry, value, type);
  }
}

@riverpod
RoutinesRepository routinesRepository(Ref ref) {
  final baseProvider = ref.watch(wgerBaseProvider);
  return RoutinesRepository(baseProvider);
}

class RoutinesRepository {
  RoutinesRepository(this._baseProvider);

  final WgerBaseProvider _baseProvider;
  static const _routinesUrlPath = 'routine';
  static const _routinesStructureSubpath = 'structure';
  static const _routinesDateSequenceDisplaySubpath = 'date-sequence-display';
  static const _routinesDateSequenceGymSubpath = 'date-sequence-gym';
  static const _daysUrlPath = 'day';
  static const _slotsUrlPath = 'slot';
  static const _slotEntriesUrlPath = 'slot-entry';
  static const _routineConfigSets = 'sets-config';
  static const _routineConfigMaxSets = 'max-sets-config';
  static const _routineConfigWeights = 'weight-config';
  static const _routineConfigMaxWeights = 'max-weight-config';
  static const _routineConfigRepetitions = 'repetitions-config';
  static const _routineConfigMaxRepetitions = 'max-repetitions-config';
  static const _routineConfigRir = 'rir-config';
  static const _routineConfigMaxRir = 'max-rir-config';
  static const _routineConfigRestTime = 'rest-config';
  static const _routineConfigMaxRestTime = 'max-rest-config';

  /*
   * Routines
   */
  Future<List<Routine>> fetchAllRoutinesSparseServer() async {
    final data = await _baseProvider.fetch(
      _baseProvider.makeUrl(
        _routinesUrlPath,
        query: {'limit': '1000', 'is_template': 'false'},
      ),
    );
    final results = data['results'] as List;
    return results.map((json) => Routine.fromJson(json)).toList();
  }

  Future<Routine> fetchAndSetRoutineFullServer(int routineId) async {
    // Fetch structure and computed data
    final results = await Future.wait([
      _baseProvider.fetch(
        _baseProvider.makeUrl(
          _routinesUrlPath,
          objectMethod: _routinesStructureSubpath,
          id: routineId,
        ),
      ),
      _baseProvider.fetch(
        _baseProvider.makeUrl(
          _routinesUrlPath,
          id: routineId,
          objectMethod: _routinesDateSequenceDisplaySubpath,
        ),
      ),
      _baseProvider.fetch(
        _baseProvider.makeUrl(
          _routinesUrlPath,
          id: routineId,
          objectMethod: _routinesDateSequenceGymSubpath,
        ),
      ),
    ]);

    final routine = Routine.fromJson(results[0] as Map<String, dynamic>);
    final dayData = results[1] as List<dynamic>;
    final dayDataGym = results[2] as List<dynamic>;

    routine.dayData = dayData.map((entry) => DayData.fromJson(entry)).toList();
    routine.dayDataGym = dayDataGym.map((entry) => DayData.fromJson(entry)).toList();

    return routine;
  }

  Future<Routine> addRoutineServer(Routine routine) async {
    final data = await _baseProvider.post(
      routine.toJson(),
      _baseProvider.makeUrl(_routinesUrlPath),
    );
    return Routine.fromJson(data);
  }

  Future<Routine> editRoutineServer(Routine routine) async {
    await _baseProvider.patch(
      routine.toJson(),
      _baseProvider.makeUrl(_routinesUrlPath, id: routine.id),
    );
    return fetchAndSetRoutineFullServer(routine.id!);
  }

  Future<void> deleteRoutineServer(int id) async {
    await _baseProvider.deleteRequest(_routinesUrlPath, id);
  }

  /*
   * Days
   */
  Future<Day> addDayServer(Day day) async {
    final data = await _baseProvider.post(
      day.toJson(),
      _baseProvider.makeUrl(_daysUrlPath),
    );
    day = Day.fromJson(data);

    fetchAndSetRoutineFullServer(day.routineId);

    return day;
  }

  Future<void> editDayServer(Day day) async {
    await _baseProvider.patch(
      day.toJson(),
      _baseProvider.makeUrl(_daysUrlPath, id: day.id),
    );
  }

  Future<void> deleteDayServer(int dayId) async {
    await _baseProvider.deleteRequest(_daysUrlPath, dayId);
  }

  /*
   * Slots
   */
  Future<Slot> addSlotServer(Slot slot) async {
    final data = await _baseProvider.post(
      slot.toJson(),
      _baseProvider.makeUrl(_slotsUrlPath),
    );
    final newSlot = Slot.fromJson(data);
    return newSlot;
  }

  Future<void> deleteSlotServer(int slotId) async {
    await _baseProvider.deleteRequest(_slotsUrlPath, slotId);
  }

  Future<void> editSlotServer(Slot slot) async {
    await _baseProvider.patch(
      slot.toJson(),
      _baseProvider.makeUrl(_slotsUrlPath, id: slot.id),
    );
  }

  /*
   * Slot entries
   */
  Future<SlotEntry> addSlotEntryServer(SlotEntry entry) async {
    final data = await _baseProvider.post(
      entry.toJson(),
      _baseProvider.makeUrl(_slotEntriesUrlPath),
    );
    return SlotEntry.fromJson(data);
  }

  Future<void> deleteSlotEntryServer(int id) async {
    await _baseProvider.deleteRequest(_slotEntriesUrlPath, id);
  }

  Future<void> editSlotEntryServer(SlotEntry entry) async {
    await _baseProvider.patch(
      entry.toJson(),
      _baseProvider.makeUrl(_slotEntriesUrlPath, id: entry.id),
    );
  }

  /*
   * Configs
   */
  String _getConfigUrl(ConfigType type) {
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

  Future<BaseConfig> editConfigServer(BaseConfig config, ConfigType type) async {
    final data = await _baseProvider.patch(
      config.toJson(),
      _baseProvider.makeUrl(_getConfigUrl(type), id: config.id),
    );

    return BaseConfig.fromJson(data);
  }

  Future<BaseConfig> addConfigServer(BaseConfig config, ConfigType type) async {
    final data = await _baseProvider.post(
      config.toJson(),
      _baseProvider.makeUrl(_getConfigUrl(type)),
    );
    return BaseConfig.fromJson(data);
  }

  Future<void> deleteConfigServer(int id, ConfigType type) async {
    await _baseProvider.deleteRequest(_getConfigUrl(type), id);
  }

  Future<void> handleConfigServer(SlotEntry entry, num? value, ConfigType type) async {
    final configs = entry.getConfigsByType(type);
    final config = configs.isNotEmpty ? configs.first : null;
    // final value = input.isNotEmpty ? num.parse(input) : null;

    if (value == null && config != null) {
      // Value removed, delete entry
      configs.removeWhere((c) => c.id! == config.id!);
      await deleteConfigServer(config.id!, type);
    } else if (config != null) {
      // Update existing value
      configs.first.value = value!;
      await editConfigServer(configs.first, type);
    } else if (value != null && config == null) {
      // Create new config
      configs.add(
        await addConfigServer(
          BaseConfig.firstIteration(value, entry.id!),
          type,
        ),
      );
    }
  }
}
