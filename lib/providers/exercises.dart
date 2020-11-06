import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/providers/auth.dart';

class Exercises with ChangeNotifier {
  static const exercisesUrl = '/api/v2/exercise/?language=1&limit=1000';

  String _url;
  List<Exercise> _entries = [];
  Auth _auth;

  Exercises(Auth auth, List<Exercise> entries) {
    this._auth = auth;
    this._entries = entries;
    this._url = auth.serverUrl + exercisesUrl;
  }

  List<Exercise> get items {
    return [..._entries];
  }

  Exercise findById(int id) {
    return _entries.firstWhere((exercise) => exercise.id == id);
  }

  Future<void> fetchAndSetExercises() async {
    final response = await http.get(
      _url,
      headers: <String, String>{'Authorization': 'Token ${_auth.token}'},
    );
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    final List<Exercise> loadedExercises = [];
    if (loadedExercises == null) {
      return;
    }

    try {
      for (final entry in extractedData['results']) {
        loadedExercises.add(Exercise(
          id: entry['id'],
          uuid: entry['uudid'],
          name: entry['name'],
          description: entry['description'],
          category: entry['category'],
          creationDate: DateTime.parse(entry['creation_date']),
          muscles: entry['muscles'],
          musclesSecondary: entry['muscles_secondary'],
          equipment: entry['equipment'],
        ));
      }

      _entries = loadedExercises;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }
}
