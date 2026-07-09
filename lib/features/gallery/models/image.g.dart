// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GalleryImage _$GalleryImageFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id', 'date']);
  return GalleryImage(
    id: (json['id'] as num?)?.toInt(),
    date: utcIso8601ToLocalDate(json['date'] as String),
    imagePath: json['image'] as String?,
    description: json['description'] as String? ?? '',
  );
}

Map<String, dynamic> _$GalleryImageToJson(GalleryImage instance) => <String, dynamic>{
  'id': instance.id,
  'date': dateToUtcIso8601(instance.date),
  'image': instance.imagePath,
  'description': instance.description,
};
