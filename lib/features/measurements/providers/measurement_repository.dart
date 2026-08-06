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

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:wger/database/powersync/database.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';

final measurementRepositoryProvider = Provider<MeasurementRepository>((ref) {
  final db = ref.read(driftPowerSyncDatabase);
  return MeasurementRepository(db);
});

class MeasurementRepository {
  final _logger = Logger('MeasurementRepository');
  final DriftPowersyncDatabase _db;

  MeasurementRepository(this._db);

  /// Watches all categories, populated with their appropriate entries.
  ///
  /// The list is flat (children of multi-value groups appear as regular items
  /// with a non-null `parentId`), but group parents additionally get their
  /// [MeasurementCategory.children] attached, sorted by their in-group order.
  /// [entriesSince] limits the entries to those on or after it; null reads the
  /// full history. The categories themselves are returned either way.
  Stream<List<MeasurementCategory>> watchAll({DateTime? entriesSince}) {
    _logger.finer('Watching all measurement categories with entries');
    return _watchCategories(entriesSince: entriesSince);
  }

  /// Watches the categories matching [filter] (all of them when it is null),
  /// each populated with its entries and, for group parents, its children.
  ///
  /// [entriesSince] bounds the entries in the query rather than afterwards, so
  /// a chart showing three months does not materialise years of rows.
  Stream<List<MeasurementCategory>> _watchCategories({
    Expression<bool> Function($MeasurementCategoryTableTable table)? filter,
    DateTime? entriesSince,
  }) {
    final select = _db.select(_db.measurementCategoryTable);
    if (filter != null) {
      select.where(filter);
    }

    // The date bound belongs into the join condition, not into a where: as a
    // where it would drop the categories that have no entry in the range,
    // turning the outer join into an inner one.
    var on = _db.measurementEntryTable.categoryId.equalsExp(_db.measurementCategoryTable.id);
    if (entriesSince != null) {
      on = on & _db.measurementEntryTable.date.isBiggerOrEqualValue(entriesSince);
    }

    final joined =
        select.join([
          leftOuterJoin(_db.measurementEntryTable, on),
        ])..orderBy([
          OrderingTerm(expression: _db.measurementCategoryTable.order),
          OrderingTerm(expression: _db.measurementCategoryTable.name),
          OrderingTerm(expression: _db.measurementEntryTable.date, mode: OrderingMode.desc),
        ]);

    return joined.watch().map((rows) {
      final Map<String, MeasurementCategory> map = {};
      // Guards against the same entry being added twice. Scanning the list
      // built so far would do, but is quadratic, and a category can hold
      // thousands of entries.
      final Map<String, Set<String>> seen = {};

      for (final row in rows) {
        final category = row.readTable(_db.measurementCategoryTable);
        final entry = row.readTableOrNull(_db.measurementEntryTable);

        final current = map.putIfAbsent(
          category.id!,
          () => category.copyWith(entries: []),
        );

        if (entry != null && seen.putIfAbsent(category.id!, () => {}).add(entry.id!)) {
          current.entries.add(entry);
        }
      }

      final categories = map.values
          .map((c) => c.copyWith(entries: List<MeasurementEntry>.from(c.entries)))
          .toList();

      // Attach children to their group parents (rows are already sorted by
      // order/name, so insertion order is the display order).
      return categories.map((c) {
        final children = categories.where((other) => other.parentId == c.id).toList();
        return children.isEmpty ? c : c.copyWith(children: children);
      }).toList();
    });
  }

  /// Watches a single category with its entries, and its children when it is
  /// a group parent.
  Stream<MeasurementCategory?> watchLocalDriftCategoryById(String id, {DateTime? entriesSince}) {
    _logger.finer('Watching local measurement category $id');
    return _watchCategories(
      filter: (table) => table.id.equals(id) | table.parentId.equals(id),
      entriesSince: entriesSince,
    ).map((categories) => categories.firstWhereOrNull((c) => c.id == id));
  }

  /// Watches the user's official body weight category with its entries.
  ///
  /// The category has no fixed id (the server assigns it), so it is selected
  /// by its type in the query rather than picked out of every category
  /// afterwards: reading all of them would materialise every other category's
  /// entries as well, and the health sync writes five sleep rows a night.
  Stream<MeasurementCategory?> watchOfficialBodyWeightCategory({DateTime? entriesSince}) {
    _logger.finer('Watching the official body weight category');
    return _watchCategories(
      filter: (table) =>
          table.isOfficial.equals(true) & table.metricType.equalsValue(MetricType.bodyWeight),
      entriesSince: entriesSince,
    ).map((categories) => categories.firstOrNull);
  }

