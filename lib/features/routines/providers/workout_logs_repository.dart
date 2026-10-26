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
 * Repository for body weight network operations.
 */

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:wger/core/json.dart';
import 'package:wger/database/powersync/database.dart';
import 'package:wger/features/routines/models/log.dart';
import 'package:wger/features/routines/models/session.dart';

final workoutLogRepositoryProvider = Provider<WorkoutLogRepository>((ref) {
  final db = ref.read(driftPowerSyncDatabase);
  return WorkoutLogRepository(db);
});

/// Local access to the `workout_log` table: writes (add/update/delete) plus a
/// per-exercise read stream. Reading logs grouped under their parent session
/// happens through `WorkoutSessionRepository.watchAllDrift`.
class WorkoutLogRepository {
  final _logger = Logger('WorkoutLogRepository');
  final DriftPowersyncDatabase _db;

  WorkoutLogRepository(this._db);

  /// Streams the logs for a single exercise, newest first, with their
  /// repetition and weight units attached.
  ///
  /// Only logs belonging to [routineId] are returned, pass null for all
  /// routines. [since] additionally restricts the result to logs on or after
  /// that point in time.
  Stream<List<Log>> watchLogsByExerciseDrift({
    int? routineId,
    required int exerciseId,
    DateTime? since,
  }) {
    _logger.finer(
      'Watching local logs for exercise $exerciseId, '
      'routine ${routineId ?? 'any'}, since ${since ?? 'always'}',
    );

    final query = _db.select(_db.workoutLogTable).join([
      leftOuterJoin(
        _db.routineRepetitionUnitTable,
        _db.routineRepetitionUnitTable.id.equalsExp(_db.workoutLogTable.repetitionsUnitId),
      ),
      leftOuterJoin(
        _db.routineWeightUnitTable,
        _db.routineWeightUnitTable.id.equalsExp(_db.workoutLogTable.weightUnitId),
      ),
    ]);

    var whereCondition = _db.workoutLogTable.exerciseId.equals(exerciseId);
    if (routineId != null) {
      whereCondition &= _db.workoutLogTable.routineId.equals(routineId);
    }
    if (since != null) {
      whereCondition &= _db.workoutLogTable.date.isBiggerOrEqualValue(since);
    }
    query.where(whereCondition);
    query.orderBy([
      OrderingTerm(expression: _db.workoutLogTable.date, mode: OrderingMode.desc),
    ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final log = row.readTable(_db.workoutLogTable);
        final repetitionUnit = row.readTableOrNull(_db.routineRepetitionUnitTable);
        if (repetitionUnit != null) {
          log.repetitionUnit = repetitionUnit;
        }
        final weightUnit = row.readTableOrNull(_db.routineWeightUnitTable);
        if (weightUnit != null) {
          log.weightUnit = weightUnit;
        }
        return log;
      }).toList();
    });
  }

  Future<void> deleteLocalDrift(String id) async {
    _logger.finer('Deleting local workout log entry $id');
    await (_db.delete(_db.workoutLogTable)..where((t) => t.id.equals(id))).go();
  }

  Future<void> updateLocalDrift(Log log) async {
    _logger.finer('Updating local workout log entry ${log.id}');
    final stmt = _db.update(_db.workoutLogTable)..where((t) => t.id.equals(log.id!));
    await stmt.write(log.toCompanion());
  }

  /// Persist a new workout log locally.
  ///
  /// If the log was created without a [Log.sessionId], the matching session is
  /// reused or, if none exists yet, a fresh one is created with [dayId]. Days
  /// that need logs to advance look sessions up by their day, so a lazy session
  /// without one stalls the routine's date sequence (issue wger#2460).
  ///
  /// Wrapping both writes in a Drift transaction guarantees atomicity: a
  /// partial failure either commits both rows or neither, so we never end
  /// up with an orphan session locally.
  Future<void> addLocalDrift(Log log, {int? dayId}) async {
    _logger.finer('Adding local workout log entry ${log.date}');

    await _db.transaction(() async {
      log.sessionId ??= await _sessionIdFor(log, dayId: dayId);

      final inserted = await _db.into(_db.workoutLogTable).insertReturning(log.toCompanion());
      log.id = inserted.id;
    });
  }

  /// The session a log without one belongs to, creating it if nothing fits.
  ///
  /// In order: a session the log falls into, then the most recent session that
  /// is still open and started no more than [sessionMaxDuration] ago, then one
  /// on the same day that carries no time at all, otherwise a new one. The first
  /// three mirror what the server does for logs uploaded without a session.
  Future<String?> _sessionIdFor(Log log, {int? dayId}) async {
    final at = dateToUtcIso8601(log.date);

    final covering =
        await (_db.select(_db.workoutSessionTable)
              ..where(
                (t) =>
                    t.routineId.equalsNullable(log.routineId) &
                    t.datetimeStart.isSmallerOrEqualValue(at) &
                    t.datetimeEnd.isBiggerOrEqualValue(at),
              )
              ..limit(1))
            .getSingleOrNull();
    if (covering != null) {
      return covering.id;
    }

    final windowStart = dateToUtcIso8601(log.date.subtract(sessionMaxDuration));
    final open =
        await (_db.select(_db.workoutSessionTable)
              ..where(
                (t) =>
                    t.routineId.equalsNullable(log.routineId) &
                    t.datetimeEnd.isNull() &
                    t.datetimeStart.isBiggerOrEqualValue(windowStart) &
                    t.datetimeStart.isSmallerOrEqualValue(at),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.datetimeStart)])
              ..limit(1))
            .getSingleOrNull();
    if (open != null) {
      return open.id;
    }

    // Sessions that came from the server without a time can only be matched by
    // their day. Dropping this would create a duplicate next to every one of them.
    final dayMidnightUtc = DateTime.utc(log.date.year, log.date.month, log.date.day);
    final sameDay =
        await (_db.select(_db.workoutSessionTable)
              ..where(
                (t) =>
                    t.routineId.equalsNullable(log.routineId) &
                    t.datetimeStart.isNull() &
                    t.date.equalsValue(dayMidnightUtc),
              )
              ..limit(1))
            .getSingleOrNull();
    if (sameDay != null) {
      return sameDay.id;
    }

    // The start has to be set, otherwise the lookups above can never find this
    // session again and every further log would create one of its own. The day
    // is set so the routine's date sequence advances (issue wger#2460).
    final created = await _db
        .into(_db.workoutSessionTable)
        .insertReturning(
          WorkoutSession(
            routineId: log.routineId,
            dayId: dayId,
            datetimeStart: log.date,
          ).toCompanion(),
        );
    _logger.finer('Created lazy session ${created.id} for log');

    return created.id;
  }
}
