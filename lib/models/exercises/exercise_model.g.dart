// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExerciseDataImpl _$$ExerciseDataImplFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['exercise_base'],
  );
  return _$ExerciseDataImpl(
    id: json['id'] as int,
    uuid: json['uuid'] as String,
    languageId: json['language'] as int,
    baseId: json['exercise_base'] as int,
    description: json['description'] as String,
    name: json['name'] as String,
    aliases: (json['aliases'] as List<dynamic>)
        .map((e) => Alias.fromJson(e as Map<String, dynamic>))
        .toList(),
    notes: (json['notes'] as List<dynamic>)
        .map((e) => Comment.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$$ExerciseDataImplToJson(_$ExerciseDataImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uuid': instance.uuid,
      'language': instance.languageId,
      'exercise_base': instance.baseId,
      'description': instance.description,
      'name': instance.name,
      'aliases': instance.aliases,
      'notes': instance.notes,
    };
