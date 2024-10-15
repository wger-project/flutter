/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
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

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wger/core/locator.dart';
import 'package:wger/database/ingredients/ingredients_database.dart';
import 'package:wger/exceptions/http_exception.dart';
import 'package:wger/exceptions/no_such_entry_exception.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/models/exercises/ingredient_api.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/models/nutrition/ingredient_image.dart';
import 'package:wger/models/nutrition/log.dart';
import 'package:wger/models/nutrition/meal.dart';
import 'package:wger/models/nutrition/meal_item.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/providers/base_provider.dart';

class NutritionPlansProvider with ChangeNotifier {
  static const _nutritionalPlansPath = 'nutritionplan';
  static const _nutritionalPlansInfoPath = 'nutritionplaninfo';
  static const _mealPath = 'meal';
  static const _mealItemPath = 'mealitem';
  static const _ingredientInfoPath = 'ingredientinfo';
  static const _ingredientSearchPath = 'ingredient/search';
  static const _nutritionDiaryPath = 'nutritiondiary';

  final WgerBaseProvider baseProvider;
  late IngredientDatabase database;
  List<NutritionalPlan> _plans = [];
  List<Ingredient> ingredients = [];

  NutritionPlansProvider(this.baseProvider, List<NutritionalPlan> entries,
      {IngredientDatabase? database})
      : _plans = entries {
    this.database = database ?? locator<IngredientDatabase>();
  }

  List<NutritionalPlan> get items {
    return [..._plans];
  }

  /// Clears all lists
  void clear() {
    _plans = [];
    ingredients = [];
  }

  /// Returns the current active nutritional plan. At the moment this is just
  /// the latest, but this might change in the future.
  NutritionalPlan? get currentPlan {
    if (_plans.isNotEmpty) {
      return _plans.first;
    }
    return null;
  }

  NutritionalPlan findById(int id) {
    return _plans.firstWhere(
      (plan) => plan.id == id,
      orElse: () => throw const NoSuchEntryException(),
    );
  }

  Meal? findMealById(int id) {
    for (final plan in _plans) {
      try {
        final meal = plan.meals.firstWhere((plan) => plan.id == id);
        return meal;
      } on StateError {}
    }
    return null;
  }

  /// Fetches and sets all plans sparsely, i.e. only with the data on the plan
  /// object itself and no child attributes
  Future<void> fetchAndSetAllPlansSparse() async {
    final data = await baseProvider.fetchPaginated(
      baseProvider.makeUrl(_nutritionalPlansPath, query: {'limit': '1000'}),
    );
    _plans = [];
    for (final planData in data) {
      final plan = NutritionalPlan.fromJson(planData);
      _plans.add(plan);
      _plans.sort((a, b) => b.creationDate.compareTo(a.creationDate));
    }
    notifyListeners();
  }

  /// Fetches and sets all plans fully, i.e. with all corresponding child objects
  Future<void> fetchAndSetAllPlansFull() async {
    final data = await baseProvider.fetchPaginated(baseProvider.makeUrl(_nutritionalPlansPath));
    await Future.wait(data.map((e) => fetchAndSetPlanFull(e['id'])).toList());
  }

  /// Fetches and sets the given nutritional plan
  ///
  /// This method only loads the data on the nutritional plan object itself,
  /// no meals, etc.
  Future<NutritionalPlan> fetchAndSetPlanSparse(int planId) async {
    final url = baseProvider.makeUrl(_nutritionalPlansPath, id: planId);
    final planData = await baseProvider.fetch(url);
    final plan = NutritionalPlan.fromJson(planData);
    _plans.add(plan);
    _plans.sort((a, b) => b.creationDate.compareTo(a.creationDate));

    notifyListeners();
    return plan;
  }

  /// Fetches a plan fully, i.e. with all corresponding child objects
  Future<NutritionalPlan> fetchAndSetPlanFull(int planId) async {
    NutritionalPlan plan;
    try {
      plan = findById(planId);
    } on NoSuchEntryException {
      // TODO: remove this useless call, because we will fetch all details below
      plan = await fetchAndSetPlanSparse(planId);
    }

    // Plan
    final url = baseProvider.makeUrl(_nutritionalPlansInfoPath, id: planId);
    final fullPlanData = await baseProvider.fetch(url);

    // Meals
    final List<Meal> meals = [];
    for (final mealData in fullPlanData['meals']) {
      final List<MealItem> mealItems = [];
      final meal = Meal.fromJson(mealData);

      // TODO: we should add these ingredients to the ingredient cache
      for (final mealItemData in mealData['meal_items']) {
        final mealItem = MealItem.fromJson(mealItemData);

        final ingredient = Ingredient.fromJson(mealItemData['ingredient_obj']);
        if (mealItemData['image'] != null) {
          final image = IngredientImage.fromJson(mealItemData['image']);
          ingredient.image = image;
        }
        mealItem.ingredient = ingredient;
        mealItems.add(mealItem);
      }
      meal.mealItems = mealItems;
      meals.add(meal);
    }
    plan.meals = meals;

    // Logs
    await fetchAndSetLogs(plan);
    for (final meal in meals) {
      meal.diaryEntries = plan.diaryEntries.where((e) => e.mealId == meal.id).toList();
    }

    // ... and done
    notifyListeners();
    return plan;
  }

