// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_base_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExerciseBaseDataImpl _$$ExerciseBaseDataImplFromJson(Map<String, dynamic> json) =>
    _$ExerciseBaseDataImpl(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      created: DateTime.parse(json['created'] as String),
      lastUpdate: DateTime.parse(json['last_update'] as String),
      lastUpdateGlobal: DateTime.parse(json['last_update_global'] as String),
      category: ExerciseCategory.fromJson(json['category'] as Map<String, dynamic>),
      muscles: (json['muscles'] as List<dynamic>)
          .map((e) => Muscle.fromJson(e as Map<String, dynamic>))
          .toList(),
      musclesSecondary: (json['muscles_secondary'] as List<dynamic>)
          .map((e) => Muscle.fromJson(e as Map<String, dynamic>))
          .toList(),
      equipment: (json['equipment'] as List<dynamic>)
          .map((e) => Equipment.fromJson(e as Map<String, dynamic>))
          .toList(),
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => ExerciseData.fromJson(e as Map<String, dynamic>))
          .toList(),
      images: (json['images'] as List<dynamic>)
          .map((e) => ExerciseImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      videos: (json['videos'] as List<dynamic>)
          .map((e) => Video.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$ExerciseBaseDataImplToJson(_$ExerciseBaseDataImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uuid': instance.uuid,
      'created': instance.created.toIso8601String(),
      'last_update': instance.lastUpdate.toIso8601String(),
      'last_update_global': instance.lastUpdateGlobal.toIso8601String(),
      'category': instance.category,
      'muscles': instance.muscles,
      'muscles_secondary': instance.musclesSecondary,
      'equipment': instance.equipment,
      'exercises': instance.exercises,
      'images': instance.images,
      'videos': instance.videos,
    };
