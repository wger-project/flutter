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

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wger/models/http_exception.dart';
import 'package:wger/models/nutrition/meal.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/providers/auth.dart';
import 'package:wger/providers/base_provider.dart';

class NutritionalPlans extends WgerBaseProvider with ChangeNotifier {
  static const nutritionalPlansUrl = 'nutritionplan';
  static const nutritionalPlansInfoUrl = 'nutritionplaninfo';
  static const mealUrl = 'meal';

  String _url;
  Auth _auth;
  List<NutritionalPlan> _plans = [];

  NutritionalPlans(Auth auth, List<NutritionalPlan> entries)
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

  Future<void> fetchAndSetPlans({http.Client client}) async {
    if (client == null) {
      client = http.Client();
    }

    final data = await fetchAndSet(client, nutritionalPlansInfoUrl);
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
    final data = await fetchAndSet(client, 'nutritionplaninfo/$planId');

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
}
