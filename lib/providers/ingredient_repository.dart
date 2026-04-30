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
import 'package:wger/models/nutrition/ingredient_weight_unit.dart';

import '../database/powersync/database.dart';

final ingredientRepositoryProvider = Provider<IngredientRepository>((ref) {
  final db = ref.read(driftPowerSyncDatabase);
  return IngredientRepository(db);
});

class IngredientRepository {
  final _logger = Logger('IngredientRepository');
  final DriftPowersyncDatabase _db;

  IngredientRepository(this._db);

  /// Watches a single ingredient by [id] with its `image` and `weightUnits`
  /// fields fully hydrated. Emits `null` if no ingredient with that id exists,
  /// and re-emits whenever the ingredient row, its image, or any of its
  /// weight units change.
  Stream<Ingredient?> watchById(int id) {
    _logger.finer('Watching ingredient $id');
    final query = (_db.select(_db.ingredientTable)..where((t) => t.id.equals(id))).join([
      leftOuterJoin(
        _db.ingredientImageTable,
        _db.ingredientImageTable.ingredientId.equalsExp(_db.ingredientTable.id),
      ),
      leftOuterJoin(
        _db.ingredientWeightUnitTable,
        _db.ingredientWeightUnitTable.ingredientId.equalsExp(_db.ingredientTable.id),
      ),
    ]);

    return query.watch().map((rows) {
      if (rows.isEmpty) {
        return null;
      }
      final ingredient = rows.first.readTable(_db.ingredientTable);
      ingredient.image = rows.first.readTableOrNull(_db.ingredientImageTable);
      ingredient.weightUnits = rows
          .map((r) => r.readTableOrNull(_db.ingredientWeightUnitTable))
          .whereType<IngredientWeightUnit>()
          .toList();
      return ingredient;
    });
  }

  /// Read a single ingredient by [id] once from the DB
  Future<Ingredient?> getById(int id) async {
    _logger.finer('Reading ingredient $id');
    return watchById(id).first;
  }
}
