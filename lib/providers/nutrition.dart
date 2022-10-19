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
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wger/exceptions/http_exception.dart';
import 'package:wger/exceptions/no_such_entry_exception.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/models/nutrition/log.dart';
import 'package:wger/models/nutrition/meal.dart';
import 'package:wger/models/nutrition/meal_item.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/providers/auth.dart';
import 'package:wger/providers/base_provider.dart';

class NutritionPlansProvider extends WgerBaseProvider with ChangeNotifier {
  static const _nutritionalPlansPath = 'nutritionplan';
  static const _nutritionalPlansInfoPath = 'nutritionplaninfo';
  static const _mealPath = 'meal';
  static const _mealItemPath = 'mealitem';
  static const _ingredientPath = 'ingredient';
  static const _ingredientSearchPath = 'ingredient/search';
  static const _nutritionDiaryPath = 'nutritiondiary';

  List<NutritionalPlan> _plans = [];
  List<Ingredient> _ingredients = [];

  NutritionPlansProvider(AuthProvider auth, List<NutritionalPlan> entries, [http.Client? client])
      : _plans = entries,
        super(auth, client);

  List<NutritionalPlan> get items {
    return [..._plans];
  }

  /// Clears all lists
  void clear() {
    _plans = [];
    _ingredients = [];
  }

  /// Returns the current active nutritional plan. At the moment this is just
  /// the latest, but this might change in the future.
  NutritionalPlan? get currentPlan {
    if (_plans.isNotEmpty) {
      return _plans.first;
    }
  }

  NutritionalPlan findById(int id) {
    return _plans.firstWhere(
      (plan) => plan.id == id,
      orElse: () => throw NoSuchEntryException(),
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
    final data = await fetch(makeUrl(_nutritionalPlansPath, query: {'limit': '1000'}));
    for (final planData in data['results']) {
      final plan = NutritionalPlan.fromJson(planData);
      _plans.add(plan);
      _plans.sort((a, b) => b.creationDate.compareTo(a.creationDate));
    }
    notifyListeners();
  }

  /// Fetches and sets all plans fully, i.e. with all corresponding child objects
  Future<void> fetchAndSetAllPlansFull() async {
    final data = await fetch(makeUrl(_nutritionalPlansPath));
    for (final entry in data['results']) {
      await fetchAndSetPlanFull(entry['id']);
    }
  }

  /// Fetches and sets the given nutritional plan
  ///
  /// This method only loads the data on the nutritional plan object itself,
  /// no meals, etc.
  Future<NutritionalPlan> fetchAndSetPlanSparse(int planId) async {
    final planData = await fetch(makeUrl(_nutritionalPlansPath, id: planId));
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
    } on NoSuchEntryException catch (e) {
      plan = await fetchAndSetPlanSparse(planId);
    }

    // Plan
    final fullPlanData = await fetch(makeUrl(_nutritionalPlansInfoPath, id: planId));

    // Meals
    final List<Meal> meals = [];
    for (final mealData in fullPlanData['meals']) {
      final List<MealItem> mealItems = [];
      final meal = Meal.fromJson(mealData);

      for (final mealItemData in mealData['meal_items']) {
        final mealItem = MealItem.fromJson(mealItemData);
        mealItem.ingredientObj = await fetchIngredient(mealItem.ingredientId);
        mealItems.add(mealItem);
      }
      meal.mealItems = mealItems;
      meals.add(meal);
    }
    plan.meals = meals;

    // Logs
    await fetchAndSetLogs(plan);

    // ... and done
    notifyListeners();
    return plan;
  }

  Future<NutritionalPlan> addPlan(NutritionalPlan planData) async {
    final data = await post(planData.toJson(), makeUrl(_nutritionalPlansPath));
    final plan = NutritionalPlan.fromJson(data);
    _plans.add(plan);
    _plans.sort((a, b) => b.creationDate.compareTo(a.creationDate));
    notifyListeners();
    return plan;
  }

  Future<void> editPlan(NutritionalPlan plan) async {
    await patch(plan.toJson(), makeUrl(_nutritionalPlansPath, id: plan.id));
    notifyListeners();
  }

  Future<void> deletePlan(int id) async {
    final existingPlanIndex = _plans.indexWhere((element) => element.id == id);
    final existingPlan = _plans[existingPlanIndex];
    _plans.removeAt(existingPlanIndex);
    notifyListeners();

    final response = await deleteRequest(_nutritionalPlansPath, id);

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
    final data = await post(meal.toJson(), makeUrl(_mealPath));

    meal = Meal.fromJson(data);
    plan.meals.add(meal);
    notifyListeners();

    return meal;
  }

  /// Edits an existing meal
  Future<Meal> editMeal(Meal meal) async {
    final data = await patch(meal.toJson(), makeUrl(_mealPath, id: meal.id));
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
    final response = await deleteRequest(_mealPath, meal.id!);
    if (response.statusCode >= 400) {
      plan.meals.insert(mealIndex, existingMeal);
      notifyListeners();
      throw WgerHttpException(response.body);
    }
  }

