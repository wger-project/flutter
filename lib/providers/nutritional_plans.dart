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
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/providers/auth.dart';

class NutritionalPlans with ChangeNotifier {
  static const nutritionPlansUrl = '/api/v2/nutritionplan/';

  String _url;
  Auth _auth;
  List<NutritionalPlan> _entries = [];

  NutritionalPlans(Auth auth, List<NutritionalPlan> entries) {
    this._auth = auth;
    this._entries = entries;
    this._url = auth.serverUrl + nutritionPlansUrl;
  }

  List<NutritionalPlan> get items {
    return [..._entries];
  }

  NutritionalPlan findById(int id) {
    return _entries.firstWhere((plan) => plan.id == id);
  }

  Future<void> fetchAndSetPlans() async {
    final response = await http.get(
      _url,
      headers: <String, String>{'Authorization': 'Token ${_auth.token}'},
    );

    // Something wrong with our request
    if (response.statusCode >= 400) {
      throw WgerHttpException(response.body);
    }

    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    final List<NutritionalPlan> loadedPlans = [];
    for (final entry in extractedData['results']) {
      loadedPlans.add(NutritionalPlan.fromJson(entry));
    }

    _entries = loadedPlans;
    notifyListeners();
  }

  Future<void> addPlan(NutritionalPlan plan) async {
    try {
      final response = await http.post(
        _url,
        headers: {
          'Authorization': 'Token ${_auth.token}',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(plan.toJson()),
      );

      // Something wrong with our request
      if (response.statusCode >= 400) {
        throw WgerHttpException(response.body);
      }

      _entries.insert(0, NutritionalPlan.fromJson(json.decode(response.body)));
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> deletePlan(int id) async {
    final url = '$_url$id/';
    final existingPlanIndex = _entries.indexWhere((element) => element.id == id);
    var existingPlan = _entries[existingPlanIndex];
    _entries.removeAt(existingPlanIndex);
    notifyListeners();

    final response = await http.delete(
      url,
      headers: {'Authorization': 'Token ${_auth.token}'},
    );
    if (response.statusCode >= 400) {
      _entries.insert(existingPlanIndex, existingPlan);
      notifyListeners();
      throw WgerHttpException(response.body);
    }
    existingPlan = null;
  }
}
