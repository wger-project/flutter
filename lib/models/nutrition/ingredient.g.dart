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
      'creation_date',
      'energy',
      'carbohydrates',
      'carbohydrates_sugar',
      'protein',
      'fat',
      'fat_saturated',
      'fibres',
      'sodium'
    ],
  );
  return Ingredient(
    id: json['id'] as int,
    code: json['code'] as String,
    name: json['name'] as String,
    creationDate: DateTime.parse(json['creation_date'] as String),
    energy: json['energy'] as int,
    carbohydrates: stringToNum(json['carbohydrates'] as String?),
    carbohydratesSugar: stringToNum(json['carbohydrates_sugar'] as String?),
    protein: stringToNum(json['protein'] as String?),
    fat: stringToNum(json['fat'] as String?),
    fatSaturated: stringToNum(json['fat_saturated'] as String?),
    fibres: stringToNum(json['fibres'] as String?),
    sodium: stringToNum(json['sodium'] as String?),
  );
}

Map<String, dynamic> _$IngredientToJson(Ingredient instance) => <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'creation_date': toDate(instance.creationDate),
      'energy': instance.energy,
      'carbohydrates': numToString(instance.carbohydrates),
      'carbohydrates_sugar': numToString(instance.carbohydratesSugar),
      'protein': numToString(instance.protein),
      'fat': numToString(instance.fat),
      'fat_saturated': numToString(instance.fatSaturated),
      'fibres': numToString(instance.fibres),
      'sodium': numToString(instance.sodium),
    };
