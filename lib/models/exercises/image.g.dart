// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExerciseImage _$ExerciseImageFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'uuid', 'exercise', 'image'],
  );
  return ExerciseImage(
    id: (json['id'] as num).toInt(),
    uuid: json['uuid'] as String,
    exerciseId: (json['exercise'] as num).toInt(),
    url: json['image'] as String,
    isMain: json['is_main'] as bool? ?? false,
  );
}

Map<String, dynamic> _$ExerciseImageToJson(ExerciseImage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uuid': instance.uuid,
      'exercise': instance.exerciseId,
      'image': instance.url,
      'is_main': instance.isMain,
    };