  /// Adds a meal item to a meal
  Future<MealItem> addMealItem(MealItem mealItem, Meal meal) async {
    final data = await post(mealItem.toJson(), makeUrl(_mealItemPath));

    mealItem = MealItem.fromJson(data);
    mealItem.ingredientObj = await fetchIngredient(mealItem.ingredientId);
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
    final response = await deleteRequest(_mealItemPath, mealItem.id!);
    if (response.statusCode >= 400) {
      meal.mealItems.insert(mealItemIndex, existingMealItem);
      notifyListeners();
      throw WgerHttpException(response.body);
    }
  }

  /// Fetch and return an ingredient
  ///
  /// If the ingredient is not known locally, it is fetched from the server
  Future<Ingredient> fetchIngredient(int ingredientId) async {
    Ingredient ingredient;

    try {
      ingredient = _ingredients.firstWhere((e) => e.id == ingredientId);
      return ingredient;

      // Get ingredient from the server and save to cache
    } on StateError {
      final data = await fetch(makeUrl(_ingredientPath, id: ingredientId));
      ingredient = Ingredient.fromJson(data);
      _ingredients.add(ingredient);

      final prefs = await SharedPreferences.getInstance();
      final ingredientData = json.decode(prefs.getString('ingredientData')!);
      ingredientData['ingredients'].add(ingredient.toJson());
      prefs.setString('ingredientData', json.encode(ingredientData));
      log("Saved ingredient '${ingredient.name}' to cache.");

      return ingredient;
    }
  }

  /// Loads the available ingredients from the local storage
  Future<void> fetchIngredientsFromCache() async {
    // Load exercises from cache, if available
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(PREFS_INGREDIENTS)) {
      final ingredientData = json.decode(prefs.getString(PREFS_INGREDIENTS)!);
      if (DateTime.parse(ingredientData['expiresIn']).isAfter(DateTime.now())) {
        ingredientData['ingredients'].forEach((e) => _ingredients.add(Ingredient.fromJson(e)));
        log("Read ${ingredientData['ingredients'].length} ingredients from cache. Valid till ${ingredientData['expiresIn']}");
        return;
      }
    }

    // Initialise an empty cache
    final ingredientData = {
      'date': DateTime.now().toIso8601String(),
      'expiresIn': DateTime.now().add(const Duration(days: DAYS_TO_CACHE)).toIso8601String(),
      'ingredients': []
    };
    prefs.setString(PREFS_INGREDIENTS, json.encode(ingredientData));
    return;
  }

  /// Searches for an ingredient
  Future<List> searchIngredient(String name, [String languageCode = 'en']) async {
    if (name.length <= 1) {
      return [];
    }

    // Send the request
    final response = await client.get(
      makeUrl(
        _ingredientSearchPath,
        query: {'term': name, 'language': languageCode},
      ),
      headers: <String, String>{
        HttpHeaders.authorizationHeader: 'Token ${auth.token}',
        HttpHeaders.userAgentHeader: auth.getAppNameHeader(),
      },
    );

    // Something wrong with our request
    if (response.statusCode >= 400) {
      throw WgerHttpException(response.body);
    }

    // Process the response
    return json.decode(utf8.decode(response.bodyBytes))['suggestions'] as List<dynamic>;
  }

  /// Searches for an ingredient with code
  Future<Ingredient?> searchIngredientWithCode(String code) async {
    if (code.isEmpty) {
      return null;
    }

    // Send the request
    final data = await fetch(
      makeUrl(
        _ingredientPath,
        query: {'code': code},
      ),
    );

    if (data["count"] == 0) {
      return null;
    } else {
      return Ingredient.fromJson(data['results'][0]);
    }
  }

  /// Log meal to nutrition diary
  Future<void> logMealToDiary(Meal meal) async {
    for (final item in meal.mealItems) {
      final plan = findById(meal.planId);
      final Log log = Log.fromMealItem(item, plan.id!, meal.id);

      final data = await post(log.toJson(), makeUrl(_nutritionDiaryPath));
      log.id = data['id'];
      plan.logs.add(log);
    }
    notifyListeners();
  }

  /// Log custom ingredient to nutrition diary
  Future<void> logIngredentToDiary(MealItem mealItem, int planId, [DateTime? dateTime]) async {
    final plan = findById(planId);
    mealItem.ingredientObj = await fetchIngredient(mealItem.ingredientId);
    final Log log = Log.fromMealItem(mealItem, plan.id!, null, dateTime);

    final data = await post(log.toJson(), makeUrl(_nutritionDiaryPath));
    log.id = data['id'];
    plan.logs.add(log);
    notifyListeners();
  }

  /// Deletes a log entry
  Future<void> deleteLog(int logId, int planId) async {
    await deleteRequest(_nutritionDiaryPath, logId);

    final plan = findById(planId);
    plan.logs.removeWhere((element) => element.id == logId);
    notifyListeners();
  }

  /// Load nutrition diary entries for plan
  Future<void> fetchAndSetLogs(NutritionalPlan plan) async {
    // TODO(x): update fetch to that it can use the pagination
    final data = await fetch(
      makeUrl(_nutritionDiaryPath, query: {'plan': plan.id.toString(), 'limit': '1000'}),
    );

    plan.logs = [];
    for (final logData in data['results']) {
      final log = Log.fromJson(logData);
      final ingredient = await fetchIngredient(log.ingredientId);
      log.ingredientObj = ingredient;
      plan.logs.add(log);
    }
    notifyListeners();
  }
}
