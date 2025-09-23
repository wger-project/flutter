// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient_image_thumbnails.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IngredientImageThumbnails _$IngredientImageThumbnailsFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'small',
      'smallCropped',
      'medium',
      'mediumCropped',
      'large',
      'largeCropped'
    ],
  );
  return IngredientImageThumbnails(
    small: json['small'] as String,
    smallCropped: json['smallCropped'] as String,
    medium: json['medium'] as String,
    mediumCropped: json['mediumCropped'] as String,
    large: json['large'] as String,
    largeCropped: json['largeCropped'] as String,
  );
}

Map<String, dynamic> _$IngredientImageThumbnailsToJson(IngredientImageThumbnails instance) =>
    <String, dynamic>{
      'small': instance.small,
      'smallCropped': instance.smallCropped,
      'medium': instance.medium,
      'mediumCropped': instance.mediumCropped,
      'large': instance.large,
      'largeCropped': instance.largeCropped,
    };
