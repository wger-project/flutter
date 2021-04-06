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
    'protein',
    'fat',
    'fat_saturated',
    'fibres',
    'sodium'
  ]);
  return Ingredient(
    id: json['id'] as int,
    name: json['name'] as String,
    creationDate: DateTime.parse(json['creation_date'] as String),
    energy: json['energy'] as int,
    carbohydrates: toNum(json['carbohydrates'] as String?),
    carbohydratesSugar: toNum(json['carbohydrates_sugar'] as String?),
    protein: toNum(json['protein'] as String?),
    fat: toNum(json['fat'] as String?),
    fatSaturated: toNum(json['fat_saturated'] as String?),
    fibres: toNum(json['fibres'] as String?),
    sodium: toNum(json['sodium'] as String?),
  );
}

Map<String, dynamic> _$IngredientToJson(Ingredient instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'creation_date': toDate(instance.creationDate),
      'energy': instance.energy,
      'carbohydrates': toString(instance.carbohydrates),
      'carbohydrates_sugar': toString(instance.carbohydratesSugar),
      'protein': toString(instance.protein),
      'fat': toString(instance.fat),
      'fat_saturated': toString(instance.fatSaturated),
      'fibres': toString(instance.fibres),
      'sodium': toString(instance.sodium),
    };
