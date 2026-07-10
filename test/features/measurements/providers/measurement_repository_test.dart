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
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';
import 'package:wger/features/measurements/providers/measurement_repository.dart';

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
      for (final entry in category.entries) {
        await db.into(db.measurementEntryTable).insert(entry.toCompanion());
      }
    }
  }

  group('watchAll', () {
    test('groups entries under their category', () async {
      await seedCategoriesAndEntries();

      final emitted = await repo.watchAll().first;

      expect(emitted, hasLength(2));
      final bodyFat = emitted.firstWhere((c) => c.name == 'Body fat');
      final biceps = emitted.firstWhere((c) => c.name == 'Biceps');
      expect(bodyFat.entries, hasLength(6));
      expect(biceps.entries, hasLength(2));
      expect(bodyFat.entries.every((e) => e.categoryId == '1'), isTrue);
      expect(biceps.entries.every((e) => e.categoryId == '2'), isTrue);
    });

    test('returns categories without entries when no entries exist', () async {
      // Seed only the categories, no entries.
      await db
          .into(db.measurementCategoryTable)
          .insert(
            MeasurementCategory(id: '1', name: 'Body fat', unit: '%').toCompanion(),
          );

      final emitted = await repo.watchAll().first;

      expect(emitted, hasLength(1));
      expect(emitted.first.entries, isEmpty);
    });

    test('emits entries newest first within each category', () async {
      await seedCategoriesAndEntries();

      final emitted = await repo.watchAll().first;

      final bodyFat = emitted.firstWhere((c) => c.name == 'Body fat');
      final dates = bodyFat.entries.map((e) => e.date).toList();
      final sorted = [...dates]..sort((a, b) => b.compareTo(a));
      expect(dates, sorted);
    });

    test('re-emits when an entry is added', () async {
      await seedCategoriesAndEntries();
      final stream = repo.watchAll();
      final iter = StreamIterator(stream);

      await iter.moveNext();
      final initial = iter.current.firstWhere((c) => c.name == 'Body fat').entries.length;

      await repo.addLocalDrift(
        MeasurementEntry(
          categoryId: '1',
          date: DateTime.utc(2027, 1, 1),
          value: 99,
          notes: 'fresh',
        ),
      );

      await iter.moveNext();
      expect(
        iter.current.firstWhere((c) => c.name == 'Body fat').entries,
        hasLength(initial + 1),
      );

      await iter.cancel();
    });
  });

  group('watchLocalDriftCategoryById', () {
    test('returns the matching category', () async {
      await seedCategoriesAndEntries();

      final emitted = await repo.watchLocalDriftCategoryById('1').first;

      expect(emitted, isNotNull);
      expect(emitted!.name, 'Body fat');
      expect(emitted.entries, hasLength(6));
    });

    test('returns null when no category matches', () async {
      await seedCategoriesAndEntries();

      final emitted = await repo.watchLocalDriftCategoryById('does-not-exist').first;

      expect(emitted, isNull);
    });
  });

  group('entry CRUD', () {
    test('addLocalDrift inserts a row visible in watchAll', () async {
      await db
          .into(db.measurementCategoryTable)
          .insert(
            MeasurementCategory(id: '1', name: 'Body fat', unit: '%').toCompanion(),
          );

      await repo.addLocalDrift(testMeasurementEntry1);

      final categories = await repo.watchAll().first;
      expect(categories.first.entries, hasLength(1));
      expect(categories.first.entries.single.value, 30);
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

      final entries = (await repo.watchAll().first).first.entries;
      expect(entries.single.value, 99);
      expect(entries.single.notes, 'updated');
    });

    test('deleteLocalDrift removes the row with matching id', () async {
      await seedCategoriesAndEntries();

      await repo.deleteLocalDrift(testMeasurementEntry1.id!);

      final entries = (await repo.watchAll().first).firstWhere((c) => c.name == 'Body fat').entries;
      expect(entries.map((e) => e.id), isNot(contains(testMeasurementEntry1.id)));
      expect(entries, hasLength(5));
    });
  });

  group('category CRUD', () {
    test('addLocalDriftCategory inserts a row visible in watchAll', () async {
      final category = MeasurementCategory(id: 'c1', name: 'Waist', unit: 'cm');

      await repo.addLocalDriftCategory(category);

      final emitted = await repo.watchAll().first;
      expect(emitted, hasLength(1));
      expect(emitted.single.name, 'Waist');
    });

    test('updateLocalDriftCategory overwrites name and unit', () async {
      final category = MeasurementCategory(id: 'c1', name: 'Waist', unit: 'cm');
      await repo.addLocalDriftCategory(category);

      await repo.updateLocalDriftCategory(
        MeasurementCategory(id: 'c1', name: 'Hips', unit: 'inch'),
      );

      final emitted = await repo.watchAll().first;
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

      final emitted = await repo.watchAll().first;
      expect(emitted.map((c) => c.id), ['c2']);
    });
  });

  group('multi-value groups', () {
    Future<void> seedBloodPressureGroup() async {
      await repo.addLocalDriftCategory(
        MeasurementCategory(id: 'bp', name: 'Blood pressure', unit: 'mmHg'),
      );
      await repo.addLocalDriftCategory(
        MeasurementCategory(id: 'sys', name: 'Systolic', unit: 'mmHg', parentId: 'bp', order: 0),
      );
      await repo.addLocalDriftCategory(
        MeasurementCategory(id: 'dia', name: 'Diastolic', unit: 'mmHg', parentId: 'bp', order: 1),
      );
    }

    test('watchAll attaches children to their parent in group order', () async {
      await seedBloodPressureGroup();

      final emitted = await repo.watchAll().first;

      final parent = emitted.firstWhere((c) => c.id == 'bp');
      expect(parent.isGroup, isTrue);
      expect(parent.children.map((c) => c.id), ['sys', 'dia']);
    });

    test('watchAll sorts categories by order before name', () async {
      await repo.addLocalDriftCategory(
        MeasurementCategory(id: 'c1', name: 'Aaa', unit: 'cm', order: 5),
      );
      await repo.addLocalDriftCategory(
        MeasurementCategory(id: 'c2', name: 'Zzz', unit: 'cm', order: 1),
      );

      final emitted = await repo.watchAll().first;

      expect(emitted.map((c) => c.id), ['c2', 'c1']);
    });

    test('addLocalDriftGroupEntries inserts one entry per component', () async {
      await seedBloodPressureGroup();
      final date = DateTime.utc(2026, 7, 10, 14, 32);

      await repo.addLocalDriftGroupEntries([
        MeasurementEntry(id: 'e1', categoryId: 'sys', date: date, value: 120, notes: ''),
        MeasurementEntry(id: 'e2', categoryId: 'dia', date: date, value: 80, notes: ''),
      ]);

      final emitted = await repo.watchAll().first;
      final parent = emitted.firstWhere((c) => c.id == 'bp');
      expect(parent.children.first.entries.single.value, 120);
      expect(parent.children.last.entries.single.value, 80);
      expect(
        parent.children.first.entries.single.date,
        parent.children.last.entries.single.date,
      );
    });

    test('deleteLocalDriftCategory removes children along with the parent', () async {
      await seedBloodPressureGroup();

      await repo.deleteLocalDriftCategory('bp');

      final emitted = await repo.watchAll().first;
      expect(emitted, isEmpty);
    });
  });

  group('reorderCategories', () {
    test('persists the list positions as order', () async {
      await repo.addLocalDriftCategory(MeasurementCategory(id: 'c1', name: 'Aaa', unit: 'cm'));
      await repo.addLocalDriftCategory(MeasurementCategory(id: 'c2', name: 'Bbb', unit: 'cm'));
      await repo.addLocalDriftCategory(MeasurementCategory(id: 'c3', name: 'Ccc', unit: 'cm'));

      await repo.reorderCategories(['c3', 'c1', 'c2']);

      final emitted = await repo.watchAll().first;
      expect(emitted.map((c) => c.id), ['c3', 'c1', 'c2']);
      expect(emitted.map((c) => c.order), [0, 1, 2]);
    });

    test('keeps the in-group order of children', () async {
      await repo.addLocalDriftCategory(
        MeasurementCategory(id: 'bp', name: 'Blood pressure', unit: 'mmHg'),
      );
      await repo.addLocalDriftCategory(
        MeasurementCategory(id: 'sys', name: 'Systolic', unit: 'mmHg', parentId: 'bp', order: 0),
      );
      await repo.addLocalDriftCategory(
        MeasurementCategory(id: 'dia', name: 'Diastolic', unit: 'mmHg', parentId: 'bp', order: 1),
      );
      await repo.addLocalDriftCategory(
        MeasurementCategory(id: 'c1', name: 'Waist', unit: 'cm', order: 1),
      );

      await repo.reorderCategories(['c1', 'bp']);

      final emitted = await repo.watchAll().first;
      final parent = emitted.firstWhere((c) => c.id == 'bp');
      expect(parent.order, 1);
      expect(parent.children.map((c) => c.id), ['sys', 'dia']);
    });
  });
}
