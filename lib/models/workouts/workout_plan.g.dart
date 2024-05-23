// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutPlan _$WorkoutPlanFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'creation_date', 'name', 'description'],
  );
  return WorkoutPlan(
    id: (json['id'] as num?)?.toInt(),
    creationDate: DateTime.parse(json['creation_date'] as String),
    name: json['name'] as String,
    description: json['description'] as String?,
  );
}

Map<String, dynamic> _$WorkoutPlanToJson(WorkoutPlan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'creation_date': instance.creationDate.toIso8601String(),
      'name': instance.name,
      'description': instance.description,
    };
