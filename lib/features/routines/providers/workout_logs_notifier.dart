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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/features/routines/models/log.dart';
import 'package:wger/features/routines/providers/workout_logs_repository.dart';

part 'workout_logs_notifier.g.dart';

final workoutLogProvider = Provider<WorkoutLogMutations>((ref) {
  return WorkoutLogMutations(ref.read(workoutLogRepositoryProvider));
});

/// Streams the past logs for [exerciseId] within [routineId], newest first.
@riverpod
Stream<List<Log>> pastExerciseLogs(
  Ref ref, {
  required int routineId,
  required int exerciseId,
}) {
  return ref
      .read(workoutLogRepositoryProvider)
      .watchLogsByExerciseDrift(routineId: routineId, exerciseId: exerciseId);
}

class WorkoutLogMutations {
  final WorkoutLogRepository _repo;

  WorkoutLogMutations(this._repo);

  Future<void> addEntry(Log log) => _repo.addLocalDrift(log);

  Future<void> updateEntry(Log log) => _repo.updateLocalDrift(log);

  Future<void> deleteEntry(String id) => _repo.deleteLocalDrift(id);
}
