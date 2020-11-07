import 'package:flutter/foundation.dart';
import 'package:wger/models/nutrition/meal.dart';

class NutritionalPlan {
  final int id;
  final String description;
  final DateTime date;
  final List<Meal> meals;

  NutritionalPlan({
    @required this.id,
    @required this.description,
    @required this.date,
    @required this.meals,
  });
}
