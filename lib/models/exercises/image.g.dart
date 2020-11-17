// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExerciseImage _$ExerciseImageFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['image']);
  return ExerciseImage(
    url: json['image'] as String,
    isMain: json['is_main'] as bool ?? false,
  );
}

Map<String, dynamic> _$ExerciseImageToJson(ExerciseImage instance) =>
    <String, dynamic>{
      'image': instance.url,
      'is_main': instance.isMain,
    };
