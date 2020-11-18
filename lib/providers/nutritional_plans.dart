import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    final List<NutritionalPlan> loadedPlans = [];
    if (loadedPlans == null) {
      return;
    }

    try {
      for (final entry in extractedData['results']) {
        loadedPlans.add(NutritionalPlan.fromJson(entry));
      }

      _entries = loadedPlans;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
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
      print(plan.toJson());
      print(json.decode(response.body));
      _entries.add(NutritionalPlan.fromJson(json.decode(response.body)));
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
      //throw HttpException();
    }
    existingPlan = null;
  }
}
