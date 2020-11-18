import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/models/nutrition/ingredient_weight_unit.dart';

part 'meal_item.g.dart';

@JsonSerializable()
class MealItem {
  @JsonKey(required: true)
  final int id;

  @JsonKey(required: true)
  final Ingredient ingredient;

  @JsonKey(required: true)
  final IngredientWeightUnit weightUnit;

  @JsonKey(required: true)
  final double amount;

  MealItem({
    @required this.id,
    @required this.ingredient,
    @required this.weightUnit,
    @required this.amount,
  });

  // Boilerplate
  factory MealItem.fromJson(Map<String, dynamic> json) => _$MealItemFromJson(json);
  Map<String, dynamic> toJson() => _$MealItemToJson(this);
}
