// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutPlan _$WorkoutPlanFromJson(Map<String, dynamic> json) {
  $checkKeys(json,
      requiredKeys: const ['id', 'creation_date', 'description', 'days']);
  return WorkoutPlan(
    id: json['id'] as int,
    creationDate: json['creation_date'] == null
        ? null
        : DateTime.parse(json['creation_date'] as String),
    description: json['description'] as String,
    days: (json['days'] as List)
        ?.map((e) => e == null ? null : Day.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$WorkoutPlanToJson(WorkoutPlan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'creation_date': instance.creationDate?.toIso8601String(),
      'description': instance.description,
      'days': instance.days,
    };
