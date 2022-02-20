// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Exercise _$ExerciseFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'uuid',
      'language',
      'creation_date',
      'exercise_base',
      'name',
      'description'
    ],
  );
  return Exercise(
    id: json['id'] as int?,
    uuid: json['uuid'] as String?,
    creationDate: json['creation_date'] == null
        ? null
        : DateTime.parse(json['creation_date'] as String),
    name: json['name'] as String,
    description: json['description'] as String,
  )
    ..languageId = json['language'] as int
    ..baseId = json['exercise_base'] as int?;
}

Map<String, dynamic> _$ExerciseToJson(Exercise instance) => <String, dynamic>{
      'id': instance.id,
      'uuid': instance.uuid,
      'language': instance.languageId,
      'creation_date': instance.creationDate?.toIso8601String(),
      'exercise_base': instance.baseId,
      'name': instance.name,
      'description': instance.description,
    };
