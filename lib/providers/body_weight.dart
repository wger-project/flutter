import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wger/models/body_weight/weight_entry.dart';
import 'package:wger/providers/auth.dart';

class BodyWeight with ChangeNotifier {
  static const nutritionPlansUrl = '/api/v2/weightentry/';

  String _url;
  Auth _auth;
  List<WeightEntry> _entries = [];

  BodyWeight(Auth auth, List<WeightEntry> entries) {
    this._auth = auth;
    this._entries = entries;
    this._url = auth.serverUrl + nutritionPlansUrl;
  }

  List<WeightEntry> get items {
    return [..._entries];
  }

  WeightEntry findById(int id) {
    return _entries.firstWhere((plan) => plan.id == id);
  }

  Future<void> fetchAndSetEntries() async {
    final response = await http.get(
      _url,
      headers: <String, String>{'Authorization': 'Token ${_auth.token}'},
    );
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    final List<WeightEntry> loadedEntries = [];
    if (loadedEntries == null) {
      return;
    }

    for (final entry in extractedData['results']) {
      loadedEntries.add(WeightEntry.fromJson(entry));
    }

    _entries = loadedEntries;
    notifyListeners();
  }

  Future<void> addEntry(WeightEntry entry) async {
    try {
      final response = await http.post(
        _url,
        headers: {
          'Authorization': 'Token ${_auth.token}',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(entry.toJson()),
      );
      _entries.insert(0, WeightEntry.fromJson(json.decode(response.body)));
      notifyListeners();
    } catch (error) {
      log(error);
      throw error;
    }
  }

  Future<void> deleteEntry(int id) async {
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
