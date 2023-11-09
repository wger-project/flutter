// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Routine _$RoutineFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'creation_date', 'name', 'description'],
  );
  return Routine(
    id: json['id'] as int?,
    creationDate: DateTime.parse(json['creation_date'] as String),
    name: json['name'] as String,
    description: json['description'] as String?,
  );
}

Map<String, dynamic> _$RoutineToJson(Routine instance) => <String, dynamic>{
      'id': instance.id,
      'creation_date': instance.creationDate.toIso8601String(),
      'name': instance.name,
      'description': instance.description,
    };
