// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient_weight_unit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IngredientWeightUnit _$IngredientWeightUnitFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const [
    'id',
    'weight_unit',
    'ingredient',
    'grams',
    'amount'
  ]);
  return IngredientWeightUnit(
    id: json['id'] as int,
    weightUnit: json['weight_unit'] == null
        ? null
        : WeightUnit.fromJson(json['weight_unit'] as Map<String, dynamic>),
    ingredient: json['ingredient'] == null
        ? null
        : Ingredient.fromJson(json['ingredient'] as Map<String, dynamic>),
    grams: json['grams'] as int,
    amount: (json['amount'] as num)?.toDouble(),
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
