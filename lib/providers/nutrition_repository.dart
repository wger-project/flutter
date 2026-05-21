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

final nutritionRepositoryProvider = Provider<NutritionRepository>((ref) {
  final db = ref.read(driftPowerSyncDatabase);
  return NutritionRepository(db);
});

/// Data access for nutrition-related entities.
class NutritionRepository {
  final _logger = Logger('NutritionRepository');
  final DriftPowersyncDatabase _db;

  NutritionRepository(this._db);

  // --- Plans ---

  /// Streams all nutritional plans from the local PowerSync-backed Drift table.
  ///
  /// Sort matches Django's `NutritionalPlan.Meta.ordering = ['-start']`.
  Stream<List<NutritionalPlan>> watchAllDrift() {
    _logger.finer('Watching all local nutritional plans');
    return (_db.select(
      _db.nutritionalPlanTable,
    )..orderBy([(t) => OrderingTerm.desc(t.startDate)])).watch();
  }

  /// Inserts a nutritional plan into the local Drift table. If [plan] has no
  /// id, Drift mints one and writes it back to [plan.id] so the caller can
  /// reference it immediately (e.g. to add child meals in the same flow).
  Future<void> addPlanLocalDrift(NutritionalPlan plan) async {
    _logger.finer('Inserting local nutritional plan');
    final inserted = await _db.into(_db.nutritionalPlanTable).insertReturning(plan.toCompanion());
    plan.id = inserted.id;
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
  Future<void> deleteLocalDrift(String id) async {
    _logger.finer('Deleting local nutritional plan $id');
    await (_db.delete(_db.nutritionalPlanTable)..where((t) => t.id.equals(id))).go();
  }

  // --- Meals ---

  /// Streams all meals (across every plan) with their meal items hydrated
  /// from the same Drift database in one query. Re-emits whenever any of the
  /// joined tables changes.
  ///
  /// Each [MealItem] has its [Ingredient] and optional [IngredientWeightUnit]
  /// resolved via the same query
  Stream<List<Meal>> watchAllMealsHydrated() {
    _logger.finer('Watching all local meals');
    final query =
        _db.select(_db.mealTable).join([
          leftOuterJoin(_db.mealItemTable, _db.mealItemTable.mealId.equalsExp(_db.mealTable.id)),
          leftOuterJoin(
            _db.ingredientTable,
            _db.ingredientTable.id.equalsExp(_db.mealItemTable.ingredientId),
          ),
          leftOuterJoin(
            _db.ingredientImageTable,
            _db.ingredientImageTable.ingredientId.equalsExp(_db.ingredientTable.id),
          ),
          leftOuterJoin(
            _db.ingredientWeightUnitTable,
            _db.ingredientWeightUnitTable.ingredientId.equalsExp(_db.ingredientTable.id),
          ),
        ])..orderBy([
          OrderingTerm.asc(_db.mealTable.planId),
          OrderingTerm.asc(_db.mealTable.order),
          OrderingTerm.asc(_db.mealTable.time),
        ]);

    return query.watch().map(_hydrateMeals);
  }

  /// Collapses cross-joined rows into hydrated [Meal]s with their child items.
  List<Meal> _hydrateMeals(Iterable<TypedResult> rows) {
    final meals = <String, Meal>{};
    final itemsByMeal = <String, Map<String, MealItem>>{};
    final ingredients = <int, Ingredient>{};
    final weightUnitsByIngredient = <int, List<IngredientWeightUnit>>{};

    for (final row in rows) {
      final meal = row.readTable(_db.mealTable);
      meals.putIfAbsent(meal.id!, () => meal);

      final mealItem = row.readTableOrNull(_db.mealItemTable);
      if (mealItem == null) continue;

      final ingredient = row.readTableOrNull(_db.ingredientTable);
      final image = row.readTableOrNull(_db.ingredientImageTable);
      final wu = row.readTableOrNull(_db.ingredientWeightUnitTable);

      if (ingredient != null) {
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
      }

      itemsByMeal.putIfAbsent(meal.id!, () => {}).putIfAbsent(mealItem.id!, () => mealItem);
    }

    for (final ing in ingredients.values) {
      ing.weightUnits = weightUnitsByIngredient[ing.id] ?? const [];
    }
    for (final entry in itemsByMeal.entries) {
      final meal = meals[entry.key]!;
      meal.mealItems = entry.value.values.toList()..sort((a, b) => a.order.compareTo(b.order));
      for (final item in meal.mealItems) {
        final ing = ingredients[item.ingredientId];
        if (ing != null) {
          item.ingredient = ing;
          if (item.weightUnitId != null) {
            item.weightUnitObj = ing.weightUnits.firstWhereOrNull(
              (w) => w.id == item.weightUnitId,
            );
          }
        }
      }
    }

    return meals.values.toList();
  }

  /// Inserts a meal into the local Drift table. The caller must have set
  /// [Meal.planId]; if [Meal.id] is null Drift mints one and writes it back
  /// to [meal] so the caller can reference it immediately. The `order` is
  /// computed here as `MAX(order) + 1` over the plan's existing meals so
  /// that newly added meals land at the bottom of the ordering.
  Future<void> addMealLocalDrift(Meal meal) async {
    final maxOrder =
        await (_db.selectOnly(_db.mealTable)
              ..addColumns([_db.mealTable.order.max()])
              ..where(_db.mealTable.planId.equals(meal.planId)))
            .map((row) => row.read(_db.mealTable.order.max()))
            .getSingleOrNull();
    meal.order = (maxOrder ?? 0) + 1;
    _logger.finer('Inserting local meal (order=${meal.order})');
    final inserted = await _db.into(_db.mealTable).insertReturning(meal.toCompanion());
    meal.id = inserted.id;
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
  Future<void> deleteMealLocalDrift(String id) async {
    _logger.finer('Deleting local meal $id');
    await (_db.delete(_db.mealTable)..where((t) => t.id.equals(id))).go();
  }

  // --- Meal items ---

  /// Inserts a meal item into the local Drift table. The caller must have
  /// set [MealItem.mealId] (parent meal's UUID); if [MealItem.id] is null
  /// Drift mints one and writes it back. `order` is computed here as
  /// `MAX(order) + 1` over the meal's existing items.
  Future<void> addMealItemLocalDrift(MealItem item) async {
    final maxOrder =
        await (_db.selectOnly(_db.mealItemTable)
              ..addColumns([_db.mealItemTable.order.max()])
              ..where(_db.mealItemTable.mealId.equals(item.mealId)))
            .map((row) => row.read(_db.mealItemTable.order.max()))
            .getSingleOrNull();
    item.order = (maxOrder ?? 0) + 1;
    _logger.finer('Inserting local meal item (order=${item.order})');
    final inserted = await _db.into(_db.mealItemTable).insertReturning(item.toCompanion());
    item.id = inserted.id;
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
  Future<void> deleteMealItemLocalDrift(String id) async {
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
