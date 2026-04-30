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
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:wger/database/powersync/database.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/models/nutrition/ingredient_weight_unit.dart';
import 'package:wger/models/nutrition/log.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/providers/base_provider.dart';
import 'package:wger/providers/wger_base.dart';

enum IngredientSearchLanguage {
  current,
  currentAndEnglish,
  all,
}

final nutritionRepositoryProvider = Provider<NutritionRepository>((ref) {
  final base = ref.read(wgerBaseProvider);
  final db = ref.read(driftPowerSyncDatabase);
  return NutritionRepository(base, db);
});

/// Data access for nutrition-related entities.
///
/// HTTP only for what hasn't migrated to PowerSync yet (plan creation, meals
/// and meal items). Reads/edits/deletes for the top-level [NutritionalPlan]
/// and the diary [LogItem] table go through the local PowerSync-backed Drift
/// database — see [watchAllDrift], [editLocalDrift], [deleteLocalDrift],
/// [watchAllLogsHydrated], [addLogLocalDrift], [deleteLogLocalDrift].
///
/// Local ingredient lookups are handled by [IngredientRepository] (PowerSync).
class NutritionRepository {
  final _logger = Logger('NutritionRepository');
  final WgerBaseProvider _base;
  final DriftPowersyncDatabase _db;

  static const plansPath = 'nutritionplan';
  static const plansInfoPath = 'nutritionplaninfo';
  static const mealPath = 'meal';
  static const mealItemPath = 'mealitem';
  static const ingredientInfoPath = 'ingredientinfo';

  NutritionRepository(this._base, this._db);

  // --- Plans ---

  Future<List<dynamic>> fetchAllPlans() async {
    _logger.fine('Fetching all plans (sparse)');
    return _base.fetchPaginated(
      _base.makeUrl(plansPath, query: {'limit': API_MAX_PAGE_SIZE}),
    );
  }

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

  Future<void> updatePlan(int id, Map<String, dynamic> data) async {
    await _base.patch(data, _base.makeUrl(plansPath, id: id));
  }

  Future<http.Response> deletePlan(int id) async {
    return _base.deleteRequest(plansPath, id);
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

  Future<Map<String, dynamic>> createMeal(Map<String, dynamic> data) async {
    return _base.post(data, _base.makeUrl(mealPath));
  }

  Future<Map<String, dynamic>> updateMeal(int id, Map<String, dynamic> data) async {
    return _base.patch(data, _base.makeUrl(mealPath, id: id));
  }

  Future<http.Response> deleteMeal(int id) async {
    return _base.deleteRequest(mealPath, id);
  }

  // --- Meal items ---

  Future<Map<String, dynamic>> createMealItem(Map<String, dynamic> data) async {
    return _base.post(data, _base.makeUrl(mealItemPath));
  }

  Future<http.Response> deleteMealItem(int id) async {
    return _base.deleteRequest(mealItemPath, id);
  }

  // --- Ingredients ---

  /// Searches for an ingredient via the REST API.
  ///
  /// [nutriscoreMax] — if non-null, the worst acceptable Nutri-Score grade,
  /// sent to the backend as `nutriscore__lte`. The Django filterset
  /// compares lexicographically on the `a`..`e` choices, so passing
  /// [NutriScore.b] yields "only A or B".
  Future<List<Ingredient>> searchIngredient(
    String name, {
    String languageCode = 'en',
    IngredientSearchLanguage searchLanguage = IngredientSearchLanguage.current,
    bool isVegan = false,
    bool isVegetarian = false,
    NutriScore? nutriscoreMax,
  }) async {
    if (name.length <= 1) {
      return [];
    }
    final List<String> languages = [];

    switch (searchLanguage) {
      case IngredientSearchLanguage.current:
        languages.add(languageCode);
      case IngredientSearchLanguage.currentAndEnglish:
        languages.add(languageCode);
        if (languageCode != LANGUAGE_SHORT_ENGLISH) {
          languages.add(LANGUAGE_SHORT_ENGLISH);
        }
      case IngredientSearchLanguage.all:
        // Don't add any language code to search in all languages
        break;
    }

    final query = {
      'name__search': name,
      'limit': API_RESULTS_PAGE_SIZE,
    };
    if (languages.isNotEmpty) {
      query['language__code'] = languages.join(',');
    }
    if (isVegan) {
      query['is_vegan'] = 'true';
    }
    if (isVegetarian) {
      query['is_vegetarian'] = 'true';
    }
    if (nutriscoreMax != null) {
      query['nutriscore__lte'] = nutriscoreMax.name;
    }

    _logger.info('Searching ingredients from server');
    final response = await _base.fetch(
      _base.makeUrl(ingredientInfoPath, query: query),
      timeout: const Duration(seconds: 20),
    );

    return (response['results'] as List)
        .map((data) => Ingredient.fromJson(data as Map<String, dynamic>))
        .toList();
  }

  Future<Ingredient?> searchIngredientWithBarcode(String barcode) async {
    if (barcode.isEmpty) {
      return null;
    }
    final data = await _base.fetch(
      _base.makeUrl(ingredientInfoPath, query: {'code': barcode}),
    );
    if (data['count'] == 0) {
      return null;
    }
    return Ingredient.fromJson(data['results'][0]);
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
