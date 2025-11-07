/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020,  wger Team
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

import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/models/workouts/log.dart';

import 'workout_log_repository.dart';

part 'workout_logs.g.dart';

@riverpod
final class WorkoutLogNotifier extends _$WorkoutLogNotifier {
  final _logger = Logger('WorkoutLogNotifier');
  late final WorkoutLogRepository _repo;

  @override
  Stream<List<Log>> build() {
    _repo = ref.read(workoutLogRepositoryProvider);
    return _repo.watchAllDrift();
  }

  Future<void> deleteEntry(String id) async {
    await _repo.deleteLocalDrift(id);
  }

  Future<void> updateEntry(Log log) async {
    await _repo.updateLocalDrift(log);
  }

  Future<void> addEntry(Log log) async {
    await _repo.addLocalDrift(log);
  }
}
