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
import 'package:wger/models/user/user_profile.dart';
import 'package:wger/providers/user_profile_repository.dart';

import '../helpers/in_memory_drift.dart';

void main() {
  late DriftPowersyncDatabase db;
  late UserProfileRepository repo;

  setUp(() async {
    db = await openTestDatabase();
    repo = UserProfileRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seed({int id = 1, String weightUnit = 'kg'}) async {
    await db
        .into(db.userProfileTable)
        .insert(UserProfileTableCompanion.insert(id: id, weightUnitStr: weightUnit));
  }

  group('watchDrift', () {
    test('emits null until a row has synced down', () async {
      expect(await repo.watchDrift().first, isNull);
    });

    test('emits the synced profile row', () async {
      await seed(weightUnit: 'lb');

      final profile = await repo.watchDrift().first;

      expect(profile, isNotNull);
      expect(profile!.id, 1);
      expect(profile.weightUnitStr, 'lb');
    });

    test('re-emits after the row changes', () async {
      await seed();
      final iter = StreamIterator(repo.watchDrift());

      await iter.moveNext();
      expect(iter.current!.weightUnitStr, 'kg');

      await repo.editLocalDrift(UserProfile(id: 1, weightUnitStr: 'lb'));

      await iter.moveNext();
      expect(iter.current!.weightUnitStr, 'lb');

      await iter.cancel();
    });
  });

  group('editLocalDrift', () {
    test('overwrites the weight unit for the row with matching id', () async {
      await seed();

      await repo.editLocalDrift(UserProfile(id: 1, weightUnitStr: 'lb'));

      final row = await db.select(db.userProfileTable).getSingle();
      expect(row.weightUnitStr, 'lb');
    });
  });
}
