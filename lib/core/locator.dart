import 'dart:developer';

import 'package:get_it/get_it.dart';
import 'package:wger/database/exercises/exercise_database.dart';
import 'package:wger/database/ingredients/ingredients_database.dart';

final locator = GetIt.asNewInstance();

class ServiceLocator {
  factory ServiceLocator() => _singleton;

  ServiceLocator._internal();

  static final ServiceLocator _singleton = ServiceLocator._internal();

  Future<void> _initDB() async {
    final exerciseDB = ExerciseDatabase();
    final ingredientDB = IngredientDatabase();
    locator.registerSingleton<ExerciseDatabase>(exerciseDB);
    locator.registerSingleton<IngredientDatabase>(ingredientDB);
  }

  Future<void> configure() async {
    try {
      await _initDB();
    } catch (e, _) {
      log(e.toString());
      rethrow;
    }
  }
}
