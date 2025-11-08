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
import 'package:wger/models/workouts/session.dart';
import 'package:wger/providers/workout_session_repository.dart';

part 'workout_session.g.dart';

@riverpod
Future<void> sessionStateReady(Ref ref) {
  return Future.wait([
    ref.watch(workoutSessionProvider.future),
  ]);
}

@riverpod
final class WorkoutSessionNotifier extends _$WorkoutSessionNotifier {
  final _logger = Logger('WorkoutSessionNotifier');
  late final WorkoutSessionRepository _repo;

  @override
  Stream<List<WorkoutSession>> build() {
    _repo = ref.read(workoutSessionRepositoryProvider);
    return _repo.watchAllDrift();
  }

  Future<void> deleteEntry(String id) async {
    await _repo.deleteLocalDrift(id);
  }

  Future<void> updateEntry(WorkoutSession entry) async {
    await _repo.editLocalDrift(entry);
  }

  Future<void> addEntry(WorkoutSession entry) async {
    await _repo.addLocalDrift(entry);
  }
}
