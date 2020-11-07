import 'package:flutter/foundation.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/models/nutrition/ingredient_weight_unit.dart';

class Log {
  final int id;
  final int nutritionalPlanId;
  final DateTime date;
  final String comment;
  final Ingredient ingredient;
  final IngredientWeightUnit weightUnit;
  final double amount;

  Log({
    @required this.id,
    @required this.ingredient,
    @required this.weightUnit,
    @required this.amount,
    @required this.nutritionalPlanId,
    @required this.date,
    @required this.comment,
  });
}
