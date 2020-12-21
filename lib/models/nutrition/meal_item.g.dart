// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealItem _$MealItemFromJson(Map<String, dynamic> json) {
  $checkKeys(json,
      requiredKeys: const ['id', 'ingredient', 'weight_unit', 'amount']);
  return MealItem(
    id: json['id'] as int,
    ingredient: json['ingredient'] == null
        ? null
        : Ingredient.fromJson(json['ingredient'] as Map<String, dynamic>),
    weightUnit: json['weight_unit'] == null
        ? null
        : IngredientWeightUnit.fromJson(
            json['weight_unit'] as Map<String, dynamic>),
    amount: toNum(json['amount'] as String),
  );
}

Map<String, dynamic> _$MealItemToJson(MealItem instance) => <String, dynamic>{
      'id': instance.id,
      'ingredient': instance.ingredient,
      'weight_unit': instance.weightUnit,
      'amount': toString(instance.amount),
    };
