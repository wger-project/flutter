// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise2.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Exercise2 _$Exercise2FromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const [
    'id',
    'exercise_base',
    'uuid',
    'creation_date',
    'name',
    'description'
  ]);
  return Exercise2(
    id: json['id'] as int,
    baseId: json['exercise_base'] as int,
    uuid: json['uuid'] as String,
    creationDate: DateTime.parse(json['creation_date'] as String),
    name: json['name'] as String,
    description: json['description'] as String,
  );
}

Map<String, dynamic> _$Exercise2ToJson(Exercise2 instance) => <String, dynamic>{
      'id': instance.id,
      'exercise_base': instance.baseId,
      'uuid': instance.uuid,
      'creation_date': instance.creationDate.toIso8601String(),
      'name': instance.name,
      'description': instance.description,
    };