  /// The newest entry of every category, keyed by category id.
  ///
  /// For the places that show the last known value without charting anything:
  /// reading a range wide enough to be sure to contain it would materialise
  /// every entry in that range, and a metric synced from a watch writes
  /// hundreds a day.
  Stream<Map<String, MeasurementEntry>> watchLatestEntries() {
    _logger.finer('Watching the latest measurement entry per category');

    final table = _db.measurementEntryTable;
    // Not the typed API: its datetime aggregate goes through UNIXEPOCH and
    // drops the sub-second part the sync writes, and the NOT EXISTS it can
    // express wraps both dates in JULIANDAY, losing the index (0.2 s vs 90 s)
    final query = _db.customSelect(
      'SELECT entry.* FROM ${table.actualTableName} entry '
      'WHERE entry.date = ('
      'SELECT MAX(newest.date) FROM ${table.actualTableName} newest '
      'WHERE newest.category_id = entry.category_id)',
      readsFrom: {table},
    );

    // Entries that share the newest timestamp (the importer writes a day
    // aggregate on midnight) collapse onto one, which is what a single latest
    // value means
    return query.watch().map((rows) {
      final entries = rows.map((row) => table.map(row.data));
      return {for (final entry in entries) entry.categoryId: entry};
    });
  }

  /// One-shot snapshot of all categories with their entries.
  Future<List<MeasurementCategory>> getAllOnce() => watchAll().first;

  // Entries
  Future<void> deleteLocalDrift(String id) async {
    _logger.finer('Deleting local measurement entry $id');
    await (_db.delete(_db.measurementEntryTable)..where((t) => t.id.equals(id))).go();
  }

  Future<void> updateLocalDrift(MeasurementEntry entry) async {
    _logger.finer('Updating local measurement entry ${entry.id}');
    final stmt = _db.update(_db.measurementEntryTable)..where((t) => t.id.equals(entry.id!));
    await stmt.write(entry.toCompanion());
  }

  Future<void> addLocalDrift(MeasurementEntry entry) async {
    _logger.finer('Adding local measurement entry ${entry.date}');
    await _db.into(_db.measurementEntryTable).insert(entry.toCompanion());
  }

  /// Inserts one reading of a multi-value group: one entry per component,
  /// written in a single transaction so a reading is never half-persisted.
  Future<void> addLocalDriftGroupEntries(List<MeasurementEntry> entries) async {
    _logger.finer('Adding ${entries.length} local measurement entries for a group reading');
    await _db.transaction(() async {
      for (final entry in entries) {
        await _db.into(_db.measurementEntryTable).insert(entry.toCompanion());
      }
    });
  }

  // Categories
  Future<void> deleteLocalDriftCategory(String id) async {
    _logger.finer('Deleting local measurement category $id');
    await _db.transaction(() async {
      // Children of a multi-value group are meaningless without their parent;
      // the server cascades the same way.
      await (_db.delete(_db.measurementCategoryTable)..where((t) => t.parentId.equals(id))).go();
      await (_db.delete(_db.measurementCategoryTable)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<void> updateLocalDriftCategory(MeasurementCategory category) async {
    _logger.finer('Updating local measurement category ${category.id}');
    final stmt = _db.update(_db.measurementCategoryTable)..where((t) => t.id.equals(category.id!));
    await stmt.write(category.toCompanion());
  }

  Future<void> addLocalDriftCategory(MeasurementCategory category) async {
    _logger.finer('Adding local measurement category ${category.name}');
    await _db.into(_db.measurementCategoryTable).insert(category.toCompanion());
  }

  /// Persists the given display order: each category gets its list index as
  /// [MeasurementCategory.order]. Categories whose order is unchanged are not
  /// written, so no sync upload is queued for them.
  Future<void> reorderCategories(List<String> orderedIds) async {
    _logger.finer('Reordering ${orderedIds.length} categories');
    await _db.transaction(() async {
      for (var i = 0; i < orderedIds.length; i++) {
        final stmt = _db.update(_db.measurementCategoryTable)
          ..where((t) => t.id.equals(orderedIds[i]) & t.order.equals(i).not());
        await stmt.write(MeasurementCategoryTableCompanion(order: Value(i)));
      }
    });
  }
}
