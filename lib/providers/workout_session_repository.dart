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

/*
 * Repository for workout session local storage.
 */

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:wger/models/workouts/log.dart';
import 'package:wger/models/workouts/session.dart';

import '../database/powersync/database.dart';

final workoutSessionRepositoryProvider = Provider<WorkoutSessionRepository>((ref) {
  final db = ref.read(driftPowerSyncDatabase);
  return WorkoutSessionRepository(db);
});

class WorkoutSessionRepository {
  final _logger = Logger('WorkoutSessionRepository');
  final DriftPowersyncDatabase _db;

  WorkoutSessionRepository(this._db);

  /// Streams all workout sessions with their logs attached.
  Stream<List<WorkoutSession>> watchAllDrift() {
    _logger.finer('Watching all local workout session entries');

    final query = _db.select(_db.workoutSessionTable).join([
      leftOuterJoin(
        _db.workoutLogTable,
        _db.workoutLogTable.sessionId.equalsExp(_db.workoutSessionTable.id),
      ),
      leftOuterJoin(
        _db.routineRepetitionUnitTable,
        _db.routineRepetitionUnitTable.id.equalsExp(_db.workoutLogTable.repetitionsUnitId),
      ),
      leftOuterJoin(
        _db.routineWeightUnitTable,
        _db.routineWeightUnitTable.id.equalsExp(_db.workoutLogTable.weightUnitId),
      ),
    ])..orderBy([OrderingTerm(expression: _db.workoutSessionTable.date, mode: OrderingMode.desc)]);

    return query.watch().map((rows) {
      final sessions = <String, WorkoutSession>{};
      final logsBySession = <String, List<Log>>{};
      final seenLogs = <String>{};

      for (final row in rows) {
        final session = row.readTable(_db.workoutSessionTable);
        sessions.putIfAbsent(session.id!, () => session);
        final logs = logsBySession.putIfAbsent(session.id!, () => []);

        final log = row.readTableOrNull(_db.workoutLogTable);
        if (log == null || seenLogs.contains(log.id)) {
          continue;
        }
        seenLogs.add(log.id!);

        final repetitionUnit = row.readTableOrNull(_db.routineRepetitionUnitTable);
        if (repetitionUnit != null) {
          log.repetitionUnit = repetitionUnit;
        }
        final weightUnit = row.readTableOrNull(_db.routineWeightUnitTable);
        if (weightUnit != null) {
          log.weightUnit = weightUnit;
        }
        logs.add(log);
      }

      return sessions.values.map((s) => s.copyWith(logs: logsBySession[s.id]!)).toList();
    });
  }

  Future<void> deleteLocalDrift(String id) async {
    _logger.finer('Deleting local workout session entry $id');
    await (_db.delete(_db.workoutSessionTable)..where((t) => t.id.equals(id))).go();
  }

  Future<void> editLocalDrift(WorkoutSession session) async {
    _logger.finer('Updating local workout session entry ${session.id}');
    final stmt = _db.update(_db.workoutSessionTable)..where((t) => t.id.equals(session.id!));
    await stmt.write(session.toCompanion());
  }

  /// Inserts the session locally and returns the persisted row. When
  /// `session.id` is null, Drift mints one, so the returned session carries
  /// the id the caller needs to reference it.
  Future<WorkoutSession> addLocalDrift(WorkoutSession session) async {
    _logger.finer('Adding local workout session entry ${session.date}');
    return _db.into(_db.workoutSessionTable).insertReturning(session.toCompanion());
  }
}
