// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Day _$DayFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id', 'description', 'training']);
  return Day(
    id: json['id'] as int,
    description: json['description'] as String,
    daysOfWeek: (json['day'] as List)?.map((e) => e as int)?.toList() ?? [],
    sets: (json['sets'] as List)
        ?.map((e) => e == null ? null : Set.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  )
    ..workoutId = json['training'] as int
    ..workout = json['workout'] == null
        ? null
        : WorkoutPlan.fromJson(json['workout'] as Map<String, dynamic>);
}

Map<String, dynamic> _$DayToJson(Day instance) => <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'day': instance.daysOfWeek,
      'sets': instance.sets,
      'training': instance.workoutId,
      'workout': instance.workout,
    };
