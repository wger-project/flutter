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

/*
 * Repository for measurement entries (local Drift operations).
 */

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:wger/models/measurements/measurement_category.dart';
import 'package:wger/models/measurements/measurement_entry.dart';

import '../database/powersync/database.dart';

final measurementRepositoryProvider = Provider<MeasurementRepository>((ref) {
  final db = ref.read(driftPowerSyncDatabase);
  return MeasurementRepository(db);
});

class MeasurementRepository {
  final _logger = Logger('MeasurementRepository');
  final DriftPowersyncDatabase _db;

  MeasurementRepository(this._db);

  /// Watches all categories, populated with their appropriate entries
  Stream<List<MeasurementCategory>> watchAll() {
    _logger.finer('Watching all measurement categories with entries');

    final joined =
        _db.select(_db.measurementCategoryTable).join([
          leftOuterJoin(
            _db.measurementEntryTable,
            _db.measurementEntryTable.category.equalsExp(_db.measurementCategoryTable.id),
          ),
        ])..orderBy([
          OrderingTerm(expression: _db.measurementCategoryTable.name),
          OrderingTerm(expression: _db.measurementEntryTable.date, mode: OrderingMode.desc),
        ]);

    return joined.watch().map((rows) {
      final Map<String, MeasurementCategory> map = {};

      for (final row in rows) {
        final category = row.readTable(_db.measurementCategoryTable);
        final entry = row.readTableOrNull(_db.measurementEntryTable);

        final current = map.putIfAbsent(
          category.id,
          () => category.copyWith(entries: []),
        );

        if (entry != null && !current.entries.any((e) => e.id == entry.id)) {
          current.entries.add(entry);
        }
      }

      return map.values
          .map((c) => c.copyWith(entries: List<MeasurementEntry>.from(c.entries)))
          .toList();
    });
  }

  // Entries
  Future<void> deleteLocalDrift(String id) async {
    _logger.finer('Deleting local measurement entry $id');
    await (_db.delete(_db.measurementEntryTable)..where((t) => t.id.equals(id))).go();
  }

  Future<void> updateLocalDrift(MeasurementEntry entry) async {
    _logger.finer('Updating local measurement entry ${entry.id}');
    final stmt = _db.update(_db.measurementEntryTable)..where((t) => t.id.equals(entry.id));
    await stmt.write(entry.toCompanion());
  }

  Future<void> addLocalDrift(MeasurementEntry entry) async {
    _logger.finer('Adding local measurement entry ${entry.date}');
    await _db.into(_db.measurementEntryTable).insert(entry.toCompanion());
  }

  // Categories
  Future<void> deleteLocalDriftCategory(String id) async {
    _logger.finer('Deleting local measurement category $id');
    await (_db.delete(_db.measurementCategoryTable)..where((t) => t.id.equals(id))).go();
  }

  Future<void> updateLocalDriftCategory(MeasurementCategory category) async {
    _logger.finer('Updating local measurement category ${category.id}');
    final stmt = _db.update(_db.measurementCategoryTable)..where((t) => t.id.equals(category.id));
    await stmt.write(category.toCompanion());
  }

  Future<void> addLocalDriftCategory(MeasurementCategory category) async {
    _logger.finer('Adding local measurement category ${category.name}');
    await _db.into(_db.measurementCategoryTable).insert(category.toCompanion());
  }
}
