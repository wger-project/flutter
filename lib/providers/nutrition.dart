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
import 'package:wger/models/nutrition/meal.dart';
import 'package:wger/models/nutrition/meal_item.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/providers/auth.dart';
import 'package:wger/providers/base_provider.dart';

class Nutrition extends WgerBaseProvider with ChangeNotifier {
  static const nutritionalPlansUrl = 'nutritionplan';
  static const nutritionalPlansInfoUrl = 'nutritionplaninfo';
  static const mealUrl = 'meal';
  static const mealItemUrl = 'mealitem';
  static const ingredientUrl = 'ingredient';
  static const ingredientSearchUrl = 'ingredient/search';

  String _url;
  Auth _auth;
  List<NutritionalPlan> _plans = [];

  Nutrition(Auth auth, List<NutritionalPlan> entries)
      : this._plans = entries,
        super(auth, nutritionalPlansUrl);

  //NutritionalPlans(Auth auth, List<NutritionalPlan> entries) {
  //  this._auth = auth;
  //  this._entries = entries;
  //  this._url = auth.serverUrl + nutritionPlansUrl;
  //}

  List<NutritionalPlan> get items {
    return [..._plans];
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

  Future<void> fetchAndSetPlans({http.Client client}) async {
    if (client == null) {
      client = http.Client();
    }

    final data = await fetch(client, makeUrl(nutritionalPlansInfoUrl));
    final List<NutritionalPlan> loadedPlans = [];
    for (final entry in data['results']) {
      loadedPlans.add(NutritionalPlan.fromJson(entry));
    }

    _plans = loadedPlans;
    notifyListeners();
  }

  Future<NutritionalPlan> fetchAndSetPlan(int planId, {http.Client client}) async {
    if (client == null) {
      client = http.Client();
    }

    String url = makeUrl('nutritionplaninfo', planId.toString());
    //fetchAndSet
    final data = await fetch(client, 'nutritionplaninfo/$planId');

    //final response = await http.get(
    //  url,
    //  headers: <String, String>{'Authorization': 'Token ${_auth.token}'},
    //);
    //final extractedData = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return NutritionalPlan.fromJson(data);
  }

  Future<void> addPlan(NutritionalPlan plan, {http.Client client}) async {
    if (client == null) {
      client = http.Client();
    }

    final data = await add(plan.toJson(), client);
    _plans.insert(0, NutritionalPlan.fromJson(data));
    notifyListeners();
  }

  Future<void> deletePlan(int id, {http.Client client}) async {
    if (client == null) {
      client = http.Client();
    }

    final existingPlanIndex = _plans.indexWhere((element) => element.id == id);
    var existingPlan = _plans[existingPlanIndex];
    _plans.removeAt(existingPlanIndex);
    notifyListeners();

    final response = await deleteRequest(nutritionalPlansUrl, id, client);

    if (response.statusCode >= 400) {
      _plans.insert(existingPlanIndex, existingPlan);
      notifyListeners();
      throw WgerHttpException(response.body);
    }
    existingPlan = null;
  }

  /// Adds a meal to a plan
  Future<Meal> addMeal(Meal meal, int planId, {http.Client client}) async {
    if (client == null) {
      client = http.Client();
    }

    var plan = findById(planId);
    final data = await add(meal.toJson(), client, mealUrl);

    meal = Meal.fromJson(data);
    plan.meals.add(meal);
    notifyListeners();

    return meal;
  }

  /// Deletes a meal
  Future<void> deleteMeal(Meal meal, {http.Client client}) async {
    if (client == null) {
      client = http.Client();
    }

    // Get the meal
    var plan = findById(meal.plan);
    final mealIndex = plan.meals.indexWhere((e) => e.id == meal.id);
    var existingMeal = plan.meals[mealIndex];
    plan.meals.removeAt(mealIndex);
    notifyListeners();

    // Try to delete
    final response = await deleteRequest(mealUrl, meal.id, client);
    if (response.statusCode >= 400) {
      plan.meals.insert(mealIndex, existingMeal);
      notifyListeners();
      throw WgerHttpException(response.body);
    }
    existingMeal = null;
  }

  /// Adds a meal item to a meal
  Future<MealItem> addMealIteam(MealItem mealItem, int mealId, {http.Client client}) async {
    if (client == null) {
      client = http.Client();
    }

    var meal = findMealById(mealId);
    final data = await add(mealItem.toJson(), client, mealItemUrl);

    mealItem = MealItem.fromJson(data);
    mealItem.ingredientObj = await fetchIngredient(mealItem.ingredientId);
    meal.mealItems.add(mealItem);
    notifyListeners();

    return mealItem;
  }

  /// Fetch and return an ingredient
  Future<Ingredient> fetchIngredient(int ingredientId, {http.Client client}) async {
    if (client == null) {
      client = http.Client();
    }

    // fetch and return
    final data = await fetch(client, makeUrl(ingredientUrl, ingredientId.toString()));
    return Ingredient.fromJson(data);
  }

  /// Searches for an ingredient
  Future<List> searchIngredient(String name, {http.Client client}) async {
    if (client == null) {
      client = http.Client();
    }

    // Send the request
    requestUrl = makeUrl(ingredientSearchUrl);
    final response = await client.get(
      requestUrl + '?term=$name',
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
}
