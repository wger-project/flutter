import 'package:flutter/foundation.dart';
import 'package:wger/models/nutrition/meal_item.dart';

class Meal {
  final int id;
  final DateTime time;
  final List<MealItem> mealItems;

  Meal({
    @required this.id,
    @required this.time,
    @required this.mealItems,
  });
}
