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
import 'package:mockito/annotations.dart';
import 'package:wger/database/powersync/database.dart';
import 'package:wger/models/gallery/image.dart';
import 'package:wger/providers/base_provider.dart';
import 'package:wger/providers/gallery_repository.dart';

import '../../test_data/gallery.dart';
import '../helpers/in_memory_drift.dart';
import 'gallery_repository_test.mocks.dart';

@GenerateMocks([WgerBaseProvider])
void main() {
  late DriftPowersyncDatabase db;
  late MockWgerBaseProvider mockBase;
  late GalleryRepository repo;

  setUp(() async {
    db = await openTestDatabase();
    mockBase = MockWgerBaseProvider();
    repo = GalleryRepository(mockBase, db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seed(List<GalleryImage> images) async {
    // GalleryImage.toCompanion() omits the `image` path on purpose
    // (REST handles file changes), but the column is non-nullable. Seed via
    // the table companion directly so we get a valid row in the DB.
    for (final image in images) {
      await db
          .into(db.galleryImageTable)
          .insert(
            GalleryImageTableCompanion.insert(
              id: image.id!,
              date: DateTime.utc(image.date.year, image.date.month, image.date.day),
              imagePath: image.imagePath ?? '',
              description: image.description,
            ),
          );
    }
  }

  Future<List<GalleryImage>> readAll() => db.select(db.galleryImageTable).get();

  group('watchAllDrift', () {
    test('emits seeded rows ordered by date desc', () async {
      await seed(getTestImages());

      final emitted = await repo.watchAllDrift().first;

      expect(emitted, hasLength(4));
      expect(emitted.first.date.month, 5);
      expect(emitted.last.date, DateTime.utc(2021, 2, 22));
    });

    test('re-emits after a row is added', () async {
      final stream = repo.watchAllDrift();
      final iter = StreamIterator(stream);

      await iter.moveNext();
      expect(iter.current, isEmpty);

      await seed([getTestImages().first]);

      await iter.moveNext();
      expect(iter.current, hasLength(1));

      await iter.cancel();
    });
  });

  group('editLocalDrift', () {
    test('overwrites date and description for the row with matching id', () async {
      await seed([getTestImages().first]);

      final updated = GalleryImage(
        id: 1,
        date: DateTime.utc(2026, 1, 1),
        description: 'updated description',
        imagePath: 'this-is-ignored-by-toCompanion',
      );
      await repo.editLocalDrift(updated);

      final rows = await readAll();
      expect(rows.single.date, DateTime.utc(2026, 1, 1));
      expect(rows.single.description, 'updated description');
    });

    test('throws StateError when the image has no id', () async {
      final image = GalleryImage(date: DateTime.utc(2026, 1, 1), description: 'no id');

      expect(() => repo.editLocalDrift(image), throwsStateError);
    });
  });

  group('deleteLocalDrift', () {
    test('removes the row with matching id', () async {
      await seed(getTestImages());

      await repo.deleteLocalDrift(2);

      final rows = await readAll();
      expect(rows.map((r) => r.id).toSet(), {1, 3, 4});
    });

    test('on a non-existent id is a no-op', () async {
      await seed([getTestImages().first]);

      await repo.deleteLocalDrift(999);

      expect(await readAll(), hasLength(1));
    });
  });

  // Note: addImageServer and editImageServer are not unit-tested here. Both
  // build an http.MultipartRequest and call .send() directly without going
  // through WgerBaseProvider, so a proper test requires HTTP-level mocking.
}
