// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealItem _$MealItemFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id', 'amount']);
  return MealItem(
    id: json['id'] as int?,
    mealId: json['meal'] as int?,
    ingredientId: json['ingredient'] as int,
    weightUnitId: json['weight_unit'] as int?,
    amount: toNum(json['amount'] as String?),
  );
}

Map<String, dynamic> _$MealItemToJson(MealItem instance) => <String, dynamic>{
      'id': instance.id,
      'meal': instance.mealId,
      'ingredient': instance.ingredientId,
      'weight_unit': instance.weightUnitId,
      'amount': toString(instance.amount),
    };
