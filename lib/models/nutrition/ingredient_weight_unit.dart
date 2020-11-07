import 'package:flutter/foundation.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/models/nutrition/weight_unit.dart';

class IngredientWeightUnit {
  final int id;
  final Ingredient weightUnit;
  final WeightUnit ingredient;
  final int grams;
  final double amount;

  IngredientWeightUnit({
    @required this.id,
    @required this.weightUnit,
    @required this.ingredient,
    @required this.grams,
    @required this.amount,
  });
}
