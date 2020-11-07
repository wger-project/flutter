import 'package:flutter/foundation.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/models/nutrition/ingredient_weight_unit.dart';

class MealItem {
  final int id;
  final Ingredient ingredient;
  final IngredientWeightUnit weightUnit;
  final double amount;

  MealItem({
    @required this.id,
    @required this.ingredient,
    @required this.weightUnit,
    @required this.amount,
  });
}
