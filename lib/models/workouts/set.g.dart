// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Set _$SetFromJson(Map<String, dynamic> json) {
  $checkKeys(json,
      requiredKeys: const ['id', 'sets', 'order', 'exercises', 'settings']);
  return Set(
    id: json['id'] as int,
    sets: json['sets'] as int,
    order: json['order'] as int,
    exercises: (json['exercises'] as List)
        ?.map((e) =>
            e == null ? null : Exercise.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    settings: (json['settings'] as List)
        ?.map((e) =>
            e == null ? null : Setting.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$SetToJson(Set instance) => <String, dynamic>{
      'id': instance.id,
      'sets': instance.sets,
      'order': instance.order,
      'exercises': instance.exercises,
      'settings': instance.settings,
    };
