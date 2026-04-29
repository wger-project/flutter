/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2026 wger Team
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

import 'package:collection/collection.dart';
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
import 'package:wger/providers/exercises.dart';
import 'package:wger/providers/helpers.dart';
import 'package:wger/providers/routines_repository.dart';
import 'package:wger/providers/workout_session.dart';

part 'routines.g.dart';

// Reference-data streams: kept alive across the app's lifetime so that
// callers using `ref.read(...future)` (notably [fetchAndSetRoutineFull])
// don't race the auto-dispose scheduler and crash with "provider was
// disposed during loading state".
@Riverpod(keepAlive: true)
Stream<List<WeightUnit>> routineWeightUnit(Ref ref) {
  final db = ref.read(driftPowerSyncDatabase);
  return db.select(db.routineWeightUnitTable).watch();
}

@Riverpod(keepAlive: true)
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
    return RoutinesState(routines: routines ?? this.routines);
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
  Stream<RoutinesState> build() {
    _logger.fine('Building Routines Riverpod notifier');
    ref.keepAlive();

    // Top-level routine list comes from PowerSync (Drift stream over
    // the synced `manager_routine` table). The sub-hierarchy (days,
    // slots, …) still lives behind REST and is layered on top by
    // callers via [fetchAndSetRoutineFull]. To prevent those sub-data
    // from being wiped out every time the stream re-emits the routines
    // (e.g. after a remote edit), we re-attach them from the previous
    // state below.
    final repo = ref.read(routinesRepositoryProvider);
    return repo.watchAllDrift().map((freshRoutines) {
      final existing = state.value?.routines ?? const <Routine>[];
      for (final fresh in freshRoutines) {
        final old = existing.firstWhereOrNull((r) => r.id == fresh.id);
        if (old != null) {
          fresh.days = old.days;
          fresh.dayData = old.dayData;
          fresh.dayDataGym = old.dayDataGym;
          fresh.sessions = old.sessions;
        }
      }
      return RoutinesState(routines: freshRoutines);
    });
  }

  /*
   * Routines
   */
  Future<Routine> addRoutine(Routine routine) async {
    // Creation still goes through REST: the backend assigns the integer
    // PK and any auto-fields (created etc.). PowerSync will eventually
    // replicate the new row down via the stream, but to avoid a
    // perceptible UI lag we also inject the freshly-created routine
    // into state right away. When the stream later re-emits the same
    // row, build()'s sub-data preservation logic keeps things stable.
    final repo = ref.read(routinesRepositoryProvider);
    final created = await repo.addRoutineServer(routine);
    final current = state.value ?? const RoutinesState();
    // Re-sort to match Django's `Meta.ordering = ['-start', '-created']` so
    // a freshly-created routine with an older start date doesn't briefly
    // jump to the front before the next stream emission corrects it.
    final routines = [created, ...current.routines]
      ..sort((a, b) {
        final byStart = b.start.compareTo(a.start);
        return byStart != 0 ? byStart : b.created.compareTo(a.created);
      });
    state = AsyncData(current.copyWith(routines: routines));
    return created;
  }

  Future<Routine> fetchAndSetRoutineFull(int routineId) async {
    final repo = ref.read(routinesRepositoryProvider);

    final exerciseState = await ref.awaitFirstValue(exercisesProvider);
    final repetitionUnits = await ref.awaitFirstValue(routineRepetitionUnitProvider);
    final weightUnits = await ref.awaitFirstValue(routineWeightUnitProvider);
    final sessions = await ref.awaitFirstValue(workoutSessionProvider);
    final routine = await repo.fetchAndSetRoutineFullServer(routineId);

    // Hydrate exercises + units on every set config
    Future<void> setExercisesAndUnits(List<DayData> entries) async {
      for (final entry in entries) {
        for (final slot in entry.slots) {
          for (final setConfig in slot.setConfigs) {
            setConfig.exercise = exerciseState.getById(setConfig.exerciseId);
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

    // Attach sessions (already joined with their logs) that belong to this routine
    // and set the appropriate exercises
    routine.sessions = sessions.where((s) => s.routineId == routineId).toList();
    for (final session in routine.sessions) {
      for (final log in session.logs) {
        log.exercise = exerciseState.getById(log.exerciseId);
      }
    }

    // Inject the hydrated routine into the current state. Note: this is
    // a transient overlay — the next PowerSync stream tick re-emits the
    // top-level routine (without sub-data), but `build()` re-attaches
    // sub-data from the previous state, so the hydration survives.
    final current = state.value ?? const RoutinesState();
    final updatedRoutines = [...current.routines];
    final index = updatedRoutines.indexWhere((r) => r.id == routineId);
    if (index != -1) {
      updatedRoutines[index] = routine;
    } else {
      updatedRoutines.add(routine);
    }
    state = AsyncData(current.copyWith(routines: updatedRoutines));

    return routine;
  }

  Future<void> deleteRoutine(int routineId) async {
    // Goes through PowerSync (Drift delete → CRUD queue → backend).
    // Local state picks up the removal on the next stream emission.
    final repo = ref.read(routinesRepositoryProvider);
    await repo.deleteLocalDrift(routineId);
  }

  Future<void> editRoutine(Routine routine) async {
    // Goes through PowerSync (Drift update → CRUD queue → backend).
    // Local state picks up the change on the next stream emission.
    final repo = ref.read(routinesRepositoryProvider);
    await repo.editLocalDrift(routine);
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
