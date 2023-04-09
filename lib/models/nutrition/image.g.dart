// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IngredientImage _$IngredientImageFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'uuid', 'ingredient_id', 'image', 'size'],
  );
  return IngredientImage(
    id: json['id'] as int,
    uuid: json['uuid'] as String,
    ingredientId: json['ingredient_id'] as String,
    image: json['image'] as String,
    size: json['size'] as int,
  );
}

Map<String, dynamic> _$IngredientImageToJson(IngredientImage instance) => <String, dynamic>{
      'id': instance.id,
      'uuid': instance.uuid,
      'ingredient_id': instance.ingredientId,
      'image': instance.image,
      'size': instance.size,
    };
