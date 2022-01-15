// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExerciseImage _$ExerciseImageFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'uuid', 'exercise_base', 'image'],
  );
  return ExerciseImage(
    id: json['id'] as int,
    uuid: json['uuid'] as String,
    exerciseBaseId: json['exercise_base'] as int,
    url: json['image'] as String,
    isMain: json['is_main'] as bool? ?? false,
  );
}

Map<String, dynamic> _$ExerciseImageToJson(ExerciseImage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uuid': instance.uuid,
      'exercise_base': instance.exerciseBaseId,
      'image': instance.url,
      'is_main': instance.isMain,
    };
