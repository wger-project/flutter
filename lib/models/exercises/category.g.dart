// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExerciseCategory _$ExerciseCategoryFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'name'],
  );
  return ExerciseCategory(
    id: json['id'] as int,
    name: json['name'] as String,
  );
}

Map<String, dynamic> _$ExerciseCategoryToJson(ExerciseCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };
