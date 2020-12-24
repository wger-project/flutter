// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealItem _$MealItemFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id', 'amount']);
  return MealItem(
    id: json['id'] as int,
    ingredientObj: json['ingredient_obj'] == null
        ? null
        : Ingredient.fromJson(json['ingredient_obj'] as Map<String, dynamic>),
    weightUnit: json['weight_unit'] == null
        ? null
        : IngredientWeightUnit.fromJson(
            json['weight_unit'] as Map<String, dynamic>),
    amount: toNum(json['amount'] as String),
  )
    ..ingredientId = json['ingredient'] as int
    ..meal = json['meal'] as int;
}

Map<String, dynamic> _$MealItemToJson(MealItem instance) => <String, dynamic>{
      'id': instance.id,
      'ingredient': instance.ingredientId,
      'ingredient_obj': instance.ingredientObj,
      'meal': instance.meal,
      'weight_unit': instance.weightUnit,
      'amount': toString(instance.amount),
    };
