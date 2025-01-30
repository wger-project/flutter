// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alias.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Alias _$AliasFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'alias'],
  );
  return Alias(
    id: (json['id'] as num?)?.toInt(),
    translationId: (json['translation'] as num?)?.toInt(),
    alias: json['alias'] as String,
  );
}

Map<String, dynamic> _$AliasToJson(Alias instance) => <String, dynamic>{
      'id': instance.id,
      'translation': instance.translationId,
      'alias': instance.alias,
    };
