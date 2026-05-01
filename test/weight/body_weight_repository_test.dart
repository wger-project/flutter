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
import 'package:wger/models/body_weight/weight_entry.dart';
import 'package:wger/providers/body_weight_repository.dart';

import '../../test_data/body_weight.dart';
import '../helpers/in_memory_drift.dart';

void main() {
  late DriftPowersyncDatabase db;
  late BodyWeightRepository repo;

  setUp(() async {
    db = await openTestDatabase();
    repo = BodyWeightRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<List<WeightEntry>> readAll() => db.select(db.weightEntryTable).get();

  test('addLocalDrift inserts a row visible via the table query', () async {
    await repo.addLocalDrift(testWeightEntry1);

    final rows = await readAll();
    expect(rows, hasLength(1));
    expect(rows.first.weight, testWeightEntry1.weight);
    expect(rows.first.date, testWeightEntry1.date);
    // The entry's `id` field is ignored on insert (toCompanion uses
    // includeId:false) so the table's clientDefault assigns a fresh UUID.
    expect(rows.first.id, isNotEmpty);
  });

  test('updateLocalDrift overwrites the row with matching id', () async {
    await repo.addLocalDrift(testWeightEntry1);
    final inserted = (await readAll()).single;

    final updated = WeightEntry(
      id: inserted.id,
      weight: 90.0,
      date: DateTime.utc(2026, 4, 16),
    );
    await repo.updateLocalDrift(updated);

    final rows = await readAll();
    expect(rows, hasLength(1));
    expect(rows.first.id, inserted.id);
    expect(rows.first.weight, 90.0);
    expect(rows.first.date, DateTime.utc(2026, 4, 16));
  });

  test('deleteLocalDrift removes the row with matching id', () async {
    await repo.addLocalDrift(testWeightEntry1);
    await repo.addLocalDrift(testWeightEntry2);
    final all = await readAll();
    final toDelete = all.firstWhere((e) => e.weight == testWeightEntry1.weight).id!;

    await repo.deleteLocalDrift(toDelete);

    final remaining = await readAll();
    expect(remaining, hasLength(1));
    expect(remaining.first.weight, testWeightEntry2.weight);
  });

  test('deleteLocalDrift on a non-existent id is a no-op', () async {
    await repo.addLocalDrift(testWeightEntry1);

    await repo.deleteLocalDrift('does-not-exist');

    expect(await readAll(), hasLength(1));
  });

  group('watchAllDrift', () {
    test('emits the current rows ordered by date desc', () async {
      // testWeightEntry1.date = 2021-01-01; testWeightEntry2.date = 2021-01-10.
      // Insert in non-sorted order to make sure the order comes from the query,
      // not insertion order.
      await repo.addLocalDrift(testWeightEntry1);
      await repo.addLocalDrift(testWeightEntry2);

      final emitted = await repo.watchAllDrift().first;

      expect(
        emitted.map((e) => e.weight).toList(),
        [testWeightEntry2.weight, testWeightEntry1.weight],
      );
    });

    test('re-emits after an insert', () async {
      final stream = repo.watchAllDrift();
      final iter = StreamIterator(stream);

      await iter.moveNext();
      expect(iter.current, isEmpty);

      await repo.addLocalDrift(testWeightEntry1);

      await iter.moveNext();
      expect(iter.current, hasLength(1));

      await iter.cancel();
    });
  });
}
