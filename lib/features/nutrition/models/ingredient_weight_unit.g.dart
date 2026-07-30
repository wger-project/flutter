// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient_weight_unit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IngredientWeightUnit _$IngredientWeightUnitFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'uuid', 'ingredient', 'name', 'gram'],
  );
  return IngredientWeightUnit(
    id: (json['id'] as num).toInt(),
    uuid: json['uuid'] as String,
    ingredientId: (json['ingredient'] as num).toInt(),
    name: json['name'] as String,
    grams: (json['gram'] as num).toInt(),
  );
}

Map<String, dynamic> _$IngredientWeightUnitToJson(
  IngredientWeightUnit instance,
) => <String, dynamic>{
  'id': instance.id,
  'uuid': instance.uuid,
  'ingredient': instance.ingredientId,
  'name': instance.name,
  'gram': instance.grams,
};
