// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Set _$SetFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id', 'sets', 'order']);
  return Set()
    ..id = json['id'] as int?
    ..sets = json['sets'] as int
    ..day = json['exerciseday'] as int
    ..order = json['order'] as int
    ..exercisesObj = (json['exercisesObj'] as List<dynamic>)
        .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
        .toList()
    ..exercisesIds =
        (json['exercises'] as List<dynamic>).map((e) => e as int).toList()
    ..settings = (json['settings'] as List<dynamic>)
        .map((e) => Setting.fromJson(e as Map<String, dynamic>))
        .toList()
    ..settingsComputed = (json['settingsComputed'] as List<dynamic>)
        .map((e) => Setting.fromJson(e as Map<String, dynamic>))
        .toList();
}

Map<String, dynamic> _$SetToJson(Set instance) => <String, dynamic>{
      'id': instance.id,
      'sets': instance.sets,
      'exerciseday': instance.day,
      'order': instance.order,
      'exercisesObj': instance.exercisesObj,
      'exercises': instance.exercisesIds,
      'settings': instance.settings,
      'settingsComputed': instance.settingsComputed,
    };
