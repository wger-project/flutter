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

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:wger/models/nutrition/ingredient.dart';

import '../database/powersync/database.dart';

final ingredientRepositoryProvider = Provider<IngredientRepository>((ref) {
  final db = ref.read(driftPowerSyncDatabase);
  return IngredientRepository(db);
});

class IngredientRepository {
  final _logger = Logger('IngredientRepository');
  final DriftPowersyncDatabase _db;

  IngredientRepository(this._db);

  /// Watches a single ingredient by [id], with its `image` field hydrated.
  /// Emits `null` if no ingredient with that id exists, and re-emits whenever
  /// either the ingredient row or its image change.
  Stream<Ingredient?> watchById(int id) {
    _logger.finer('Watching ingredient $id');
    final joined = (_db.select(_db.ingredientTable)..where((t) => t.id.equals(id))).join([
      leftOuterJoin(
        _db.ingredientImageTable,
        _db.ingredientImageTable.ingredientId.equalsExp(_db.ingredientTable.id),
      ),
    ]);

    return joined.watchSingleOrNull().map((row) {
      if (row == null) {
        return null;
      }
      final ingredient = row.readTable(_db.ingredientTable);
      ingredient.image = row.readTableOrNull(_db.ingredientImageTable);
      return ingredient;
    });
  }

  /// Read a single ingredient by [id] once from the DB
  Future<Ingredient?> getById(int id) async {
    _logger.finer('Reading ingredient $id');
    return watchById(id).first;
  }
}
