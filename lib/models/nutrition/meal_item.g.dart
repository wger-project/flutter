// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealItem _$MealItemFromJson(Map<String, dynamic> json) {
  $checkKeys(json,
      requiredKeys: const ['id', 'ingredient', 'weightUnit', 'amount']);
  return MealItem(
    id: json['id'] as int,
    ingredient: json['ingredient'] == null
        ? null
        : Ingredient.fromJson(json['ingredient'] as Map<String, dynamic>),
    weightUnit: json['weightUnit'] == null
        ? null
        : IngredientWeightUnit.fromJson(
            json['weightUnit'] as Map<String, dynamic>),
    amount: (json['amount'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$MealItemToJson(MealItem instance) => <String, dynamic>{
      'id': instance.id,
      'ingredient': instance.ingredient,
      'weightUnit': instance.weightUnit,
      'amount': instance.amount,
    };
