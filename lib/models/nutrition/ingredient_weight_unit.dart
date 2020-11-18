import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/models/nutrition/weight_unit.dart';

part 'ingredient_weight_unit.g.dart';

@JsonSerializable()
class IngredientWeightUnit {
  @JsonKey(required: true)
  final int id;

  @JsonKey(required: true, name: 'weight_unit')
  final WeightUnit weightUnit;

  @JsonKey(required: true)
  final Ingredient ingredient;

  @JsonKey(required: true)
  final int grams;

  @JsonKey(required: true)
  final double amount;

  IngredientWeightUnit({
    @required this.id,
    @required this.weightUnit,
    @required this.ingredient,
    @required this.grams,
    @required this.amount,
  });

  // Boilerplate
  factory IngredientWeightUnit.fromJson(Map<String, dynamic> json) =>
      _$IngredientWeightUnitFromJson(json);
  Map<String, dynamic> toJson() => _$IngredientWeightUnitToJson(this);
}
