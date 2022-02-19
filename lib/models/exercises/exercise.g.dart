// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Exercise _$ExerciseFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'uuid',
      'creation_date',
      'name',
      'description',
      'category',
      'muscles',
      'muscles_secondary',
      'equipment',
      'images',
      'videos',
      'comments'
    ],
  );
  return Exercise(
    id: json['id'] as int,
    uuid: json['uuid'] as String,
    creationDate: DateTime.parse(json['creation_date'] as String),
    name: json['name'] as String,
    description: json['description'] as String,
    muscles: (json['muscles'] as List<dynamic>?)
        ?.map((e) => Muscle.fromJson(e as Map<String, dynamic>))
        .toList(),
    musclesSecondary: (json['muscles_secondary'] as List<dynamic>?)
        ?.map((e) => Muscle.fromJson(e as Map<String, dynamic>))
        .toList(),
    equipment: (json['equipment'] as List<dynamic>?)
        ?.map((e) => Equipment.fromJson(e as Map<String, dynamic>))
        .toList(),
    images: (json['images'] as List<dynamic>?)
        ?.map((e) => ExerciseImage.fromJson(e as Map<String, dynamic>))
        .toList(),
    videos: (json['videos'] as List<dynamic>?)
        ?.map((e) => Video.fromJson(e as Map<String, dynamic>))
        .toList(),
    tips: (json['comments'] as List<dynamic>?)
        ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
        .toList(),
  )..categoryObj =
      ExerciseCategory.fromJson(json['category'] as Map<String, dynamic>);
}

Map<String, dynamic> _$ExerciseToJson(Exercise instance) => <String, dynamic>{
      'id': instance.id,
      'uuid': instance.uuid,
      'creation_date': instance.creationDate.toIso8601String(),
      'name': instance.name,
      'description': instance.description,
      'category': instance.categoryObj.toJson(),
      'muscles': instance.muscles.map((e) => e.toJson()).toList(),
      'muscles_secondary':
          instance.musclesSecondary.map((e) => e.toJson()).toList(),
      'equipment': instance.equipment.map((e) => e.toJson()).toList(),
      'images': instance.images.map((e) => e.toJson()).toList(),
      'videos': instance.videos.map((e) => e.toJson()).toList(),
      'comments': instance.tips.map((e) => e.toJson()).toList(),
    };
