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
    carbohydrates: (json['carbohydrates'] as num)?.toDouble(),
    carbohydrates_sugar: (json['carbohydrates_sugar'] as num)?.toDouble(),
    fat: (json['fat'] as num)?.toDouble(),
    fat_saturated: (json['fat_saturated'] as num)?.toDouble(),
    fibres: (json['fibres'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$IngredientToJson(Ingredient instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'creation_date': instance.creationDate?.toIso8601String(),
      'energy': instance.energy,
      'carbohydrates': instance.carbohydrates,
      'carbohydrates_sugar': instance.carbohydrates_sugar,
      'fat': instance.fat,
      'fat_saturated': instance.fat_saturated,
      'fibres': instance.fibres,
    };
