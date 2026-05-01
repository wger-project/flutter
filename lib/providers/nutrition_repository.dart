/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
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
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:wger/database/powersync/database.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/models/nutrition/ingredient_weight_unit.dart';
import 'package:wger/models/nutrition/log.dart';
import 'package:wger/models/nutrition/meal.dart';
import 'package:wger/models/nutrition/meal_item.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/providers/base_provider.dart';
import 'package:wger/providers/wger_base.dart';

final nutritionRepositoryProvider = Provider<NutritionRepository>((ref) {
  final base = ref.read(wgerBaseProvider);
  final db = ref.read(driftPowerSyncDatabase);
  return NutritionRepository(base, db);
});

/// Data access for nutrition-related entities.
///
/// Creation paths still use HTTP (plans, meals, meal items — the server picks
/// the integer PK and the `order`). Edits and deletes for [NutritionalPlan],
/// [Meal], [MealItem] and the diary [LogItem] table all flow through the
/// local PowerSync-backed Drift database; see [editLocalDrift] /
/// [deleteLocalDrift] (plans), [editMealLocalDrift] / [deleteMealLocalDrift],
/// [editMealItemLocalDrift] / [deleteMealItemLocalDrift], and the log
/// methods.
///
/// Ingredient searches (local + REST) live on [IngredientRepository].
class NutritionRepository {
  final _logger = Logger('NutritionRepository');
  final WgerBaseProvider _base;
  final DriftPowersyncDatabase _db;

  static const plansPath = 'nutritionplan';
  static const plansInfoPath = 'nutritionplaninfo';
  static const mealPath = 'meal';
  static const mealItemPath = 'mealitem';

  NutritionRepository(this._base, this._db);

  // --- Plans ---

