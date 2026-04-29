/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 wger Team
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

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/database/powersync/database.dart';
import 'package:wger/models/workouts/base_config.dart';
import 'package:wger/models/workouts/day.dart';
import 'package:wger/models/workouts/day_data.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/models/workouts/slot.dart';
import 'package:wger/models/workouts/slot_entry.dart';
import 'package:wger/providers/base_provider.dart';
import 'package:wger/providers/wger_base.dart';

part 'routines_repository.g.dart';

@Riverpod(keepAlive: true)
RoutinesRepository routinesRepository(Ref ref) {
  final baseProvider = ref.watch(wgerBaseProvider);
  final db = ref.read(driftPowerSyncDatabase);
  return RoutinesRepository(baseProvider, db);
}

/// Data access for routine-related entities.
///
/// HTTP for everything that hasn't been migrated to PowerSync yet (creation
/// of routines, days, slots, slot entries, configs, …). Top-level [Routine]
/// reads as well as edit/delete go through the local PowerSync-backed Drift
/// table — see [watchAllDrift], [editLocalDrift], [deleteLocalDrift].
class RoutinesRepository {
  RoutinesRepository(this._baseProvider, this._db);

  final _logger = Logger('RoutinesRepository');
  final WgerBaseProvider _baseProvider;
  final DriftPowersyncDatabase _db;
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

  /// Streams all routines from the local PowerSync-backed Drift table.
  ///
  /// Templates (`is_template = TRUE`, including public ones) are excluded at
  /// the sync-rule level (see `sync_rules.yaml`), so they never reach the
  /// local DB — no client-side filter needed here.
  ///
  /// Sort matches Django's `Routine.Meta.ordering = ['-start', '-created']` so
  /// that REST responses and PowerSync emissions agree on the row order. The
  /// UI takes the first row as the active routine and the optimistic
  /// insertion in `RoutinesRiverpod.addRoutine` assumes newest-first.
  Stream<List<Routine>> watchAllDrift() {
    _logger.finer('Watching all local routines');
    return (_db.select(_db.routineTable)..orderBy([
          (t) => OrderingTerm.desc(t.start),
          (t) => OrderingTerm.desc(t.created),
        ]))
        .watch();
  }

  /// Updates a routine via the local Drift table.
  Future<void> editLocalDrift(Routine routine) async {
    final id = routine.id;
    if (id == null) {
      throw StateError('Cannot edit a routine without id');
    }
    _logger.finer('Updating local routine $id');
    await (_db.update(
      _db.routineTable,
    )..where((t) => t.id.equals(id))).write(routine.toCompanion());
  }

  /// Deletes a routine via the local Drift table.
  Future<void> deleteLocalDrift(int id) async {
    _logger.finer('Deleting local routine $id');
    await (_db.delete(_db.routineTable)..where((t) => t.id.equals(id))).go();
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
