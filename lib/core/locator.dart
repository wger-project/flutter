import 'dart:developer';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:get_it/get_it.dart';
import 'package:wger/database/ingredients/ingredients_database.dart';

final locator = GetIt.asNewInstance();

class ServiceLocator {
  factory ServiceLocator() => _singleton;

  const ServiceLocator._internal();

  static const ServiceLocator _singleton = ServiceLocator._internal();

  Future<void> _initDB() async {
    IngredientDatabase ingredientDB;

    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      ingredientDB = IngredientDatabase.inMemory(NativeDatabase.memory());
    } else {
      ingredientDB = IngredientDatabase();
    }

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
