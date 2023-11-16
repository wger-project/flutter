import 'dart:developer';

import 'package:get_it/get_it.dart';
import 'package:wger/database/exercise_DB/exercise_database.dart';

final locator = GetIt.asNewInstance();

class ServiceLocator {
  factory ServiceLocator() => _singleton;

  ServiceLocator._internal();

  static final ServiceLocator _singleton = ServiceLocator._internal();

  Future<void> _initDB() async {
    final exerciseDB = ExerciseDatabase();
    locator.registerSingleton<ExerciseDatabase>(exerciseDB);
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
