/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/models/http_exception.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/models/nutrition/log.dart';
import 'package:wger/models/nutrition/meal.dart';
import 'package:wger/models/nutrition/meal_item.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/providers/auth.dart';
import 'package:wger/providers/base_provider.dart';

class Nutrition extends WgerBaseProvider with ChangeNotifier {
  static const _nutritionalPlansPath = 'nutritionplan';
  static const _mealPath = 'meal';
  static const _mealItemPath = 'mealitem';
  static const _ingredientPath = 'ingredient';
  static const _ingredientSearchPath = 'ingredient/search';
  static const _nutritionDiaryPath = 'nutritiondiary';

  List<NutritionalPlan> _plans = [];
  List<Ingredient> _ingredients = [];

  Nutrition(Auth auth, List<NutritionalPlan> entries, [http.Client? client])
      : this._plans = entries,
        super(auth, client);

  List<NutritionalPlan> get items {
    return [..._plans];
  }

  /// Returns the current active nutritional plan. At the moment this is just
  /// the latest, but this might change in the future.
  NutritionalPlan? get currentPlan {
    if (_plans.length > 0) {
      return _plans.first;
    }
  }

  NutritionalPlan findById(int id) {
    return _plans.firstWhere((plan) => plan.id == id);
  }

  Meal? findMealById(int id) {
    for (var plan in _plans) {
      var meal = plan.meals.firstWhere((plan) => plan.id == id);
      return meal;
    }
    return null;
  }

  /// Fetches and sets all nutritional plans
  Future<void> fetchAndSetAllPlans() async {
    final data = await fetch(makeUrl(_nutritionalPlansPath));
    for (final entry in data['results']) {
      await fetchAndSetPlan(entry['id']);
    }
  }

  /// Fetches and sets the given nutritional plan
  Future<NutritionalPlan> fetchAndSetPlan(int planId) async {
    // Plan
    final planData = await fetch(makeUrl(_nutritionalPlansPath, id: planId));
    final plan = NutritionalPlan.fromJson(planData);

    // Meals
    List<Meal> meals = [];
    final mealsData = await fetch(makeUrl(_mealPath, query: {'plan': planId.toString()}));
    for (final mealEntry in mealsData['results']) {
      List<MealItem> mealItems = [];
      final meal = Meal.fromJson(mealEntry);

      // Meal items
      final mealItemsData = await fetch(
        makeUrl(_mealItemPath, query: {'meal': meal.id.toString()}),
      );
      for (final mealItemEntry in mealItemsData['results']) {
        final mealItem = MealItem.fromJson(mealItemEntry);
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
    _plans.add(plan);
    _plans.sort((a, b) => b.creationDate.compareTo(a.creationDate));
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
    var existingPlan = _plans[existingPlanIndex];
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
    var plan = findById(planId);
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
    var plan = findById(meal.planId);
    final mealIndex = plan.meals.indexWhere((e) => e.id == meal.id);
    var existingMeal = plan.meals[mealIndex];
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
  Future<MealItem> addMealItem(MealItem mealItem, int mealId) async {
    var meal = findMealById(mealId)!;
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
    var meal = findMealById(mealItem.mealId)!;
    final mealItemIndex = meal.mealItems.indexWhere((e) => e.id == mealItem.id);
    var existingMealItem = meal.mealItems[mealItemIndex];
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
    } on StateError catch (e) {
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
    if (prefs.containsKey('ingredientData')) {
      final ingredientData = json.decode(prefs.getString('ingredientData')!);
      if (DateTime.parse(ingredientData['expiresIn']).isAfter(DateTime.now())) {
        ingredientData['ingredients'].forEach((e) => _ingredients.add(Ingredient.fromJson(e)));
        log("Read ${ingredientData['ingredients'].length} ingredients from cache. Valid till ${ingredientData['expiresIn']}");
        return;
      }
    }

    // Initialise an empty cache
    final ingredientData = {
      'date': DateTime.now().toIso8601String(),
      'expiresIn': DateTime.now().add(Duration(days: DAYS_TO_CACHE)).toIso8601String(),
      'ingredients': []
    };
    prefs.setString('ingredientData', json.encode(ingredientData));
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
        HttpHeaders.userAgentHeader: 'wger Workout Manager App',
      },
    );

    // Something wrong with our request
    if (response.statusCode >= 400) {
      throw WgerHttpException(response.body);
    }

    // Process the response
    return json.decode(utf8.decode(response.bodyBytes))['suggestions'] as List<dynamic>;
  }

  /// Log meal to nutrition diary
  Future<void> logMealToDiary(Meal meal) async {
    //var meal = findMealById(mealId);
    for (var item in meal.mealItems) {
      final plan = findById(meal.planId);
      Log log = Log.fromMealItem(item, plan.id!);
      //log.planId = plan.id;
      //log.datetime = DateTime.now();

      final data = await post(log.toJson(), makeUrl(_nutritionDiaryPath));
      log.id = data['id'];
      plan.logs.add(log);
    }
    notifyListeners();
  }

  /// Log meal to nutrition diary
  Future<void> fetchAndSetAllLogs() async {
    for (var plan in _plans) {
      fetchAndSetLogs(plan);
    }
  }

  /// Log meal to nutrition diary
  Future<void> fetchAndSetLogs(NutritionalPlan plan) async {
    // TODO: update fetch to that it can use the pagination
    final data = await fetch(
      makeUrl(_nutritionDiaryPath, query: {'plan': plan.id.toString(), 'limit': '1000'}),
    );

    for (var logData in data['results']) {
      var log = Log.fromJson(logData);
      final ingredient = await fetchIngredient(log.ingredientId);
      log.ingredientObj = ingredient;
      plan.logs.add(log);
    }
    notifyListeners();
  }
}