  Future<NutritionalPlan> addPlan(NutritionalPlan planData) async {
    final data = await baseProvider.post(
      planData.toJson(),
      baseProvider.makeUrl(_nutritionalPlansPath),
    );
    final plan = NutritionalPlan.fromJson(data);
    _plans.add(plan);
    _plans.sort((a, b) => b.creationDate.compareTo(a.creationDate));
    notifyListeners();
    return plan;
  }

  Future<void> editPlan(NutritionalPlan plan) async {
    await baseProvider.patch(
      plan.toJson(),
      baseProvider.makeUrl(_nutritionalPlansPath, id: plan.id),
    );
    notifyListeners();
  }

  Future<void> deletePlan(int id) async {
    final existingPlanIndex = _plans.indexWhere((element) => element.id == id);
    final existingPlan = _plans[existingPlanIndex];
    _plans.removeAt(existingPlanIndex);
    notifyListeners();

    final response = await baseProvider.deleteRequest(_nutritionalPlansPath, id);

    if (response.statusCode >= 400) {
      _plans.insert(existingPlanIndex, existingPlan);
      notifyListeners();
      throw WgerHttpException(response.body);
    }
    //existingPlan = null;
  }

  /// Adds a meal to a plan
  Future<Meal> addMeal(Meal meal, int planId) async {
    final plan = findById(planId);
    final data = await baseProvider.post(
      meal.toJson(),
      baseProvider.makeUrl(_mealPath),
    );

    meal = Meal.fromJson(data);
    plan.meals.add(meal);
    notifyListeners();

    return meal;
  }

  /// Edits an existing meal
  Future<Meal> editMeal(Meal meal) async {
    final data = await baseProvider.patch(
      meal.toJson(),
      baseProvider.makeUrl(_mealPath, id: meal.id),
    );
    meal = Meal.fromJson(data);

    notifyListeners();
    return meal;
  }

  /// Deletes a meal
  Future<void> deleteMeal(Meal meal) async {
    // Get the meal
    final plan = findById(meal.planId);
    final mealIndex = plan.meals.indexWhere((e) => e.id == meal.id);
    final existingMeal = plan.meals[mealIndex];
    plan.meals.removeAt(mealIndex);
    notifyListeners();

    // Try to delete
    final response = await baseProvider.deleteRequest(_mealPath, meal.id!);
    if (response.statusCode >= 400) {
      plan.meals.insert(mealIndex, existingMeal);
      notifyListeners();
      throw WgerHttpException(response.body);
    }
  }

  /// Adds a meal item to a meal
  Future<MealItem> addMealItem(MealItem mealItem, Meal meal) async {
    final data = await baseProvider.post(
      mealItem.toJson(),
      baseProvider.makeUrl(_mealItemPath),
    );

    mealItem = MealItem.fromJson(data);
    mealItem.ingredient = await fetchIngredient(mealItem.ingredientId);
    meal.mealItems.add(mealItem);
    notifyListeners();

    return mealItem;
  }

  /// Deletes a meal
  Future<void> deleteMealItem(MealItem mealItem) async {
    // Get the meal
    final meal = findMealById(mealItem.mealId)!;
    final mealItemIndex = meal.mealItems.indexWhere((e) => e.id == mealItem.id);
    final existingMealItem = meal.mealItems[mealItemIndex];
    meal.mealItems.removeAt(mealItemIndex);
    notifyListeners();

    // Try to delete
    final response = await baseProvider.deleteRequest(_mealItemPath, mealItem.id!);
    if (response.statusCode >= 400) {
      meal.mealItems.insert(mealItemIndex, existingMealItem);
      notifyListeners();
      throw WgerHttpException(response.body);
    }
  }

  Future<void> clearIngredientCache() async {
    await database.deleteEverything();
  }

