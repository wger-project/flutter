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

  /// Watches all categories with their children.
  ///
  /// The list is flat (children of multi-value groups appear as regular items
  /// with a non-null `parentId`), but group parents additionally get their
  /// [MeasurementCategory.children] attached, sorted by their in-group order.
  ///
  /// A category never carries its entries: those of a watch-fed metric are
  /// tens of thousands of rows a year, and building an object per row to then
  /// chart a few hundred points is the cost the aggregated queries below
  /// avoid.
  Stream<List<MeasurementCategory>> watchAllWithoutEntries() {
    _logger.finer('Watching all measurement categories');
    return _watchCategories();
  }

  /// One category with its children. See [watchAllWithoutEntries].
  Stream<MeasurementCategory?> watchCategoryWithoutEntries(String id) {
    _logger.finer('Watching measurement category $id');
    return _watchCategories(
      filter: (table) => table.id.equals(id) | table.parentId.equals(id),
    ).map((categories) => categories.firstWhereOrNull((c) => c.id == id));
  }

  /// Watches the categories matching [filter] (all of them when it is null),
  /// group parents with their children attached.
  Stream<List<MeasurementCategory>> _watchCategories({
    Expression<bool> Function($MeasurementCategoryTableTable table)? filter,
  }) {
    final select = _db.select(_db.measurementCategoryTable);
    if (filter != null) {
      select.where(filter);
    }
    select.orderBy([
      (t) => OrderingTerm(expression: t.order),
      (t) => OrderingTerm(expression: t.name),
    ]);

    return select.watch().debounce(_emitDebounce, leading: true).map(_attachChildren);
  }

  /// Attaches the children of every group parent. The rows arrive sorted by
  /// order and name, so insertion order is the display order.
  List<MeasurementCategory> _attachChildren(List<MeasurementCategory> categories) =>
      categories.map((c) {
        final children = categories.where((other) => other.parentId == c.id).toList();
        return children.isEmpty ? c : c.copyWith(children: children);
      }).toList();

  /// Watches the user's official body weight category.
  ///
  /// The category has no fixed id (the server assigns it), so it is selected
  /// by its type in the query rather than picked out of every category
  /// afterwards.
  Stream<MeasurementCategory?> watchOfficialBodyWeightCategory() {
    _logger.finer('Watching the official body weight category');
    return _watchCategories(
      filter: (table) =>
          table.isOfficial.equals(true) & table.metricType.equalsValue(MetricType.bodyWeight),
    ).map((categories) => categories.firstOrNull);
  }

  /// The newest entries of [categoryId], at most [limit] of them.
  ///
  /// For the lists, which show a page at a time rather than a history that
  /// runs into five figures. Ordered by date and, among the rows sharing one,
  /// by id: the sync writes entries on the same timestamp (a day aggregate at
  /// midnight, the components of a reading at its exact time), and a limit
  /// over an ambiguous order picks a different row on every read.
  Stream<List<MeasurementEntry>> watchEntries(String categoryId, {required int limit}) {
    _logger.finer('Watching $limit entries of measurement category $categoryId');

    final query = _db.select(_db.measurementEntryTable)
      ..where((t) => t.categoryId.equals(categoryId))
      ..orderBy([
        (t) => OrderingTerm.desc(t.date),
        (t) => OrderingTerm.desc(t.id),
      ])
      ..limit(limit);

    return query.watch().debounce(_emitDebounce, leading: true);
  }

  /// The newest entries of every component of the group [parentId], at most
  /// [limit] of them, in the order [watchEntries] describes.
  ///
  /// One query over the components rather than one each: the readings are
  /// paired afterwards, and a page has to cover the same span for all of them.
  Stream<List<MeasurementEntry>> watchGroupEntries(String parentId, {required int limit}) {
    _logger.finer('Watching $limit entries of measurement group $parentId');

    final query =
        _db.select(_db.measurementEntryTable).join([
            innerJoin(
              _db.measurementCategoryTable,
              _db.measurementCategoryTable.id.equalsExp(_db.measurementEntryTable.categoryId),
            ),
          ])
          ..where(_db.measurementCategoryTable.parentId.equals(parentId))
          ..orderBy([
            OrderingTerm.desc(_db.measurementEntryTable.date),
            OrderingTerm.desc(_db.measurementEntryTable.id),
          ])
          ..limit(limit);

    return query
        .watch()
        .debounce(_emitDebounce, leading: true)
        .map(
          (rows) => rows.map((row) => row.readTable(_db.measurementEntryTable)).toList(),
        );
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
  /// entry. [since] and [until] bound the entries read, null on both covers the
  /// full history; [until] is exclusive.
  Stream<List<MeasurementBucket>> watchEntryBuckets(
    String categoryId, {
    DateTime? since,
    DateTime? until,
    MeasurementBucketLevel level = MeasurementBucketLevel.auto,
    int maxPoints = measurementChartMaxPoints,
  }) {
    _logger.finer('Watching $level buckets of measurement category $categoryId');

    return _watchBucketRows(
      where: 'WHERE category_id = ?1${_bucketRange(since, until)}',
      variables: _bucketVariables(categoryId, since, until),
      level: level,
      maxPoints: maxPoints,
    ).map(_toBuckets);
  }

  /// Chart points for every child of [parentId], keyed by child, all at one
  /// calendar unit.
  ///
  /// One unit for the whole group rather than one per component: the halves of
  /// a reading are paired on their shared bucket, and a component condensed on
  /// its own would put them in different ones.
  Stream<Map<String, List<MeasurementBucket>>> watchGroupBuckets(
    String parentId, {
    DateTime? since,
    MeasurementBucketLevel level = MeasurementBucketLevel.auto,
    int maxPoints = measurementChartMaxPoints,
  }) {
    _logger.finer('Watching $level buckets of measurement group $parentId');

    return _watchBucketRows(
      where:
          'WHERE category_id IN ('
          'SELECT id FROM ${_db.measurementCategoryTable.actualTableName} WHERE parent_id = ?1)'
          '${_bucketRange(since, null)}',
      variables: _bucketVariables(parentId, since, null),
      level: level,
      maxPoints: maxPoints,
      perCategory: true,
    ).map(_toBucketsByCategory);
  }

  /// One point per day and category, over every category there is.
  ///
  /// For the calendar, which marks days rather than readings: a metric fed by
  /// a watch writes hundreds of entries onto the same square, and reading them
  /// to draw one marker is what this avoids.
  Stream<Map<String, List<MeasurementBucket>>> watchDailyBuckets() {
    _logger.finer('Watching the day buckets of every measurement category');

    return _watchBucketRows(
      where: '',
      variables: [],
      level: MeasurementBucketLevel.day,
      maxPoints: measurementChartMaxPoints,
      perCategory: true,
    ).map(_toBucketsByCategory);
  }

  /// The aggregated rows of whatever [where] selects, at the calendar unit
  /// [level] asks for: fixed for the charts built on one, otherwise the finest
  /// that keeps the series under [maxPoints].
  ///
  /// Only `auto` reads the probe, so a fixed level does not pay for it.
  Stream<List<QueryRow>> _watchBucketRows({
    required String where,
    required List<Variable> variables,
    required MeasurementBucketLevel level,
    required int maxPoints,
    bool perCategory = false,
  }) {
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
        perCategory: perCategory,
      ).watch().debounce(_emitDebounce, leading: true);
    }

    return _probeQuery(where, variables)
        .watchSingle()
        .debounce(_emitDebounce, leading: true)
        .asyncMap(
          (row) => _bucketQuery(
            _ladderUnit(row, maxPoints),
            where,
            variables,
            perCategory: perCategory,
          ).get(),
        );
  }

  /// The id the query is scoped to, and the date bounds it has.
  ///
  /// Encoded the way drift writes the column (UTC ISO-8601 text), so a bucket
  /// query reads the same rows as the typed ones.
  List<Variable> _bucketVariables(String id, DateTime? since, DateTime? until) => [
    Variable.withString(id),
    if (since != null) Variable.withString(since.toUtc().toIso8601String()),
    if (until != null) Variable.withString(until.toUtc().toIso8601String()),
  ];

  /// The date bounds as SQL, against the variables [_bucketVariables] binds
  /// after the id. The upper one is exclusive, so a caller passes the start of
  /// the day after the last one it wants.
  String _bucketRange(DateTime? since, DateTime? until) => [
    if (since != null) ' AND date >= ?2',
    if (until != null) ' AND date < ?${since == null ? 2 : 3}',
  ].join();

  /// How often each value occurred in [categoryId], for the histogram.
  ///
  /// Not bucketed by time but by value, which is the granularity a histogram
  /// bins at anyway: a year of heart rate is tens of thousands of readings
  /// over some two hundred distinct bpm. Counting instead of binning in SQL
  /// keeps the conversion of a mixed-unit category exact, since the values
  /// still go through the one helper. [summedPerDay] counts daily totals
  /// rather than single readings, for the metrics whose samples mean nothing
  /// on their own.
  Stream<List<MeasurementValueCount>> watchValueCounts(
    String categoryId, {
    DateTime? since,
    bool summedPerDay = false,
  }) {
    _logger.finer('Watching the value counts of measurement category $categoryId');

    final variables = [
      Variable.withString(categoryId),
      if (since != null) Variable.withString(since.toUtc().toIso8601String()),
    ];
    final where = 'WHERE category_id = ?1${since == null ? '' : ' AND date >= ?2'}';
    final day = _bucketExpression(MeasurementBucketUnit.day);
    final source = summedPerDay
        ? 'SELECT '
              r"json_extract(extra_data, '$.unit') AS unit, "
              'SUM(value) AS v, MAX(date) AS newest '
              'FROM ${_db.measurementEntryTable.actualTableName} $where '
              'GROUP BY $day, unit'
        : 'SELECT '
              r"json_extract(extra_data, '$.unit') AS unit, "
              'value AS v, date AS newest '
              'FROM ${_db.measurementEntryTable.actualTableName} $where';

    return _db
        .customSelect(
          'SELECT unit, v, COUNT(*) AS n, MAX(newest) AS newest FROM ($source) '
          'GROUP BY unit, v ORDER BY v',
          variables: variables,
          readsFrom: {_db.measurementEntryTable},
        )
        .watch()
        .debounce(_emitDebounce, leading: true)
        .map(
          (rows) => [
            for (final row in rows)
              MeasurementValueCount(
                value: row.read<double>('v'),
                unit: row.read<String?>('unit'),
                count: row.read<int>('n'),
                newest: _parseDbDate(row.read<String>('newest')),
              ),
          ],
        );
  }

  /// The aggregate of a category's entries at [unit], one row per bucket and
  /// per unit the values were entered in: a mean over kg and lb values would
  /// be a number in neither.
  Selectable<QueryRow> _bucketQuery(
    MeasurementBucketUnit unit,
    String where,
    List<Variable> variables, {
    bool perCategory = false,
  }) {
    final by = perCategory ? 'category_id, ' : '';
    return _db.customSelect(
      'SELECT $by${_bucketExpression(unit)} AS bucket, '
      r"json_extract(extra_data, '$.unit') AS unit, "
      'COUNT(*) AS n, '
      'SUM(value) AS total, '
      // A daily aggregate contributes the range it summarises, not its mean
      r"MIN(COALESCE(json_extract(extra_data, '$.min'), value)) AS low, "
      r"MAX(COALESCE(json_extract(extra_data, '$.max'), value)) AS high "
      'FROM ${_db.measurementEntryTable.actualTableName} $where '
      'GROUP BY ${by}bucket, unit ORDER BY bucket',
      variables: variables,
      readsFrom: {_db.measurementEntryTable},
    );
  }

  /// Every unit's point count in one pass, so picking one costs no scan per
  /// candidate.
  Selectable<QueryRow> _probeQuery(String where, List<Variable> variables) => _db.customSelect(
    'SELECT COUNT(*) AS entries, '
    'COUNT(DISTINCT ${_bucketExpression(MeasurementBucketUnit.hour)}) AS hours, '
    'COUNT(DISTINCT ${_bucketExpression(MeasurementBucketUnit.day)}) AS days, '
    'COUNT(DISTINCT ${_bucketExpression(MeasurementBucketUnit.week)}) AS weeks '
    'FROM ${_db.measurementEntryTable.actualTableName} $where',
    variables: variables,
    readsFrom: {_db.measurementEntryTable},
  );

  MeasurementBucket _toBucket(QueryRow row) => MeasurementBucket(
    start: _parseDbDate(row.read<String>('bucket')),
    unit: row.read<String?>('unit'),
    count: row.read<int>('n'),
    sum: row.read<double>('total'),
    min: row.read<double>('low'),
    max: row.read<double>('high'),
  );

  List<MeasurementBucket> _toBuckets(List<QueryRow> rows) => rows.map(_toBucket).toList();

  Map<String, List<MeasurementBucket>> _toBucketsByCategory(List<QueryRow> rows) {
    final out = <String, List<MeasurementBucket>>{};
    for (final row in rows) {
      out.putIfAbsent(row.read<String>('category_id'), () => []).add(_toBucket(row));
    }
    return out;
  }

  /// The finest unit that keeps the series under [maxPoints].
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

  /// A date column or bucket key as a local [DateTime]. A stored date is UTC
  /// and marked as such; a bucket key was already shifted to the local zone by
  /// the query.
  DateTime _parseDbDate(String value) {
    final parsed = DateTime.parse(value);
    return parsed.isUtc ? parsed.toLocal() : parsed;
  }

  /// One-shot snapshot of all categories with their children, without their
  /// entries. See [watchAllWithoutEntries].
  Future<List<MeasurementCategory>> getCategoriesOnce() => watchAllWithoutEntries().first;

  /// The external ids of [categoryId]'s entries.
  ///
  /// Only the ids: an import deduplicates by comparing keys and has no use for
  /// the entries themselves, of which a watch-fed metric writes hundreds a day.
  Future<Set<String>> getExternalIds(String categoryId) async {
    _logger.finer('Reading the external ids of measurement category $categoryId');

    final table = _db.measurementEntryTable;
    final query = _db.selectOnly(table)
      ..addColumns([table.externalId])
      ..where(table.categoryId.equals(categoryId) & table.externalId.isNotNull());

    final rows = await query.get();
    return {for (final row in rows) row.read(table.externalId)!};
  }

  /// The entries of [categoryId] that carry an external id, keyed by it.
  ///
  /// For the day aggregates, which are rewritten when late samples change
  /// them, so their importer needs the stored row rather than just its key.
  Future<Map<String, MeasurementEntry>> getEntriesByExternalId(String categoryId) async {
    _logger.finer('Reading the keyed entries of measurement category $categoryId');

    final query = _db.select(_db.measurementEntryTable)
      ..where((t) => t.categoryId.equals(categoryId) & t.externalId.isNotNull());

    final entries = await query.get();
    return {for (final entry in entries) entry.externalId!: entry};
  }

  /// Whether [categoryId] holds any entry of its own.
  Future<bool> hasEntries(String categoryId) async {
    _logger.finer('Checking whether measurement category $categoryId holds entries');

    final query = _db.select(_db.measurementEntryTable)
      ..where((t) => t.categoryId.equals(categoryId))
      ..limit(1);

    return await query.getSingleOrNull() != null;
  }

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

  /// Inserts a group together with its components, in a single transaction so
  /// a group is never left without the children its readings live in.
  Future<void> addLocalDriftCategoryGroup(List<MeasurementCategory> categories) async {
    _logger.finer('Adding a local measurement group of ${categories.length} categories');
    await _db.transaction(() async {
      for (final category in categories) {
        await _db.into(_db.measurementCategoryTable).insert(category.toCompanion());
      }
    });
  }

  /// Persists the given display order: each category gets its list index as
  /// [MeasurementCategory.order]. Categories whose order is unchanged are not
  /// written, so no sync upload is queued for them.
  Future<void> reorderCategories(List<String> orderedIds) async {
    _logger.finer('Reordering ${orderedIds.length} categories');
    await _db.transaction(() async {
      for (var i = 0; i < orderedIds.length; i++) {
        final stmt = _db.update(_db.measurementCategoryTable)
          // IS NOT so legacy rows with a NULL order still get written
          ..where((t) => t.id.equals(orderedIds[i]) & t.order.isNotValue(i));
        await stmt.write(MeasurementCategoryTableCompanion(order: Value(i)));
      }
    });
  }
}
