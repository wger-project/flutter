// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Image _$ImageFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['url']);
  return Image(
    url: json['url'] as String,
    isMain: json['is_main'] as bool ?? false,
  );
}

Map<String, dynamic> _$ImageToJson(Image instance) => <String, dynamic>{
      'url': instance.url,
      'is_main': instance.isMain,
    };
