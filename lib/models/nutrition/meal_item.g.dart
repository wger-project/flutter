// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealItem _$MealItemFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'amount'],
  );
  return MealItem(
    id: (json['id'] as num?)?.toInt(),
    mealId: (json['meal'] as num?)?.toInt(),
    ingredientId: (json['ingredient'] as num).toInt(),
    weightUnitId: (json['weight_unit'] as num?)?.toInt(),
    amount: stringToNum(json['amount'] as String?),
  );
}

Map<String, dynamic> _$MealItemToJson(MealItem instance) => <String, dynamic>{
      'id': instance.id,
      'meal': instance.mealId,
      'ingredient': instance.ingredientId,
      'weight_unit': instance.weightUnitId,
      'amount': numToString(instance.amount),
    };
