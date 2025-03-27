// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'language.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Language _$LanguageFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'short_name', 'full_name'],
  );
  return Language(
    id: (json['id'] as num).toInt(),
    shortName: json['short_name'] as String,
    fullName: json['full_name'] as String,
  );
}

Map<String, dynamic> _$LanguageToJson(Language instance) => <String, dynamic>{
      'id': instance.id,
      'short_name': instance.shortName,
      'full_name': instance.fullName,
    };
