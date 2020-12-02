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

  Future<void> fetchAndSetEntries({http.Client client}) async {
    if (client == null) {
      client = http.Client();
    }

    // Send the request
    final response = await client.get(
      _url,
      headers: <String, String>{'Authorization': 'Token ${_auth.token}'},
    );

    // Process the response
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    final List<WeightEntry> loadedEntries = [];
    for (final entry in extractedData['results']) {
      loadedEntries.add(WeightEntry.fromJson(entry));
    }

    _entries = loadedEntries;
    notifyListeners();
  }

  Future<WeightEntry> addEntry(WeightEntry entry, {http.Client client}) async {
    if (client == null) {
      client = http.Client();
    }

    try {
      final response = await client.post(
        _url,
        headers: {
          'Authorization': 'Token ${_auth.token}',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(entry.toJson()),
      );
      WeightEntry weightEntry = WeightEntry.fromJson(json.decode(response.body));
      _entries.insert(0, weightEntry);
      notifyListeners();
      return weightEntry;
    } catch (error) {
      log(error.toString());
      throw error;
    }
  }

  Future<void> deleteEntry(int id, {http.Client client}) async {
    if (client == null) {
      client = http.Client();
    }

    // Send the request and remove the entry from the list...
    final url = '$_url$id/';
    final existingEntryIndex = _entries.indexWhere((element) => element.id == id);
    var existingWeightEntry = _entries[existingEntryIndex];
    _entries.removeAt(existingEntryIndex);
    notifyListeners();

    final response = await client.delete(
      url,
      headers: {'Authorization': 'Token ${_auth.token}'},
    );

    // ...but it that didn't work, put it back again
    if (response.statusCode >= 400) {
      _entries.insert(existingEntryIndex, existingWeightEntry);
      notifyListeners();
      //throw HttpException();
    }
    existingWeightEntry = null;
  }
}