  /// Fetch and return an ingredient
  ///
  /// If the ingredient is not known locally, it is fetched from the server
  Future<Ingredient> fetchIngredient(int ingredientId, {IngredientDatabase? database}) async {
    database ??= this.database;
    Ingredient ingredient;

    try {
      ingredient = ingredients.firstWhere((e) => e.id == ingredientId);
    } on StateError {
      final ingredientDb = await (database.select(database.ingredients)
            ..where((e) => e.id.equals(ingredientId)))
          .getSingleOrNull();

      // Try to fetch from local db
      if (ingredientDb != null) {
        ingredient = Ingredient.fromJson(jsonDecode(ingredientDb.data));
        ingredients.add(ingredient);
        log("Loaded ingredient '${ingredient.name}' from db cache");

        // Prune old entries
        if (DateTime.now()
            .isAfter(ingredientDb.lastFetched.add(const Duration(days: DAYS_TO_CACHE)))) {
          (database.delete(database.ingredients)..where((i) => i.id.equals(ingredientId))).go();
        }
      } else {
        final data = await baseProvider.fetch(
          baseProvider.makeUrl(_ingredientInfoPath, id: ingredientId),
        );
        ingredient = Ingredient.fromJson(data);
        ingredients.add(ingredient);

        database.into(database.ingredients).insert(
              IngredientsCompanion.insert(
                id: ingredientId,
                data: jsonEncode(data),
                lastFetched: DateTime.now(),
              ),
            );
        log("Saved ingredient '${ingredient.name}' to db cache");
      }
    }

    return ingredient;
  }

  /// Loads the available ingredients from the local cache
  Future<void> fetchIngredientsFromCache() async {
    final ingredientDb = await database.select(database.ingredients).get();
    log('Read ${ingredientDb.length} ingredients from db cache');
    if (ingredientDb.isNotEmpty) {
      ingredients = ingredientDb.map((e) => Ingredient.fromJson(jsonDecode(e.data))).toList();
    }
  }

  /// Searches for an ingredient
  Future<List<IngredientApiSearchEntry>> searchIngredient(
    String name, {
    String languageCode = 'en',
    bool searchEnglish = false,
  }) async {
    if (name.length <= 1) {
      return [];
    }

    final languages = [languageCode];
    if (searchEnglish && languageCode != LANGUAGE_SHORT_ENGLISH) {
      languages.add(LANGUAGE_SHORT_ENGLISH);
    }

    // Send the request
    final response = await baseProvider.fetch(
      baseProvider.makeUrl(
        _ingredientSearchPath,
        query: {'term': name, 'language': languages.join(',')},
      ),
    );

    // Process the response
    return IngredientApiSearch.fromJson(response).suggestions;
  }

  /// Searches for an ingredient with code
  Future<Ingredient?> searchIngredientWithCode(String code) async {
    if (code.isEmpty) {
      return null;
    }

    // Send the request
    final data = await baseProvider.fetch(
      baseProvider.makeUrl(_ingredientInfoPath, query: {'code': code}),
    );

    if (data['count'] == 0) {
      return null;
    }
    // TODO we should probably add it to ingredient cache.
    // TODO: we could also use the ingredient cache for code searches
    return Ingredient.fromJson(data['results'][0]);
  }

  /// Log meal to nutrition diary
  Future<void> logMealToDiary(Meal meal) async {
    for (final item in meal.mealItems) {
      final plan = findById(meal.planId);
      final Log log = Log.fromMealItem(item, plan.id!, meal.id);

      final data = await baseProvider.post(
        log.toJson(),
        baseProvider.makeUrl(_nutritionDiaryPath),
      );
      log.id = data['id'];
      plan.diaryEntries.add(log);
    }
    notifyListeners();
  }

  /// Log custom ingredient to nutrition diary
  Future<void> logIngredientToDiary(
    MealItem mealItem,
    int planId, [
    DateTime? dateTime,
  ]) async {
    final plan = findById(planId);
    mealItem.ingredient = await fetchIngredient(mealItem.ingredientId);
    final Log log = Log.fromMealItem(mealItem, plan.id!, null, dateTime);

    final data = await baseProvider.post(
      log.toJson(),
      baseProvider.makeUrl(_nutritionDiaryPath),
    );
    log.id = data['id'];
    plan.diaryEntries.add(log);
    notifyListeners();
  }

  /// Deletes a log entry
  Future<void> deleteLog(int logId, int planId) async {
    await baseProvider.deleteRequest(_nutritionDiaryPath, logId);

    final plan = findById(planId);
    plan.diaryEntries.removeWhere((element) => element.id == logId);
    notifyListeners();
  }

  /// Load nutrition diary entries for plan
  Future<void> fetchAndSetLogs(NutritionalPlan plan) async {
    final data = await baseProvider.fetchPaginated(
      baseProvider.makeUrl(
        _nutritionDiaryPath,
        query: {
          'plan': plan.id?.toString(),
          'limit': '999',
          'ordering': 'datetime',
        },
      ),
    );

    plan.diaryEntries = [];
    for (final logData in data) {
      final log = Log.fromJson(logData);
      final ingredient = await fetchIngredient(log.ingredientId);
      log.ingredient = ingredient;
      plan.diaryEntries.add(log);
    }
    notifyListeners();
  }
}
