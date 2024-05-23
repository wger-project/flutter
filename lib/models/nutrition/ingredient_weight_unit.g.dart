// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient_weight_unit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IngredientWeightUnit _$IngredientWeightUnitFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'weight_unit', 'ingredient', 'grams', 'amount'],
  );
  return IngredientWeightUnit(
    id: (json['id'] as num).toInt(),
    weightUnit:
        WeightUnit.fromJson(json['weight_unit'] as Map<String, dynamic>),
    ingredient: Ingredient.fromJson(json['ingredient'] as Map<String, dynamic>),
    grams: (json['grams'] as num).toInt(),
    amount: (json['amount'] as num).toDouble(),
  );
}

Map<String, dynamic> _$IngredientWeightUnitToJson(
        IngredientWeightUnit instance) =>
    <String, dynamic>{
      'id': instance.id,
      'weight_unit': instance.weightUnit,
      'ingredient': instance.ingredient,
      'grams': instance.grams,
      'amount': instance.amount,
    };
