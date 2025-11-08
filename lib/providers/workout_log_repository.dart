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
import 'package:wger/models/workouts/log.dart';
import 'package:wger/providers/exercise_state_notifier.dart';

import '../database/powersync/database.dart';

final workoutLogRepositoryProvider = Provider<WorkoutLogRepository>((ref) {
  final db = ref.read(driftPowerSyncDatabase);
  return WorkoutLogRepository(db, ref);
});

class WorkoutLogRepository {
  final _logger = Logger('WorkoutLogRepository');
  final DriftPowersyncDatabase _db;
  final Ref _ref;

  WorkoutLogRepository(this._db, this._ref);

  Stream<List<Log>> watchAllDrift() {
    _logger.finer('Watching all local workout log entries');
    final exercisesProvider = _ref.read(exerciseStateProvider.notifier);

    final query = _db.select(_db.workoutLogTable)
      ..orderBy(
        [(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)],
      );

    final joined = query.join([
      leftOuterJoin(
        _db.routineRepetitionUnitTable,
        _db.routineRepetitionUnitTable.id.equalsExp(_db.workoutLogTable.repetitionsUnitId),
      ),
      leftOuterJoin(
        _db.routineWeightUnitTable,
        _db.routineWeightUnitTable.id.equalsExp(_db.workoutLogTable.weightUnitId),
      ),
    ]);

    return joined.watch().map((rows) {
      final Map<String, Log> map = {};

      for (final row in rows) {
        final log = row.readTable(_db.workoutLogTable);
        final repetitionUnit = row.readTableOrNull(_db.routineRepetitionUnitTable);
        final weightUnit = row.readTableOrNull(_db.routineWeightUnitTable);

        final entry = map.putIfAbsent(
          log.id!,
          () => log,
        );

        if (repetitionUnit != null) {
          entry.repetitionUnit = repetitionUnit;
        }

        if (weightUnit != null) {
          entry.weightUnit = weightUnit;
        }

        try {
          log.exerciseBase = exercisesProvider.getById(log.exerciseId);
        } catch (e) {
          _logger.warning(
            'Could not find exercise for log entry ${log.id} with exercise ID ${log.exerciseId}',
          );
        }
      }

      return map.values.toList();
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

  Future<void> addLocalDrift(Log log) async {
    _logger.finer('Adding local workout log entry ${log.date}');
    await _db.into(_db.workoutLogTable).insert(log.toCompanion());
  }
}
