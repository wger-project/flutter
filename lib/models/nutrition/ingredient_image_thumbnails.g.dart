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
      'small_cropped',
      'medium',
      'medium_cropped',
      'large',
      'large_cropped',
    ],
  );
  return IngredientImageThumbnails(
    small: json['small'] as String,
    smallCropped: json['small_cropped'] as String,
    medium: json['medium'] as String,
    mediumCropped: json['medium_cropped'] as String,
    large: json['large'] as String,
    largeCropped: json['large_cropped'] as String,
  );
}

Map<String, dynamic> _$IngredientImageThumbnailsToJson(IngredientImageThumbnails instance) =>
    <String, dynamic>{
      'small': instance.small,
      'small_cropped': instance.smallCropped,
      'medium': instance.medium,
      'medium_cropped': instance.mediumCropped,
      'large': instance.large,
      'large_cropped': instance.largeCropped,
    };
