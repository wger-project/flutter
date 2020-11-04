import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wger/providers/workout_plan.dart';

class WorkoutPlans with ChangeNotifier {
  static const workoutPlansUrl = 'http://10.0.2.2:8000/api/v2/workout/';
  List<WorkoutPlan> _entries = [];
  final String authToken;

  WorkoutPlans(this.authToken, this._entries);

  List<WorkoutPlan> get items {
    return [..._entries];
  }

  WorkoutPlan findById(int id) {
    return _entries.firstWhere((workoutPlan) => workoutPlan.id == id);
  }

  Future<void> fetchAndSetWorkouts() async {
    final response = await http.get(
      workoutPlansUrl,
      headers: <String, String>{'Authorization': 'Token $authToken'},
    );
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    final List<WorkoutPlan> loadedWorkoutPlans = [];
    if (loadedWorkoutPlans == null) {
      return;
    }

    try {
      for (final entry in extractedData['results']) {
        loadedWorkoutPlans.add(WorkoutPlan(
          id: entry['id'],
          description: entry['comment'],
          creation_date: DateTime.parse(entry['creation_date']),
        ));
      }

      _entries = loadedWorkoutPlans;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(WorkoutPlan product) async {
    final productsUrl =
        'https://flutter-shop-a2335.firebaseio.com/products.json?auth=$authToken';
    try {
      final response = await http.post(
        productsUrl,
        body: json.encode(
          {
            'description': product.description,
          },
        ),
      );
      final newProduct = WorkoutPlan(
        id: json.decode(response.body)['name'],
        creation_date: json.decode(response.body)['creation_date'],
        description: product.description,
      );
      _entries.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, WorkoutPlan newProduct) async {
    final prodIndex = _entries.indexWhere((element) => element.id == id);
    if (prodIndex >= 0) {
      final url =
          'https://flutter-shop-a2335.firebaseio.com/products/$id.json?auth=$authToken';
      await http.patch(url,
          body: json.encode({
            'description': newProduct.description,
          }));
      _entries[prodIndex] = newProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://flutter-shop-a2335.firebaseio.com/products/$id.json?auth=$authToken';
    final existingProductIndex =
        _entries.indexWhere((element) => element.id == id);
    var existingProduct = _entries[existingProductIndex];
    _entries.removeAt(existingProductIndex);
    notifyListeners();

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _entries.insert(existingProductIndex, existingProduct);
      notifyListeners();
      //throw HttpException();
    }
    existingProduct = null;
  }
}
