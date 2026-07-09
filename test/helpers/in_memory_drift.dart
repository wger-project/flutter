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

import 'package:drift/native.dart';
import 'package:wger/database/powersync/database.dart';

/// Builds a fresh, empty [DriftPowersyncDatabase] backed by an in-memory
/// SQLite instance. The schema is created explicitly because the production
/// migration is a no-op (PowerSync owns the schema in production).
///
/// Each call returns an isolated database, call this in `setUp`, and call
/// `db.close()` in `tearDown`.
Future<DriftPowersyncDatabase> openTestDatabase() async {
  final db = DriftPowersyncDatabase(NativeDatabase.memory());
  await db.customStatement('PRAGMA foreign_keys = OFF');
  await db.createMigrator().createAll();
  return db;
}
