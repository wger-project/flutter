// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Image _$ImageFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'date', 'image'],
  );
  return Image(
    id: (json['id'] as num?)?.toInt(),
    date: DateTime.parse(json['date'] as String),
    url: json['image'] as String?,
    description: json['description'] as String? ?? '',
  );
}

Map<String, dynamic> _$ImageToJson(Image instance) => <String, dynamic>{
      'id': instance.id,
      'date': toDate(instance.date),
      'image': instance.url,
      'description': instance.description,
    };
