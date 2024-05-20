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
    exerciseId: (json['exercise'] as num?)?.toInt(),
    alias: json['alias'] as String,
  );
}

Map<String, dynamic> _$AliasToJson(Alias instance) => <String, dynamic>{
      'id': instance.id,
      'exercise': instance.exerciseId,
      'alias': instance.alias,
    };
