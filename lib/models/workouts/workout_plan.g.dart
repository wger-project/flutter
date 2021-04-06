// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutPlan _$WorkoutPlanFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id', 'creation_date', 'comment']);
  return WorkoutPlan(
    id: json['id'] as int?,
    creationDate: DateTime.parse(json['creation_date'] as String),
    description: json['comment'] as String,
  );
}

Map<String, dynamic> _$WorkoutPlanToJson(WorkoutPlan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'creation_date': instance.creationDate.toIso8601String(),
      'comment': instance.description,
    };
