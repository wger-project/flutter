// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Set _$SetFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id', 'sets', 'order', 'exercises']);
  return Set(
    id: json['id'] as int,
    sets: json['sets'] as int,
    day: json['exerciseday'] as int,
    order: json['order'] as int,
    exercises: json['exercises'],
    settings: json['settings'],
  );
}

Map<String, dynamic> _$SetToJson(Set instance) => <String, dynamic>{
      'id': instance.id,
      'sets': instance.sets,
      'exerciseday': instance.day,
      'order': instance.order,
      'exercises': instance.exercises,
      'settings': instance.settings,
    };