  Future<Map<String, dynamic>> fetchPlanSparse(int planId) async {
    _logger.fine('Fetching plan $planId (sparse)');
    final data = await _base.fetch(_base.makeUrl(plansPath, id: planId));
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> fetchPlanFull(int planId) async {
    _logger.fine('Fetching plan $planId (full)');
    final data = await _base.fetch(_base.makeUrl(plansInfoPath, id: planId));
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createPlan(Map<String, dynamic> data) async {
    return _base.post(data, _base.makeUrl(plansPath));
  }

  /// Streams all nutritional plans from the local PowerSync-backed Drift table.
  ///
  /// Sort matches Django's `NutritionalPlan.Meta.ordering = ['-start']` so
  /// that REST responses and PowerSync emissions agree on the row order.
  Stream<List<NutritionalPlan>> watchAllDrift() {
    _logger.finer('Watching all local nutritional plans');
    return (_db.select(
      _db.nutritionalPlanTable,
    )..orderBy([(t) => OrderingTerm.desc(t.startDate)])).watch();
  }

  /// Updates a nutritional plan via the local Drift table. PowerSync's CRUD
  /// queue picks the change up and pushes it to the backend.
  Future<void> editLocalDrift(NutritionalPlan plan) async {
    final id = plan.id;
    if (id == null) {
      throw StateError('Cannot edit a nutritional plan without id');
    }
    _logger.finer('Updating local nutritional plan $id');
    await (_db.update(
      _db.nutritionalPlanTable,
    )..where((t) => t.id.equals(id))).write(plan.toCompanion());
  }

  /// Deletes a nutritional plan via the local Drift table. Deletion of children
  /// entities (meals, meal items, diary entries) is handled by the backend via
  /// FK CASCADE, so we don't have to worry about that here.
  Future<void> deleteLocalDrift(int id) async {
    _logger.finer('Deleting local nutritional plan $id');
    await (_db.delete(_db.nutritionalPlanTable)..where((t) => t.id.equals(id))).go();
  }

  // --- Meals ---

  /// Creation still goes through REST: the server assigns the integer PK and
  /// the `order` field, then PowerSync replicates the row down so subsequent
  /// edits and deletes can target the local Drift row.
  Future<Map<String, dynamic>> createMeal(Map<String, dynamic> data) async {
    return _base.post(data, _base.makeUrl(mealPath));
  }

  /// Updates a meal via the local Drift table. PowerSync's CRUD queue picks
  /// the change up and PATCHes it to the backend.
  Future<void> editMealLocalDrift(Meal meal) async {
    final id = meal.id;
    if (id == null) {
      throw StateError('Cannot edit a meal without id');
    }
    _logger.finer('Updating local meal $id');
    await (_db.update(_db.mealTable)..where((t) => t.id.equals(id))).write(meal.toCompanion());
  }

  /// Deletes a meal via the local Drift table. The backend cascades through
  /// to the dependent meal items.
  Future<void> deleteMealLocalDrift(int id) async {
    _logger.finer('Deleting local meal $id');
    await (_db.delete(_db.mealTable)..where((t) => t.id.equals(id))).go();
  }

  // --- Meal items ---

  /// Creation still goes through REST (server-assigned PK and `order`);
  /// PowerSync replicates the row down for subsequent local edits/deletes.
  Future<Map<String, dynamic>> createMealItem(Map<String, dynamic> data) async {
    return _base.post(data, _base.makeUrl(mealItemPath));
  }

  /// Updates a meal item via the local Drift table. PowerSync picks the
  /// change up and PATCHes it to the backend.
  Future<void> editMealItemLocalDrift(MealItem item) async {
    final id = item.id;
    if (id == null) {
      throw StateError('Cannot edit a meal item without id');
    }
    _logger.finer('Updating local meal item $id');
    await (_db.update(_db.mealItemTable)..where((t) => t.id.equals(id))).write(item.toCompanion());
  }

  /// Deletes a meal item via the local Drift table.
  Future<void> deleteMealItemLocalDrift(int id) async {
    _logger.finer('Deleting local meal item $id');
    await (_db.delete(_db.mealItemTable)..where((t) => t.id.equals(id))).go();
  }

  // --- Nutrition diary (logs) ---

  /// Streams all of the user's diary entries with their related [Ingredient]
  /// (incl. its image and weight units) hydrated from the same Drift database
  /// in one query. Re-emits whenever any of the joined tables changes.
  Stream<List<LogItem>> watchAllLogsHydrated() {
    _logger.finer('Watching all local diary entries');
    final query = _db.select(_db.logItemTable).join([
      innerJoin(
        _db.ingredientTable,
        _db.ingredientTable.id.equalsExp(_db.logItemTable.ingredientId),
      ),
      leftOuterJoin(
        _db.ingredientImageTable,
        _db.ingredientImageTable.ingredientId.equalsExp(_db.ingredientTable.id),
      ),
      leftOuterJoin(
        _db.ingredientWeightUnitTable,
        _db.ingredientWeightUnitTable.ingredientId.equalsExp(_db.ingredientTable.id),
      ),
    ])..orderBy([OrderingTerm(expression: _db.logItemTable.datetime)]);

    return query.watch().map(_hydrateLogs);
  }

  /// Collapses the cross-joined rows into hydrated [LogItem]s.
  List<LogItem> _hydrateLogs(Iterable<TypedResult> rows) {
    final logs = <String, LogItem>{};
    final ingredients = <int, Ingredient>{};
    final weightUnitsByIngredient = <int, List<IngredientWeightUnit>>{};

    for (final row in rows) {
      final log = row.readTable(_db.logItemTable);
      final ingredient = row.readTable(_db.ingredientTable);
      final image = row.readTableOrNull(_db.ingredientImageTable);
      final wu = row.readTableOrNull(_db.ingredientWeightUnitTable);

      final ingEntry = ingredients.putIfAbsent(ingredient.id, () => ingredient);
      if (image != null) {
        ingEntry.image = image;
      }
      if (wu != null) {
        final list = weightUnitsByIngredient.putIfAbsent(ingredient.id, () => []);
        if (!list.any((w) => w.id == wu.id)) {
          list.add(wu);
        }
      }

      logs.putIfAbsent(log.id!, () => log);
    }

    for (final ing in ingredients.values) {
      ing.weightUnits = weightUnitsByIngredient[ing.id] ?? const [];
    }
    for (final log in logs.values) {
      log.ingredient = ingredients[log.ingredientId]!;
      if (log.weightUnitId != null) {
        log.weightUnitObj = log.ingredient.weightUnits.firstWhereOrNull(
          (w) => w.id == log.weightUnitId,
        );
      }
    }

    return logs.values.toList();
  }

  /// Inserts a new diary entry
  Future<void> addLogLocalDrift(LogItem log) async {
    _logger.finer('Adding local diary entry for ingredient ${log.ingredientId}');
    await _db.into(_db.logItemTable).insert(log.toCompanion());
  }

  /// Deletes a diary entry by its UUID
  Future<void> deleteLogLocalDrift(String id) async {
    _logger.finer('Deleting local diary entry $id');
    await (_db.delete(_db.logItemTable)..where((t) => t.id.equals(id))).go();
  }
}
