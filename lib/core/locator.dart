import 'dart:developer';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:get_it/get_it.dart';
import 'package:wger/database/exercises/exercise_database.dart';
import 'package:wger/database/ingredients/ingredients_database.dart';

final locator = GetIt.asNewInstance();

class ServiceLocator {
  factory ServiceLocator() => _singleton;

  const ServiceLocator._internal();

  static const ServiceLocator _singleton = ServiceLocator._internal();

  Future<void> _initDB() async {
    ExerciseDatabase exerciseDB;
    IngredientDatabase ingredientDB;
    // final exerciseDB = ExerciseDatabase();
    // final ingredientDB = IngredientDatabase();

    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      exerciseDB = ExerciseDatabase.inMemory(NativeDatabase.memory());
      ingredientDB = IngredientDatabase.inMemory(NativeDatabase.memory());
    } else {
      exerciseDB = ExerciseDatabase();
      ingredientDB = IngredientDatabase();
    }

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
