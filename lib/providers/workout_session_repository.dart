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

/*
 * Repository for body weight network operations.
 */

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:wger/models/workouts/session.dart';

import '../database/powersync/database.dart';
import 'exercise_state_notifier.dart';

final workoutSessionRepositoryProvider = Provider<WorkoutSessionRepository>((ref) {
  final db = ref.read(driftPowerSyncDatabase);
  return WorkoutSessionRepository(db, ref);
});

class WorkoutSessionRepository {
  final _logger = Logger('WorkoutSessionRepository');
  final DriftPowersyncDatabase _db;
  final Ref _ref;

  WorkoutSessionRepository(this._db, this._ref);

  Stream<List<WorkoutSession>> watchAllDrift() {
    _logger.finer('Watching all local workout session entries');
    final query = _db.select(_db.workoutSessionTable)
      ..orderBy(
        [(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)],
      );

    return query.watch();
    // final joined = _buildJoinedQuery();
    // return joined.watch().map((rows) => _mapRowsToSessions(rows));
  }

  Stream<List<WorkoutSession>> watchRoutineDrift(int routineId) {
    _logger.finer('Watching local workout session entries for routine $routineId');
    final joined = _buildJoinedQuery(routineId: routineId);
    return joined.watch().map((rows) => _mapRowsToSessions(rows));
  }

  Future<void> deleteLocalDrift(String id) async {
    _logger.finer('Deleting local workout session entry $id');
    await (_db.delete(_db.workoutSessionTable)..where((t) => t.id.equals(id))).go();
  }

  Future<void> updateLocalDrift(WorkoutSession session) async {
    _logger.finer('Updating local workout session entry ${session.id}');
    final stmt = _db.update(_db.workoutSessionTable)..where((t) => t.id.equals(session.id!));
    await stmt.write(session.toCompanion());
  }

  Future<void> addLocalDrift(WorkoutSession session) async {
    _logger.finer('Adding local workout session entry ${session.date}');
    await _db.into(_db.workoutSessionTable).insert(session.toCompanion());
  }

  JoinedSelectStatement _buildJoinedQuery({int? routineId}) {
    final base = _db.select(_db.workoutSessionTable)
      ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]);

    if (routineId != null) {
      base.where((t) => t.routineId.equals(routineId));
    }

    return base.join([
      leftOuterJoin(
        _db.workoutSessionTable,
        _db.workoutLogTable.routineId.equalsExp(_db.workoutSessionTable.routineId),
      ),
      leftOuterJoin(
        _db.routineRepetitionUnitTable,
        _db.routineRepetitionUnitTable.id.equalsExp(_db.workoutLogTable.repetitionsUnitId),
      ),
      leftOuterJoin(
        _db.routineWeightUnitTable,
        _db.routineWeightUnitTable.id.equalsExp(_db.workoutLogTable.weightUnitId),
      ),
    ]);
  }

  List<WorkoutSession> _mapRowsToSessions(List<dynamic> rows) {
    final exercisesHelper = _ref.read(exerciseStateProvider.notifier);

    final Map<String, WorkoutSession> map = {};

    for (final row in rows) {
      final session = row.readTable(_db.workoutSessionTable);
      final log = row.readTableOrNull(_db.workoutLogTable);
      final repetitionUnit = row.readTableOrNull(_db.routineRepetitionUnitTable);
      final weightUnit = row.readTableOrNull(_db.routineWeightUnitTable);

      final entry = map.putIfAbsent(session.id!, () => session);

      if (log != null) {
        log.repetitionUnit = repetitionUnit;
        log.weightUnit = weightUnit;
        log.exerciseBase = exercisesHelper.getById(log.exerciseId);

        final exists = entry.logs.any((l) => l.id == log.id);
        if (!exists) {
          entry.logs.add(log);
        }
      }
    }

    return map.values.toList();
  }
}
