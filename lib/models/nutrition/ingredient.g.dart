// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ingredient _$IngredientFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'code',
      'name',
      'created',
      'energy',
      'carbohydrates',
      'carbohydrates_sugar',
      'protein',
      'fat',
      'fat_saturated',
      'fiber',
      'sodium'
    ],
  );
  return Ingredient(
    id: (json['id'] as num).toInt(),
    code: json['code'] as String?,
    name: json['name'] as String,
    created: DateTime.parse(json['created'] as String),
    energy: (json['energy'] as num).toInt(),
    carbohydrates: stringToNum(json['carbohydrates'] as String?),
    carbohydratesSugar: stringToNum(json['carbohydrates_sugar'] as String?),
    protein: stringToNum(json['protein'] as String?),
    fat: stringToNum(json['fat'] as String?),
    fatSaturated: stringToNum(json['fat_saturated'] as String?),
    fiber: stringToNum(json['fiber'] as String?),
    sodium: stringToNum(json['sodium'] as String?),
    image: json['image'] == null
        ? null
        : IngredientImage.fromJson(json['image'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$IngredientToJson(Ingredient instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'created': instance.created.toIso8601String(),
      'energy': instance.energy,
      'carbohydrates': numToString(instance.carbohydrates),
      'carbohydrates_sugar': numToString(instance.carbohydratesSugar),
      'protein': numToString(instance.protein),
      'fat': numToString(instance.fat),
      'fat_saturated': numToString(instance.fatSaturated),
      'fiber': numToString(instance.fiber),
      'sodium': numToString(instance.sodium),
      'image': instance.image,
    };
