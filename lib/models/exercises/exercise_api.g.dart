// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExerciseBaseDataImpl _$$ExerciseBaseDataImplFromJson(
        Map<String, dynamic> json) =>
    _$ExerciseBaseDataImpl(
      id: (json['id'] as num).toInt(),
      uuid: json['uuid'] as String,
      variationId: (json['variations'] as num?)?.toInt() ?? null,
      created: DateTime.parse(json['created'] as String),
      lastUpdate: DateTime.parse(json['last_update'] as String),
      lastUpdateGlobal: DateTime.parse(json['last_update_global'] as String),
      category:
          ExerciseCategory.fromJson(json['category'] as Map<String, dynamic>),
      muscles: (json['muscles'] as List<dynamic>)
          .map((e) => Muscle.fromJson(e as Map<String, dynamic>))
          .toList(),
      musclesSecondary: (json['muscles_secondary'] as List<dynamic>)
          .map((e) => Muscle.fromJson(e as Map<String, dynamic>))
          .toList(),
      equipment: (json['equipment'] as List<dynamic>)
          .map((e) => Equipment.fromJson(e as Map<String, dynamic>))
          .toList(),
      translations: (json['exercises'] as List<dynamic>)
          .map((e) => Translation.fromJson(e as Map<String, dynamic>))
          .toList(),
      images: (json['images'] as List<dynamic>)
          .map((e) => ExerciseImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      videos: (json['videos'] as List<dynamic>)
          .map((e) => Video.fromJson(e as Map<String, dynamic>))
          .toList(),
      authors: (json['author_history'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      authorsGlobal: (json['total_authors_history'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$ExerciseBaseDataImplToJson(
        _$ExerciseBaseDataImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uuid': instance.uuid,
      'variations': instance.variationId,
      'created': instance.created.toIso8601String(),
      'last_update': instance.lastUpdate.toIso8601String(),
      'last_update_global': instance.lastUpdateGlobal.toIso8601String(),
      'category': instance.category,
      'muscles': instance.muscles,
      'muscles_secondary': instance.musclesSecondary,
      'equipment': instance.equipment,
      'exercises': instance.translations,
      'images': instance.images,
      'videos': instance.videos,
      'author_history': instance.authors,
      'total_authors_history': instance.authorsGlobal,
    };

_$ExerciseSearchDetailsImpl _$$ExerciseSearchDetailsImplFromJson(
        Map<String, dynamic> json) =>
    _$ExerciseSearchDetailsImpl(
      translationId: (json['id'] as num).toInt(),
      exerciseId: (json['base_id'] as num).toInt(),
      name: json['name'] as String,
      category: json['category'] as String,
      image: json['image'] as String?,
      imageThumbnail: json['image_thumbnail'] as String?,
    );

Map<String, dynamic> _$$ExerciseSearchDetailsImplToJson(
        _$ExerciseSearchDetailsImpl instance) =>
    <String, dynamic>{
      'id': instance.translationId,
      'base_id': instance.exerciseId,
      'name': instance.name,
      'category': instance.category,
      'image': instance.image,
      'image_thumbnail': instance.imageThumbnail,
    };

_$ExerciseSearchEntryImpl _$$ExerciseSearchEntryImplFromJson(
        Map<String, dynamic> json) =>
    _$ExerciseSearchEntryImpl(
      value: json['value'] as String,
      data:
          ExerciseSearchDetails.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ExerciseSearchEntryImplToJson(
        _$ExerciseSearchEntryImpl instance) =>
    <String, dynamic>{
      'value': instance.value,
      'data': instance.data,
    };

_$ExerciseApiSearchImpl _$$ExerciseApiSearchImplFromJson(
        Map<String, dynamic> json) =>
    _$ExerciseApiSearchImpl(
      suggestions: (json['suggestions'] as List<dynamic>)
          .map((e) => ExerciseSearchEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$ExerciseApiSearchImplToJson(
        _$ExerciseApiSearchImpl instance) =>
    <String, dynamic>{
      'suggestions': instance.suggestions,
    };
