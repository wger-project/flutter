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
import 'package:stream_transform/stream_transform.dart';
import 'package:wger/database/powersync/database.dart';
import 'package:wger/features/measurements/models/measurement_bucket.dart';
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

  /// Coalesces the bursts a health import writes, so the per-emission work
  /// below runs once they settle. Leading, unlike the nutrition streams: a
  /// screen is waiting for the first emission.
  static const _emitDebounce = Duration(milliseconds: 200);

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

    return joined.watch().debounce(_emitDebounce, leading: true).map((rows) {
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
    return query.watch().debounce(_emitDebounce, leading: true).map((rows) {
      final entries = rows.map((row) => table.map(row.data));
      return {for (final entry in entries) entry.categoryId: entry};
    });
  }

  /// Chart points for [categoryId]: one bucket per calendar unit, condensed by
  /// SQLite instead of by walking every entry in Dart.
  ///
  /// [level] fixes the unit for the charts built on one; `auto` takes the
  /// finest that keeps the series under [maxPoints], down to one bucket per
  /// entry. [since] bounds the entries read, null covers the full history.
  ///
  /// The ladder is the same one `downsample` walks in Dart for the paths that
  /// read entries; the two must stay in step.
  Stream<List<MeasurementBucket>> watchEntryBuckets(
    String categoryId, {
    DateTime? since,
    MeasurementBucketLevel level = MeasurementBucketLevel.auto,
    int maxPoints = measurementChartMaxPoints,
  }) {
    _logger.finer('Watching $level buckets of measurement category $categoryId');

    final variables = [
      Variable.withString(categoryId),
      // Encoded the way drift writes the column (UTC ISO-8601 text), so this
      // reads the same rows as the typed queries above
      if (since != null) Variable.withString(since.toUtc().toIso8601String()),
    ];
    final where = 'WHERE category_id = ?1${since == null ? '' : ' AND date >= ?2'}';

    // Only `auto` reads the probe, so a fixed level does not pay for it
    final fixed = switch (level) {
      MeasurementBucketLevel.day => MeasurementBucketUnit.day,
      MeasurementBucketLevel.week => MeasurementBucketUnit.week,
      MeasurementBucketLevel.auto => null,
    };
    if (fixed != null) {
      return _bucketQuery(
        fixed,
        where,
        variables,
      ).watch().debounce(_emitDebounce, leading: true).map(_toBuckets);
    }

    // Every unit's point count in one pass, so picking one costs no scan
    // per candidate
    final probe = _db.customSelect(
      'SELECT COUNT(*) AS entries, '
      'COUNT(DISTINCT ${_bucketExpression(MeasurementBucketUnit.hour)}) AS hours, '
      'COUNT(DISTINCT ${_bucketExpression(MeasurementBucketUnit.day)}) AS days, '
      'COUNT(DISTINCT ${_bucketExpression(MeasurementBucketUnit.week)}) AS weeks '
      'FROM ${_db.measurementEntryTable.actualTableName} $where',
      variables: variables,
      readsFrom: {_db.measurementEntryTable},
    );

    return probe
        .watchSingle()
        .debounce(_emitDebounce, leading: true)
        .asyncMap(
          (row) async => _toBuckets(
            await _bucketQuery(_ladderUnit(row, maxPoints), where, variables).get(),
          ),
        );
  }

  /// The aggregate of a category's entries at [unit], one row per bucket and
  /// per unit the values were entered in: a mean over kg and lb values would
  /// be a number in neither.
  Selectable<QueryRow> _bucketQuery(
    MeasurementBucketUnit unit,
    String where,
    List<Variable> variables,
  ) => _db.customSelect(
    'SELECT ${_bucketExpression(unit)} AS bucket, '
    r"json_extract(extra_data, '$.unit') AS unit, "
    'COUNT(*) AS n, '
    'SUM(value) AS total, '
    // A daily aggregate contributes the range it summarises, not its mean
    r"MIN(COALESCE(json_extract(extra_data, '$.min'), value)) AS low, "
    r"MAX(COALESCE(json_extract(extra_data, '$.max'), value)) AS high "
    'FROM ${_db.measurementEntryTable.actualTableName} $where '
    'GROUP BY bucket, unit ORDER BY bucket',
    variables: variables,
    readsFrom: {_db.measurementEntryTable},
  );

  List<MeasurementBucket> _toBuckets(List<QueryRow> rows) => [
    for (final row in rows)
      MeasurementBucket(
        start: _parseBucketStart(row.read<String>('bucket')),
        unit: row.read<String?>('unit'),
        count: row.read<int>('n'),
        sum: row.read<double>('total'),
        min: row.read<double>('low'),
        max: row.read<double>('high'),
      ),
  ];

  /// The finest unit that keeps the series under [maxPoints], mirroring the
  /// ladder `downsample` walks in Dart.
  MeasurementBucketUnit _ladderUnit(QueryRow probe, int maxPoints) {
    for (final (unit, points) in [
      (MeasurementBucketUnit.entry, probe.read<int>('entries')),
      (MeasurementBucketUnit.hour, probe.read<int>('hours')),
      (MeasurementBucketUnit.day, probe.read<int>('days')),
      (MeasurementBucketUnit.week, probe.read<int>('weeks')),
    ]) {
      if (points <= maxPoints) {
        return unit;
      }
    }
    return MeasurementBucketUnit.month;
  }

  /// The SQL producing a bucket key, which is also the bucket's start.
  ///
  /// Shifted to the local zone, since the column is UTC: a reading half an
  /// hour after midnight belongs to the day the user had it.
  String _bucketExpression(MeasurementBucketUnit unit) => switch (unit) {
    MeasurementBucketUnit.entry => 'date',
    MeasurementBucketUnit.hour => "strftime('%Y-%m-%dT%H:00:00', date, 'localtime')",
    MeasurementBucketUnit.day => "strftime('%Y-%m-%dT00:00:00', date, 'localtime')",
    // 'weekday 1' moves to the next Monday or stays on one, so -6 days
    // first lands on the Monday of the entry's own week
    MeasurementBucketUnit.week =>
      "strftime('%Y-%m-%dT00:00:00', date, 'localtime', '-6 days', 'weekday 1')",
    MeasurementBucketUnit.month => "strftime('%Y-%m-01T00:00:00', date, 'localtime')",
  };

  /// A bucket key as a local [DateTime]. The entry level hands back the stored
  /// column, which is UTC and marked as such; the other units are already
  /// local.
  DateTime _parseBucketStart(String value) {
    final parsed = DateTime.parse(value);
    return parsed.isUtc ? parsed.toLocal() : parsed;
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
