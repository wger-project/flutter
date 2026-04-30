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

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:wger/database/powersync/database.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/models/nutrition/ingredient_weight_unit.dart';
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
/// HTTP for everything that hasn't been migrated to PowerSync yet (creation,
/// meals, meal items, diary). Top-level [NutritionalPlan] reads as well as
/// edit/delete go through the local PowerSync-backed Drift table — see
/// [watchAllDrift], [editLocalDrift], [deleteLocalDrift].
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
  static const nutritionDiaryPath = 'nutritiondiary';
  static const ingredientWeightUnitPath = 'ingredientweightunit';

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

  Future<List<Ingredient>> searchIngredient(
    String name, {
    String languageCode = 'en',
    IngredientSearchLanguage searchLanguage = IngredientSearchLanguage.current,
    bool isVegan = false,
    bool isVegetarian = false,
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

  Future<List<IngredientWeightUnit>> fetchWeightUnits(int ingredientId) async {
    final data = await _base.fetchPaginated(
      _base.makeUrl(
        ingredientWeightUnitPath,
        query: {'ingredient': ingredientId.toString()},
      ),
    );
    return data.map((e) => IngredientWeightUnit.fromJson(e)).toList();
  }

  // --- Nutrition diary (logs) ---

  Future<List<dynamic>> fetchLogsForPlan(int planId) async {
    return _base.fetchPaginated(
      _base.makeUrl(
        nutritionDiaryPath,
        query: {
          'plan': planId.toString(),
          'limit': API_MAX_PAGE_SIZE,
          'ordering': 'datetime',
        },
      ),
    );
  }

  Future<Map<String, dynamic>> createLog(Map<String, dynamic> data) async {
    return _base.post(data, _base.makeUrl(nutritionDiaryPath));
  }

  Future<http.Response> deleteLog(int id) async {
    return _base.deleteRequest(nutritionDiaryPath, id);
  }
}
