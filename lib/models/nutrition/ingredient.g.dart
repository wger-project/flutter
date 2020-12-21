// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ingredient _$IngredientFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const [
    'id',
    'name',
    'creation_date',
    'energy',
    'carbohydrates',
    'carbohydrates_sugar',
    'fat',
    'fat_saturated',
    'fibres'
  ]);
  return Ingredient(
    id: json['id'] as int,
    name: json['name'] as String,
    creationDate: json['creation_date'] == null
        ? null
        : DateTime.parse(json['creation_date'] as String),
    energy: json['energy'] as int,
    carbohydrates: toNum(json['carbohydrates'] as String),
    carbohydrates_sugar: toNum(json['carbohydrates_sugar'] as String),
    fat: toNum(json['fat'] as String),
    fat_saturated: toNum(json['fat_saturated'] as String),
    fibres: toNum(json['fibres'] as String),
  );
}

Map<String, dynamic> _$IngredientToJson(Ingredient instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'creation_date': toDate(instance.creationDate),
      'energy': instance.energy,
      'carbohydrates': toString(instance.carbohydrates),
      'carbohydrates_sugar': toString(instance.carbohydrates_sugar),
      'fat': toString(instance.fat),
      'fat_saturated': toString(instance.fat_saturated),
      'fibres': toString(instance.fibres),
    };
