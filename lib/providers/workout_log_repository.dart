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

import '../database/powersync/database.dart';

final workoutLogRepositoryProvider = Provider<WorkoutLogRepository>((ref) {
  final db = ref.read(driftPowerSyncDatabase);
  return WorkoutLogRepository(db);
});

class WorkoutLogRepository {
  final _logger = Logger('WorkoutLogRepository');
  final DriftPowersyncDatabase _db;

  WorkoutLogRepository(this._db);

  Stream<List<Log>> watchAllDrift() {
    _logger.finer('Watching all local workout log entries');
    final query = _db.select(_db.workoutLogTable)
      ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]);
    return query.watch();
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
