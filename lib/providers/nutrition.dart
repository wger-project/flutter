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

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  static const _nutritionalPlansInfoPath = 'nutritionplaninfo';
  static const _mealPath = 'meal';
  static const _mealItemPath = 'mealitem';
  static const _ingredientPath = 'ingredient';
  static const _ingredientSearchPath = 'ingredient/search';
  static const _nutritionDiaryPath = 'nutritiondiary';

  List<NutritionalPlan> _plans = [];
  List<Ingredient> _ingredients = [];

  Nutrition(Auth auth, List<NutritionalPlan> entries, [http.Client client])
      : this._plans = entries,
        super(auth, client);

  List<NutritionalPlan> get items {
    return [..._plans];
  }

  /// Returns the current active nutritional plan. At the moment this is just
  /// the latest, but this might change in the future.
  NutritionalPlan get currentPlan {
    return _plans.last;
  }

  NutritionalPlan findById(int id) {
    return _plans.firstWhere((plan) => plan.id == id);
  }

  Meal findMealById(int id) {
    for (var plan in _plans) {
      var meal = plan.meals.firstWhere((plan) => plan.id == id, orElse: () {});
      if (meal != null) {
        return meal;
      }
    }
    return null;
  }

  Future<List<NutritionalPlan>> fetchAndSetPlans() async {
    final data = await fetch(makeUrl(_nutritionalPlansInfoPath));
    final List<NutritionalPlan> loadedPlans = [];
    for (final entry in data['results']) {
      loadedPlans.add(NutritionalPlan.fromJson(entry));
    }

    _plans = loadedPlans;
    notifyListeners();
    return loadedPlans;
  }

  Future<NutritionalPlan> fetchAndSetPlan(int planId) async {
    //fetchAndSet
    final data = await fetch(makeUrl(_nutritionalPlansInfoPath, id: planId.toString()));
    final plan = NutritionalPlan.fromJson(data);
    await fetchAndSetLogs(plan);

    return plan;
  }

  Future<void> addPlan(NutritionalPlan plan) async {
    final data = await add(plan.toJson(), makeUrl(_nutritionalPlansInfoPath));
    _plans.insert(0, NutritionalPlan.fromJson(data));
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
    existingPlan = null;
  }

  /// Adds a meal to a plan
  Future<Meal> addMeal(Meal meal, int planId) async {
    var plan = findById(planId);
    final data = await add(meal.toJson(), _mealPath);

    meal = Meal.fromJson(data);
    plan.meals.add(meal);
    notifyListeners();

    return meal;
  }

  /// Deletes a meal
  Future<void> deleteMeal(Meal meal) async {
    // Get the meal
    var plan = findById(meal.plan);
    final mealIndex = plan.meals.indexWhere((e) => e.id == meal.id);
    var existingMeal = plan.meals[mealIndex];
    plan.meals.removeAt(mealIndex);
    notifyListeners();

    // Try to delete
    final response = await deleteRequest(_mealPath, meal.id);
    if (response.statusCode >= 400) {
      plan.meals.insert(mealIndex, existingMeal);
      notifyListeners();
      throw WgerHttpException(response.body);
    }
    existingMeal = null;
  }

  /// Adds a meal item to a meal
  Future<MealItem> addMealItem(MealItem mealItem, int mealId) async {
    var meal = findMealById(mealId);
    final data = await add(mealItem.toJson(), makeUrl(_mealItemPath));

    mealItem = MealItem.fromJson(data);
    mealItem.ingredientObj = await fetchIngredient(mealItem.ingredientId);
    meal.mealItems.add(mealItem);
    notifyListeners();

    return mealItem;
  }

  /// Deletes a meal
  Future<void> deleteMealItem(MealItem mealItem) async {
    // Get the meal
    var meal = findMealById(mealItem.meal);
    final mealItemIndex = meal.mealItems.indexWhere((e) => e.id == mealItem.id);
    var existingMealItem = meal.mealItems[mealItemIndex];
    meal.mealItems.removeAt(mealItemIndex);
    notifyListeners();

    // Try to delete
    final response = await deleteRequest(_mealItemPath, mealItem.id);
    if (response.statusCode >= 400) {
      meal.mealItems.insert(mealItemIndex, existingMealItem);
      notifyListeners();
      throw WgerHttpException(response.body);
    }
    existingMealItem = null;
  }

  /// Fetch and return an ingredient
  ///
  /// If the ingredient is not known locally, it is fetched from the server
  Future<Ingredient> fetchIngredient(int ingredientId) async {
    var ingredient = _ingredients.firstWhere((e) => e.id == ingredientId, orElse: () => null);
    if (ingredient != null) {
      return ingredient;
    }

    // fetch and return
    final data = await fetch(makeUrl(_ingredientPath, id: ingredientId.toString()));
    ingredient = Ingredient.fromJson(data);
    _ingredients.add(ingredient);
    return ingredient;
  }

  /// Searches for an ingredient
  Future<List> searchIngredient(String name) async {
    // Send the request
    final response = await client.get(
      makeUrl(_ingredientSearchPath, query: {'term': name}),
      headers: <String, String>{
        'Authorization': 'Token ${auth.token}',
        'User-Agent': 'wger Workout Manager App',
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
      Log log = Log.fromMealItem(item);
      log.planId = findById(meal.plan).id;
      log.datetime = DateTime.now();

      await add(log.toJson(), makeUrl(_nutritionDiaryPath));
    }
    notifyListeners();
  }

  /// Log meal to nutrition diary
  Future<void> fetchAndSetLogs(NutritionalPlan plan) async {
    // TODO: update fetch to that it can use the pagination
    final data = await fetch(
        makeUrl(_nutritionDiaryPath, query: {'plan': plan.id.toString(), 'limit': '1000'}));

    for (var logData in data['results']) {
      var log = Log.fromJson(logData);
      final ingredient = await fetchIngredient(log.ingredientId);
      log.ingredientObj = ingredient;
      plan.logs.add(log);
    }
    notifyListeners();
  }
}
