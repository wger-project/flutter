/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 wger Team
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

import 'package:collection/collection.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/features/measurements/models/measurement_bucket.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';

import 'measurement_chart_buckets.dart';

/// Answers the reads a measurement screen does: the category streams, the
/// paged lists and the aggregated queries, all served from [entries] keyed by
/// the category holding them.
///
/// [repo] is a generated `MockMeasurementRepository`, typed dynamically
/// because only the mock's own signatures accept mockito's matchers.
void stubMeasurementReads(
  dynamic repo,
  List<MeasurementCategory> categories, [
  Map<String, List<MeasurementEntry>> entries = const {},
]) {
  // A fixture either carries its children already or is a flat list to be
  // grouped, and both shapes are in use
  final withChildren = [
    for (final category in categories)
      if (category.children.isNotEmpty)
        category
      else
        category.copyWith(children: categories.where((c) => c.parentId == category.id).toList()),
  ];
  when(repo.watchAllWithoutEntries()).thenAnswer((_) => Stream.value(withChildren));

  when(repo.watchOfficialBodyWeightCategory()).thenAnswer(
    (_) => Stream.value(withChildren.firstWhereOrNull((c) => c.isOfficialBodyWeight)),
  );

  when(repo.watchCategoryWithoutEntries(any)).thenAnswer((invocation) {
    final id = invocation.positionalArguments.first as String;
    return Stream.value(withChildren.firstWhereOrNull((c) => c.id == id));
  });

  when(repo.watchEntries(any, limit: anyNamed('limit'))).thenAnswer((invocation) {
    final id = invocation.positionalArguments.first as String;
    return Stream.value(
      _newestFirst(entries[id] ?? const [], invocation.namedArguments[#limit] as int),
    );
  });

  when(repo.watchGroupEntries(any, limit: anyNamed('limit'))).thenAnswer((invocation) {
    final id = invocation.positionalArguments.first as String;
    final group = withChildren.firstWhereOrNull((c) => c.id == id);
    final ofGroup = [
      for (final child in group?.children ?? const <MeasurementCategory>[]) ...?entries[child.id],
    ];
    return Stream.value(_newestFirst(ofGroup, invocation.namedArguments[#limit] as int));
  });

  when(repo.watchLatestEntries()).thenAnswer(
    (_) => Stream.value({
      for (final MapEntry(key: id, value: ofCategory) in entries.entries)
        if (ofCategory.isNotEmpty) id: ofCategory.reduce((a, b) => b.date.isAfter(a.date) ? b : a),
    }),
  );

  // The aggregated queries, answered at the level the caller asked for. One
  // bucket per entry for `auto`: every fixture is short enough not to be
  // condensed, and condensing is covered where it happens, in the repository
  List<MeasurementBucket> bucketsOf(String id, DateTime? since, DateTime? until, Object? level) {
    final ofCategory = (entries[id] ?? const [])
        .where((e) => since == null || !e.date.isBefore(since))
        .where((e) => until == null || e.date.isBefore(until));

    return level == MeasurementBucketLevel.auto ? entryBuckets(ofCategory) : dayBuckets(ofCategory);
  }

  when(
    repo.watchEntryBuckets(
      any,
      since: anyNamed('since'),
      until: anyNamed('until'),
      level: anyNamed('level'),
    ),
  ).thenAnswer((invocation) {
    final named = invocation.namedArguments;
    return Stream.value(
      bucketsOf(
        invocation.positionalArguments.first as String,
        named[#since] as DateTime?,
        named[#until] as DateTime?,
        named[#level],
      ),
    );
  });

  when(repo.watchGroupBuckets(any, since: anyNamed('since'), level: anyNamed('level'))).thenAnswer((
    invocation,
  ) {
    final group = withChildren.firstWhereOrNull(
      (c) => c.id == invocation.positionalArguments.first,
    );
    final named = invocation.namedArguments;
    return Stream.value({
      for (final child in group?.children ?? const <MeasurementCategory>[])
        child.id!: bucketsOf(child.id!, named[#since] as DateTime?, null, named[#level]),
    });
  });

  // Counted over the whole fixture: the cutoff and the daily summing are the
  // repository's own, and covered where they happen
  when(
    repo.watchValueCounts(any, since: anyNamed('since'), summedPerDay: anyNamed('summedPerDay')),
  ).thenAnswer((invocation) {
    final ofCategory = entries[invocation.positionalArguments.first as String] ?? const [];
    final byValue = <num, List<MeasurementEntry>>{};
    for (final entry in ofCategory) {
      byValue.putIfAbsent(entry.value, () => []).add(entry);
    }

    return Stream.value([
      for (final MapEntry(:key, :value) in byValue.entries)
        MeasurementValueCount(
          value: key,
          unit: null,
          count: value.length,
          newest: value.map((e) => e.date).reduce((a, b) => b.isAfter(a) ? b : a),
        ),
    ]);
  });

  when(repo.watchDailyBuckets()).thenAnswer(
    (_) => Stream.value({
      for (final id in entries.keys) id: dayBuckets(entries[id]!),
    }),
  );
}

List<MeasurementEntry> _newestFirst(Iterable<MeasurementEntry> entries, int limit) =>
    (entries.toList()..sort((a, b) => b.date.compareTo(a.date))).take(limit).toList();
