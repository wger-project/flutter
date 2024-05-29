// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IngredientImage _$IngredientImageFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'uuid',
      'ingredient_id',
      'image',
      'size',
      'license',
      'license_author',
      'license_author_url',
      'license_title',
      'license_object_url',
      'license_derivative_source_url'
    ],
  );
  return IngredientImage(
    id: (json['id'] as num).toInt(),
    uuid: json['uuid'] as String,
    ingredientId: (json['ingredient_id'] as num).toInt(),
    image: json['image'] as String,
    size: (json['size'] as num).toInt(),
    licenseId: (json['license'] as num).toInt(),
    author: json['license_author'] as String,
    authorUrl: json['license_author_url'] as String,
    title: json['license_title'] as String,
    objectUrl: json['license_object_url'] as String,
    derivativeSourceUrl: json['license_derivative_source_url'] as String,
  );
}

Map<String, dynamic> _$IngredientImageToJson(IngredientImage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uuid': instance.uuid,
      'ingredient_id': instance.ingredientId,
      'image': instance.image,
      'size': instance.size,
      'license': instance.licenseId,
      'license_author': instance.author,
      'license_author_url': instance.authorUrl,
      'license_title': instance.title,
      'license_object_url': instance.objectUrl,
      'license_derivative_source_url': instance.derivativeSourceUrl,
    };
