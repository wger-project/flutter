/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
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

import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/features/routines/models/log.dart';
import 'package:wger/features/routines/providers/workout_logs_repository.dart';

part 'workout_logs_notifier.g.dart';

final workoutLogProvider = Provider<WorkoutLogMutations>((ref) {
  return WorkoutLogMutations(ref.read(workoutLogRepositoryProvider));
});

/// Streams the past logs for [exerciseId], newest first.
///
/// Without [weeksBack] only the logs of [routineId] are returned. Setting it
/// widens the scope to all routines and instead limits the logs to the last
/// [weeksBack] weeks, in which case [routineId] is ignored. With [distinct],
/// only the newest log of each repetition/weight combination is kept.
@riverpod
Stream<List<Log>> pastExerciseLogs(
  Ref ref, {
  required int routineId,
  required int exerciseId,
  int? weeksBack,
  bool distinct = true,
}) {
  final repo = ref.read(workoutLogRepositoryProvider);
  final cutoff = weeksBack != null ? clock.now().subtract(Duration(days: weeksBack * 7)) : null;

  return repo
      .watchLogsByExerciseDrift(
        routineId: weeksBack == null ? routineId : null,
        exerciseId: exerciseId,
        since: cutoff,
      )
      .map((logs) => distinct ? _deduplicate(logs) : logs);
}

/// Keeps only the first log of each repetitions/weight combination, units included.
///
/// Expects [logs] to be sorted newest first, so the newest log of each
/// combination survives.
List<Log> _deduplicate(List<Log> logs) {
  final seen = <(num?, int?, num?, int?)>{};

  return logs
      .where(
        (log) => seen.add((log.repetitions, log.repetitionsUnitId, log.weight, log.weightUnitId)),
      )
      .toList();
}

class WorkoutLogMutations {
  final WorkoutLogRepository _repo;

  WorkoutLogMutations(this._repo);

  Future<void> addEntry(Log log) => _repo.addLocalDrift(log);

  Future<void> updateEntry(Log log) => _repo.updateLocalDrift(log);

  Future<void> deleteEntry(String id) => _repo.deleteLocalDrift(id);
}
