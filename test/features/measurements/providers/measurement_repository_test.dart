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

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wger/database/powersync/database.dart';
import 'package:wger/features/measurements/models/measurement_bucket.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';
import 'package:wger/features/measurements/providers/measurement_repository.dart';

import '../../../../test_data/body_weight.dart';
import '../../../../test_data/measurements.dart';
import '../../../helpers/in_memory_drift.dart';

void main() {
  late DriftPowersyncDatabase db;
  late MeasurementRepository repo;

  setUp(() async {
    db = await openTestDatabase();
    repo = MeasurementRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedCategoriesAndEntries() async {
    for (final category in getMeasurementCategories()) {
      await db.into(db.measurementCategoryTable).insert(category.toCompanion());
      for (final entry in getMeasurementEntries()[category.id] ?? const []) {
        await db.into(db.measurementEntryTable).insert(entry.toCompanion());
      }
    }
  }

  group('watchLatestEntries', () {
    test('returns the newest entry of every category', () async {
      await seedCategoriesAndEntries();

      final latest = await repo.watchLatestEntries().first;

      final entries = getMeasurementEntries();
      expect(latest.keys.toSet(), entries.keys.toSet());
      for (final MapEntry(key: id, value: ofCategory) in entries.entries) {
        final newest = ofCategory.reduce((a, b) => b.date.isAfter(a.date) ? b : a);
        expect(latest[id]!.id, newest.id);
      }
    });

    test('reaches past the range a chart would read', () async {
      // The point of the query: a value older than any range the card charts
      // is still the last known one
      final category = getMeasurementCategories()[0];
      await db.into(db.measurementCategoryTable).insert(category.toCompanion());
      final old = MeasurementEntry(
        id: 'ancient',
        categoryId: category.id!,
        date: DateTime.now().subtract(const Duration(days: 900)),
        value: 42,
        notes: '',
      );
      await db.into(db.measurementEntryTable).insert(old.toCompanion());

      final latest = await repo.watchLatestEntries().first;

      expect(latest[category.id]!.id, 'ancient');
    });

    test('tells sub-second timestamps apart', () async {
      // What the sync writes: the sleep segments land microseconds apart. A
      // formulation that compares whole seconds picks the wrong row, or none
      final category = getMeasurementCategories()[0];
      await db.into(db.measurementCategoryTable).insert(category.toCompanion());
      final second = DateTime(2026, 8, 5, 3, 39, 3);
      for (final (index, micros) in [280477, 775505].indexed) {
        await db
            .into(db.measurementEntryTable)
            .insert(
              MeasurementEntry(
                id: 'e$index',
                categoryId: category.id!,
                date: second.add(Duration(microseconds: micros)),
                value: 42,
                notes: '',
              ).toCompanion(),
            );
      }

      final latest = await repo.watchLatestEntries().first;

      expect(latest[category.id]!.id, 'e1');
    });

    test('a category without entries is absent', () async {
      await db
          .into(db.measurementCategoryTable)
          .insert(getMeasurementCategories()[0].toCompanion());

      expect(await repo.watchLatestEntries().first, isEmpty);
    });
  });

  group('watchAllWithoutEntries', () {
    test('reads the categories only, so an entry does not re-emit them', () async {
      // The screens draw from the aggregated queries; rebuilding every
      // category because a sleep row arrived is the cost that buys nothing
      await seedCategoriesAndEntries();
      final emissions = <List<MeasurementCategory>>[];
      final sub = repo.watchAllWithoutEntries().listen(emissions.add);

      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(emissions, hasLength(1));

      await repo.addLocalDrift(
        MeasurementEntry(categoryId: '1', date: DateTime.utc(2027, 1, 1), value: 99, notes: ''),
      );
      await Future<void>.delayed(const Duration(milliseconds: 400));

      expect(emissions, hasLength(1));
      await sub.cancel();
    });

    test('coalesces a burst of writes into one emission', () async {
      final emissions = <List<MeasurementCategory>>[];
      final sub = repo.watchAllWithoutEntries().listen(emissions.add);

      // The leading emission is not held back: a screen waits for it
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(emissions, hasLength(1));

      for (var i = 0; i < 5; i++) {
        await repo.addLocalDriftCategory(
          MeasurementCategory(id: 'c$i', name: 'Category $i', unit: 'cm'),
        );
      }
      await Future<void>.delayed(const Duration(milliseconds: 400));

      expect(emissions.length, lessThanOrEqualTo(2));
      expect(emissions.last, hasLength(5));

      await sub.cancel();
    });

    test('returns the categories and their children', () async {
      await seedCategoriesAndEntries();
      for (final category in getBloodPressureGroup()) {
        await repo.addLocalDriftCategory(category);
      }

      final emitted = await repo.watchAllWithoutEntries().first;

      expect(emitted.firstWhere((c) => c.id == 'bp').children.map((c) => c.id), ['sys', 'dia']);
    });

    test('sorts by order before name', () async {
      await repo.addLocalDriftCategory(
        MeasurementCategory(id: 'c1', name: 'Aaa', unit: 'cm', order: 5),
      );
      await repo.addLocalDriftCategory(
        MeasurementCategory(id: 'c2', name: 'Zzz', unit: 'cm', order: 1),
      );

      expect((await repo.watchAllWithoutEntries().first).map((c) => c.id), ['c2', 'c1']);
    });

    test('watchCategoryWithoutEntries keeps a group its children', () async {
      for (final category in getBloodPressureGroup()) {
        await repo.addLocalDriftCategory(category);
      }

      final emitted = await repo.watchCategoryWithoutEntries('bp').first;

      expect(emitted!.children.map((c) => c.id), ['sys', 'dia']);
    });

    test('watchCategoryWithoutEntries can watch a component on its own', () async {
      for (final category in getBloodPressureGroup()) {
        await repo.addLocalDriftCategory(category);
      }

      final emitted = await repo.watchCategoryWithoutEntries('sys').first;

      expect(emitted!.name, 'Systolic');
      expect(emitted.children, isEmpty);
    });

    test('watchCategoryWithoutEntries is null when no category matches', () async {
      await seedCategoriesAndEntries();

      expect(await repo.watchCategoryWithoutEntries('does-not-exist').first, isNull);
    });

    test('getCategoriesOnce returns one snapshot without entries', () async {
      await seedCategoriesAndEntries();

      final categories = await repo.getCategoriesOnce();

      expect(
        categories.map((c) => c.id),
        (await repo.watchAllWithoutEntries().first).map((c) => c.id),
      );
    });
  });

  group('the import dedup queries', () {
    /// An entry of ['1'], keyed by [externalId] unless it is null.
    Future<void> seedEntry(String id, {String? externalId, double value = 1}) => repo.addLocalDrift(
      MeasurementEntry(
        id: id,
        categoryId: '1',
        date: DateTime.utc(2026, 1, 1),
        value: value,
        notes: '',
        externalId: externalId,
      ),
    );

    test('getExternalIds returns the keys of one category, skipping the unkeyed', () async {
      await seedEntry('e1', externalId: 'key-1');
      await seedEntry('e2', externalId: 'key-2');
      // A hand-entered measurement has no external id
      await seedEntry('e3');
      await repo.addLocalDrift(
        MeasurementEntry(
          id: 'other',
          categoryId: '2',
          date: DateTime.utc(2026, 1, 1),
          value: 1,
          notes: '',
          externalId: 'key-3',
        ),
      );

      expect(await repo.getExternalIds('1'), {'key-1', 'key-2'});
    });

    test('getExternalIds returns nothing for a category without entries', () async {
      expect(await repo.getExternalIds('1'), isEmpty);
    });

    test('getEntriesByExternalId keys the entries the importer may update', () async {
      await seedEntry('e1', externalId: 'key-1', value: 60);
      await seedEntry('e2');

      final stored = await repo.getEntriesByExternalId('1');

      expect(stored.keys, ['key-1']);
      // The row itself, not just its key: the update writes it back
      expect(stored['key-1']!.id, 'e1');
      expect(stored['key-1']!.value, 60);
    });

    test('hasEntries answers for the category asked about', () async {
      await repo.addLocalDrift(
        MeasurementEntry(
          id: 'other',
          categoryId: '2',
          date: DateTime.utc(2026, 1, 1),
          value: 1,
          notes: '',
        ),
      );

      expect(await repo.hasEntries('1'), isFalse);
      expect(await repo.hasEntries('2'), isTrue);
    });
  });

  group('watchEntries', () {
    test('returns the newest entries first, at most the limit', () async {
      await seedCategoriesAndEntries();

      final page = await repo.watchEntries('1', limit: 3).first;

      final dates = page.map((e) => e.date).toList();
      expect(page, hasLength(3));
      expect(dates, [...dates]..sort((a, b) => b.compareTo(a)));
      expect(
        dates.first,
        getMeasurementEntries()['1']!.map((e) => e.date).reduce((a, b) => a.isAfter(b) ? a : b),
      );
    });

    test('a growing limit extends the same page', () async {
      await seedCategoriesAndEntries();

      final short = await repo.watchEntries('1', limit: 2).first;
      final long = await repo.watchEntries('1', limit: 4).first;

      expect(long.take(2).map((e) => e.id), short.map((e) => e.id));
    });

    test('entries sharing a timestamp keep a stable order', () async {
      // The sync writes them: a day aggregate at midnight, the components of a
      // reading at its exact time. A limit over an ambiguous order would pick
      // a different row on every read.
      await db
          .into(db.measurementCategoryTable)
          .insert(MeasurementCategory(id: '1', name: 'Sleep', unit: 'min').toCompanion());
      final shared = DateTime(2026, 5, 4);
      for (final id in ['a', 'b', 'c']) {
        await repo.addLocalDrift(
          MeasurementEntry(id: id, categoryId: '1', date: shared, value: 60, notes: ''),
        );
      }

      final first = await repo.watchEntries('1', limit: 2).first;
      final second = await repo.watchEntries('1', limit: 2).first;

      expect(first.map((e) => e.id), second.map((e) => e.id));
      expect(first.map((e) => e.id), ['c', 'b']);
    });

    test('only the requested category is read', () async {
      await seedCategoriesAndEntries();

      final page = await repo.watchEntries('2', limit: 10).first;

      expect(page.every((e) => e.categoryId == '2'), isTrue);
    });
  });

  group('watchGroupEntries', () {
    test('returns the entries of every component, newest first', () async {
      for (final category in getBloodPressureGroup()) {
        await repo.addLocalDriftCategory(category);
      }
      for (final (index, date) in [DateTime(2026, 5, 4, 8), DateTime(2026, 5, 5, 8)].indexed) {
        await repo.addLocalDriftGroupEntries([
          MeasurementEntry(id: 's$index', categoryId: 'sys', date: date, value: 120, notes: ''),
          MeasurementEntry(id: 'd$index', categoryId: 'dia', date: date, value: 80, notes: ''),
        ]);
      }

      final page = await repo.watchGroupEntries('bp', limit: 2).first;

      expect(page.map((e) => e.categoryId).toSet(), {'sys', 'dia'});
      expect(page.every((e) => e.date == DateTime(2026, 5, 5, 8)), isTrue);
    });

    test('a component id yields no group entries', () async {
      for (final category in getBloodPressureGroup()) {
        await repo.addLocalDriftCategory(category);
      }

      expect(await repo.watchGroupEntries('sys', limit: 10).first, isEmpty);
    });
  });

  group('watchEntryBuckets', () {
    /// Local dates throughout: the query buckets in the local zone, so UTC
    /// fixtures would put a reading in a different day on every machine.
    Future<void> seedEntries(
      List<(DateTime, num)> readings, {
      Map<String, dynamic>? extraData,
    }) async {
      await db
          .into(db.measurementCategoryTable)
          .insert(MeasurementCategory(id: '1', name: 'Heart rate', unit: 'bpm').toCompanion());
      for (final (index, (date, value)) in readings.indexed) {
        await db
            .into(db.measurementEntryTable)
            .insert(
              MeasurementEntry(
                id: 'e$index',
                categoryId: '1',
                date: date,
                value: value,
                notes: '',
                extraData: extraData,
              ).toCompanion(),
            );
      }
    }

    test('a series that fits keeps one bucket per entry', () async {
      await seedEntries([
        (DateTime(2026, 5, 4, 8, 30), 60),
        (DateTime(2026, 5, 4, 20, 15), 70),
      ]);

      final buckets = await repo.watchEntryBuckets('1').first;

      expect(buckets.map((b) => b.start), [
        DateTime(2026, 5, 4, 8, 30),
        DateTime(2026, 5, 4, 20, 15),
      ]);
      expect(buckets.map((b) => b.count), [1, 1]);
      expect(buckets.map((b) => b.sum), [60, 70]);
    });

    test('condenses to the finest calendar unit that fits', () async {
      // Two readings a day over four days: entry level would be eight points,
      // the hour level still eight, so the day is the first one under the limit
      await seedEntries([
        for (var day = 4; day <= 7; day++) ...[
          (DateTime(2026, 5, day, 8, 0), 60),
          (DateTime(2026, 5, day, 20, 0), 80),
        ],
      ]);

      final buckets = await repo.watchEntryBuckets('1', maxPoints: 5).first;

      expect(buckets, hasLength(4));
      expect(buckets.first.start, DateTime(2026, 5, 4));
      expect(buckets.first.count, 2);
      expect(buckets.first.sum, 140);
      expect(buckets.first.min, 60);
      expect(buckets.first.max, 80);
    });

    test('a week bucket starts on the Monday of the reading', () async {
      // 2026-05-04 is a Monday, 2026-05-10 the Sunday closing that week
      await seedEntries([
        (DateTime(2026, 5, 4, 12), 60),
        (DateTime(2026, 5, 10, 12), 80),
      ]);

      final buckets = await repo.watchEntryBuckets('1', level: MeasurementBucketLevel.week).first;

      expect(buckets.single.start, DateTime(2026, 5, 4));
      expect(buckets.single.count, 2);
    });

    test('a day bucket is a calendar day whatever the point count', () async {
      await seedEntries([
        (DateTime(2026, 5, 4, 23, 30), 60),
        (DateTime(2026, 5, 5, 0, 30), 80),
      ]);

      final buckets = await repo.watchEntryBuckets('1', level: MeasurementBucketLevel.day).first;

      expect(buckets.map((b) => b.start), [DateTime(2026, 5, 4), DateTime(2026, 5, 5)]);
    });

    test('an aggregate entry contributes its stored bounds, not its value', () async {
      // What the health sync writes for heart rate: one row a day, holding the
      // day's average with the range it summarises
      await seedEntries(
        [(DateTime(2026, 5, 4, 12), 70)],
        extraData: {'min': 48, 'max': 165},
      );

      final buckets = await repo.watchEntryBuckets('1', level: MeasurementBucketLevel.day).first;

      expect(buckets.single.min, 48);
      expect(buckets.single.max, 165);
      expect(buckets.single.sum, 70);
    });

    test('mixed units are kept apart', () async {
      // A category holding kg and lb entries: one mean over both would be a
      // number in neither, so the slices come back separately
      await db
          .into(db.measurementCategoryTable)
          .insert(MeasurementCategory(id: '1', name: 'Weight', unit: 'kg').toCompanion());
      for (final (index, (value, unit)) in [(80, 'kg'), (180, 'lb')].indexed) {
        await db
            .into(db.measurementEntryTable)
            .insert(
              MeasurementEntry(
                id: 'e$index',
                categoryId: '1',
                date: DateTime(2026, 5, 4, 8 + index),
                value: value,
                notes: '',
                extraData: {'unit': unit},
              ).toCompanion(),
            );
      }

      final buckets = await repo.watchEntryBuckets('1', level: MeasurementBucketLevel.day).first;

      expect(buckets, hasLength(2));
      expect(buckets.map((b) => b.start).toSet(), {DateTime(2026, 5, 4)});
      expect(buckets.map((b) => b.unit), ['kg', 'lb']);
      expect(buckets.map((b) => b.sum), [80, 180]);
    });

    test('since bounds the entries read', () async {
      await seedEntries([
        (DateTime(2026, 1, 1, 12), 60),
        (DateTime(2026, 5, 4, 12), 80),
      ]);

      final buckets = await repo.watchEntryBuckets('1', since: DateTime(2026, 3, 1)).first;

      expect(buckets.map((b) => b.sum), [80]);
    });

    test('until bounds the entries read, excluding its own day', () async {
      // What a chart of a finished plan period reads: everything after the
      // last day belongs to no plan
      await seedEntries([
        (DateTime(2026, 1, 1, 12), 60),
        (DateTime(2026, 5, 4, 12), 80),
      ]);

      final buckets = await repo.watchEntryBuckets('1', until: DateTime(2026, 5, 4)).first;

      expect(buckets.map((b) => b.sum), [60]);
    });

    test('since and until bound the entries together', () async {
      await seedEntries([
        (DateTime(2026, 1, 1, 12), 60),
        (DateTime(2026, 3, 4, 12), 70),
        (DateTime(2026, 5, 4, 12), 80),
      ]);

      final buckets = await repo
          .watchEntryBuckets('1', since: DateTime(2026, 2, 1), until: DateTime(2026, 4, 1))
          .first;

      expect(buckets.map((b) => b.sum), [70]);
    });

    test('only the requested category is read', () async {
      await seedEntries([(DateTime(2026, 5, 4, 12), 60)]);
      await db
          .into(db.measurementCategoryTable)
          .insert(MeasurementCategory(id: '2', name: 'Other', unit: 'cm').toCompanion());
      await repo.addLocalDrift(
        MeasurementEntry(categoryId: '2', date: DateTime(2026, 5, 4, 13), value: 99, notes: ''),
      );

      final buckets = await repo.watchEntryBuckets('1').first;

      expect(buckets.map((b) => b.sum), [60]);
    });

    test('re-emits when an entry is added', () async {
      await seedEntries([(DateTime(2026, 5, 4, 12), 60)]);
      final iter = StreamIterator(repo.watchEntryBuckets('1'));

      await iter.moveNext();
      expect(iter.current, hasLength(1));

      await repo.addLocalDrift(
        MeasurementEntry(categoryId: '1', date: DateTime(2026, 5, 5, 12), value: 80, notes: ''),
      );

      await iter.moveNext();
      expect(iter.current, hasLength(2));
      await iter.cancel();
    });
  });

  group('watchDailyBuckets', () {
    test('returns one bucket per day and category, over all of them', () async {
      await seedCategoriesAndEntries();
      // Two readings on one day, which the calendar shows as one event
      await repo.addLocalDrift(
        MeasurementEntry(
          id: 'x1',
          categoryId: '1',
          date: DateTime(2026, 5, 4, 8),
          value: 20,
          notes: '',
        ),
      );
      await repo.addLocalDrift(
        MeasurementEntry(
          id: 'x2',
          categoryId: '1',
          date: DateTime(2026, 5, 4, 20),
          value: 22,
          notes: '',
        ),
      );

      final buckets = await repo.watchDailyBuckets().first;

      expect(buckets.keys.toSet(), {'1', '2'});
      final day = buckets['1']!.firstWhere((b) => b.start == DateTime(2026, 5, 4));
      expect(day.count, 2);
      expect(day.sum, 42);
      expect(buckets['2'], isNotEmpty);
    });

    test('a category without entries is absent', () async {
      await repo.addLocalDriftCategory(MeasurementCategory(id: 'c1', name: 'Waist', unit: 'cm'));

      expect(await repo.watchDailyBuckets().first, isEmpty);
    });
  });

  group('watchGroupBuckets', () {
    Future<void> seedBloodPressure(List<(DateTime, num, num)> readings) async {
      for (final category in getBloodPressureGroup()) {
        await repo.addLocalDriftCategory(category);
      }
      for (final (index, (date, systolic, diastolic)) in readings.indexed) {
        await repo.addLocalDriftGroupEntries([
          MeasurementEntry(
            id: 's$index',
            categoryId: 'sys',
            date: date,
            value: systolic,
            notes: '',
          ),
          MeasurementEntry(
            id: 'd$index',
            categoryId: 'dia',
            date: date,
            value: diastolic,
            notes: '',
          ),
        ]);
      }
    }

    test('returns the buckets of every component, keyed by component', () async {
      await seedBloodPressure([(DateTime(2026, 5, 4, 8), 120, 80)]);

      final buckets = await repo.watchGroupBuckets('bp').first;

      expect(buckets.keys.toSet(), {'sys', 'dia'});
      expect(buckets['sys']!.single.sum, 120);
      expect(buckets['dia']!.single.sum, 80);
    });

    test('all components share one calendar unit', () async {
      // Condensing per component would put the halves of a reading in
      // different buckets, and the chart could not pair them any more
      await seedBloodPressure([
        for (var day = 1; day <= 10; day++)
          for (var hour = 6; hour < 12; hour++) (DateTime(2026, 5, day, hour), 120, 80),
      ]);

      final buckets = await repo.watchGroupBuckets('bp', maxPoints: 20).first;

      expect(buckets['sys']!.map((b) => b.start), buckets['dia']!.map((b) => b.start));
      expect(buckets['sys']!.first.start, DateTime(2026, 5, 1));
    });

    test('a category that is not a group has no components', () async {
      await seedBloodPressure([(DateTime(2026, 5, 4, 8), 120, 80)]);

      expect(await repo.watchGroupBuckets('sys').first, isEmpty);
    });
  });

  group('watchValueCounts', () {
    Future<void> seedValues(List<(DateTime, num)> readings) async {
      await db
          .into(db.measurementCategoryTable)
          .insert(MeasurementCategory(id: '1', name: 'Heart rate', unit: 'bpm').toCompanion());
      for (final (index, (date, value)) in readings.indexed) {
        await db
            .into(db.measurementEntryTable)
            .insert(
              MeasurementEntry(
                id: 'e$index',
                categoryId: '1',
                date: date,
                value: value,
                notes: '',
              ).toCompanion(),
            );
      }
    }

    test('counts how often each value occurred', () async {
      // What makes the histogram cheap: a year of readings comes back as the
      // distinct values it covers
      await seedValues([
        (DateTime(2026, 5, 4, 8), 60),
        (DateTime(2026, 5, 4, 9), 60),
        (DateTime(2026, 5, 5, 8), 75),
      ]);

      final counts = await repo.watchValueCounts('1').first;

      expect(counts.map((c) => (c.value, c.count)), [(60, 2), (75, 1)]);
    });

    test('carries the newest date a value was measured on', () async {
      await seedValues([
        (DateTime(2026, 5, 4, 8), 60),
        (DateTime(2026, 5, 6, 8), 60),
      ]);

      final counts = await repo.watchValueCounts('1').first;

      expect(counts.single.newest, DateTime(2026, 5, 6, 8));
    });

    test('counts daily totals for a summed metric', () async {
      await seedValues([
        (DateTime(2026, 5, 4, 8), 3000),
        (DateTime(2026, 5, 4, 20), 2000),
        (DateTime(2026, 5, 5, 8), 5000),
      ]);

      final counts = await repo.watchValueCounts('1', summedPerDay: true).first;

      // Both days total 5000, so the histogram sees one value twice
      expect(counts.single.value, 5000);
      expect(counts.single.count, 2);
    });

    test('mixed units are kept apart', () async {
      await db
          .into(db.measurementCategoryTable)
          .insert(MeasurementCategory(id: '1', name: 'Weight', unit: 'kg').toCompanion());
      for (final (index, (value, unit)) in [(80, 'kg'), (80, 'lb')].indexed) {
        await db
            .into(db.measurementEntryTable)
            .insert(
              MeasurementEntry(
                id: 'e$index',
                categoryId: '1',
                date: DateTime(2026, 5, 4, 8 + index),
                value: value,
                notes: '',
                extraData: {'unit': unit},
              ).toCompanion(),
            );
      }

      final counts = await repo.watchValueCounts('1').first;

      expect(counts.map((c) => c.unit), ['kg', 'lb']);
      expect(counts.every((c) => c.count == 1), isTrue);
    });
  });

  group('watchOfficialBodyWeightCategory', () {
    Future<void> seedBodyWeight() async {
      await repo.addLocalDriftCategory(getBodyWeightCategory());
      for (final entry in [testWeightEntry1, testWeightEntry2]) {
        await repo.addLocalDrift(entry);
      }
    }

    test('returns the official category out of all of them', () async {
      await seedCategoriesAndEntries();
      await seedBodyWeight();

      final emitted = await repo.watchOfficialBodyWeightCategory().first;

      expect(emitted!.id, testBodyWeightCategoryId);
    });

    test('a category of the same type that is not official is ignored', () async {
      await repo.addLocalDriftCategory(
        MeasurementCategory(
          id: 'custom',
          name: 'My weight',
          unit: 'kg',
          metricType: MetricType.bodyWeight,
        ),
      );
      await seedBodyWeight();

      final emitted = await repo.watchOfficialBodyWeightCategory().first;

      expect(emitted!.id, testBodyWeightCategoryId);
    });

    test('is null before the category has been synced', () async {
      await seedCategoriesAndEntries();

      expect(await repo.watchOfficialBodyWeightCategory().first, isNull);
    });
  });

  group('entry CRUD', () {
    test('addLocalDrift inserts a row visible in watchEntries', () async {
      await db
          .into(db.measurementCategoryTable)
          .insert(
            MeasurementCategory(id: '1', name: 'Body fat', unit: '%').toCompanion(),
          );

      await repo.addLocalDrift(testMeasurementEntry1);

      final entries = await repo.watchEntries('1', limit: 10).first;
      expect(entries, hasLength(1));
      expect(entries.single.value, 30);
    });

    test('updateLocalDrift overwrites the row with matching id', () async {
      await db
          .into(db.measurementCategoryTable)
          .insert(
            MeasurementCategory(id: '1', name: 'Body fat', unit: '%').toCompanion(),
          );
      await repo.addLocalDrift(testMeasurementEntry1);

      final updated = MeasurementEntry(
        id: testMeasurementEntry1.id,
        categoryId: testMeasurementEntry1.categoryId,
        date: testMeasurementEntry1.date,
        value: 99,
        notes: 'updated',
      );
      await repo.updateLocalDrift(updated);

      final entries = await repo.watchEntries('1', limit: 10).first;
      expect(entries.single.value, 99);
      expect(entries.single.notes, 'updated');
    });

    test('deleteLocalDrift removes the row with matching id', () async {
      await seedCategoriesAndEntries();

      await repo.deleteLocalDrift(testMeasurementEntry1.id!);

      final entries = await repo.watchEntries('1', limit: 10).first;
      expect(entries.map((e) => e.id), isNot(contains(testMeasurementEntry1.id)));
      expect(entries, hasLength(5));
    });
  });

  group('category CRUD', () {
    test('addLocalDriftCategory inserts a row visible in the category stream', () async {
      final category = MeasurementCategory(id: 'c1', name: 'Waist', unit: 'cm');

      await repo.addLocalDriftCategory(category);

      final emitted = await repo.watchAllWithoutEntries().first;
      expect(emitted, hasLength(1));
      expect(emitted.single.name, 'Waist');
      expect(emitted.single.isOfficial, isFalse);
    });

    test('isOfficial and metricType round-trip through the table', () async {
      await repo.addLocalDriftCategory(
        MeasurementCategory(
          id: 'bw',
          name: 'Weight',
          unit: 'kg',
          metricType: MetricType.bodyWeight,
          isOfficial: true,
        ),
      );

      final emitted = await repo.watchAllWithoutEntries().first;
      expect(emitted.single.isOfficial, isTrue);
      expect(emitted.single.metricType, MetricType.bodyWeight);
      expect(emitted.single.isOfficialBodyWeight, isTrue);
    });

    test('updateLocalDriftCategory overwrites name and unit', () async {
      final category = MeasurementCategory(id: 'c1', name: 'Waist', unit: 'cm');
      await repo.addLocalDriftCategory(category);

      await repo.updateLocalDriftCategory(
        MeasurementCategory(id: 'c1', name: 'Hips', unit: 'inch'),
      );

      final emitted = await repo.watchAllWithoutEntries().first;
      expect(emitted.single.name, 'Hips');
      expect(emitted.single.unit, 'inch');
    });

    test('deleteLocalDriftCategory removes the row', () async {
      await repo.addLocalDriftCategory(
        MeasurementCategory(id: 'c1', name: 'Waist', unit: 'cm'),
      );
      await repo.addLocalDriftCategory(
        MeasurementCategory(id: 'c2', name: 'Hips', unit: 'cm'),
      );

      await repo.deleteLocalDriftCategory('c1');

      final emitted = await repo.watchAllWithoutEntries().first;
      expect(emitted.map((c) => c.id), ['c2']);
    });
  });

  group('multi-value groups', () {
    Future<void> seedBloodPressureGroup() async {
      for (final category in getBloodPressureGroup()) {
        await repo.addLocalDriftCategory(category);
      }
    }

    test('the category stream attaches children to their parent in group order', () async {
      await seedBloodPressureGroup();

      final emitted = await repo.watchAllWithoutEntries().first;

      final parent = emitted.firstWhere((c) => c.id == 'bp');
      expect(parent.hasChildren, isTrue);
      expect(parent.children.map((c) => c.id), ['sys', 'dia']);
    });

    test('the category stream sorts categories by order before name', () async {
      await repo.addLocalDriftCategory(
        MeasurementCategory(id: 'c1', name: 'Aaa', unit: 'cm', order: 5),
      );
      await repo.addLocalDriftCategory(
        MeasurementCategory(id: 'c2', name: 'Zzz', unit: 'cm', order: 1),
      );

      final emitted = await repo.watchAllWithoutEntries().first;

      expect(emitted.map((c) => c.id), ['c2', 'c1']);
    });

    test('addLocalDriftGroupEntries inserts one entry per component', () async {
      await seedBloodPressureGroup();
      final date = DateTime.utc(2026, 7, 10, 14, 32);

      await repo.addLocalDriftGroupEntries([
        MeasurementEntry(id: 'e1', categoryId: 'sys', date: date, value: 120, notes: ''),
        MeasurementEntry(id: 'e2', categoryId: 'dia', date: date, value: 80, notes: ''),
      ]);

      final entries = await repo.watchGroupEntries('bp', limit: 10).first;
      expect(entries.map((e) => e.value).toSet(), {120, 80});
      expect(entries.first.date, entries.last.date);
    });

    test('deleteLocalDriftCategory removes children along with the parent', () async {
      await seedBloodPressureGroup();

      await repo.deleteLocalDriftCategory('bp');

      final emitted = await repo.watchAllWithoutEntries().first;
      expect(emitted, isEmpty);
    });
  });

  group('reorderCategories', () {
    test('persists the list positions as order', () async {
      await repo.addLocalDriftCategory(MeasurementCategory(id: 'c1', name: 'Aaa', unit: 'cm'));
      await repo.addLocalDriftCategory(MeasurementCategory(id: 'c2', name: 'Bbb', unit: 'cm'));
      await repo.addLocalDriftCategory(MeasurementCategory(id: 'c3', name: 'Ccc', unit: 'cm'));

      await repo.reorderCategories(['c3', 'c1', 'c2']);

      final emitted = await repo.watchAllWithoutEntries().first;
      expect(emitted.map((c) => c.id), ['c3', 'c1', 'c2']);
      expect(emitted.map((c) => c.order), [0, 1, 2]);
    });

    test('keeps the in-group order of children', () async {
      for (final category in getBloodPressureGroup()) {
        await repo.addLocalDriftCategory(category);
      }
      await repo.addLocalDriftCategory(
        MeasurementCategory(id: 'c1', name: 'Waist', unit: 'cm', order: 1),
      );

      await repo.reorderCategories(['c1', 'bp']);

      final emitted = await repo.watchAllWithoutEntries().first;
      final parent = emitted.firstWhere((c) => c.id == 'bp');
      expect(parent.order, 1);
      expect(parent.children.map((c) => c.id), ['sys', 'dia']);
    });
  });
}
