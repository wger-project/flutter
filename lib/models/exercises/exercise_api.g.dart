// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExerciseBaseData _$ExerciseBaseDataFromJson(Map<String, dynamic> json) =>
    _ExerciseBaseData(
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
      translations: (json['translations'] as List<dynamic>?)
              ?.map((e) => Translation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
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

Map<String, dynamic> _$ExerciseBaseDataToJson(_ExerciseBaseData instance) =>
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
      'translations': instance.translations,
      'images': instance.images,
      'videos': instance.videos,
      'author_history': instance.authors,
      'total_authors_history': instance.authorsGlobal,
    };

_ExerciseSearchDetails _$ExerciseSearchDetailsFromJson(
        Map<String, dynamic> json) =>
    _ExerciseSearchDetails(
      translationId: (json['id'] as num).toInt(),
      exerciseId: (json['base_id'] as num).toInt(),
      name: json['name'] as String,
      category: json['category'] as String,
      image: json['image'] as String?,
      imageThumbnail: json['image_thumbnail'] as String?,
    );

Map<String, dynamic> _$ExerciseSearchDetailsToJson(
        _ExerciseSearchDetails instance) =>
    <String, dynamic>{
      'id': instance.translationId,
      'base_id': instance.exerciseId,
      'name': instance.name,
      'category': instance.category,
      'image': instance.image,
      'image_thumbnail': instance.imageThumbnail,
    };

_ExerciseSearchEntry _$ExerciseSearchEntryFromJson(Map<String, dynamic> json) =>
    _ExerciseSearchEntry(
      value: json['value'] as String,
      data:
          ExerciseSearchDetails.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ExerciseSearchEntryToJson(
        _ExerciseSearchEntry instance) =>
    <String, dynamic>{
      'value': instance.value,
      'data': instance.data,
    };

_ExerciseApiSearch _$ExerciseApiSearchFromJson(Map<String, dynamic> json) =>
    _ExerciseApiSearch(
      suggestions: (json['suggestions'] as List<dynamic>)
          .map((e) => ExerciseSearchEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ExerciseApiSearchToJson(_ExerciseApiSearch instance) =>
    <String, dynamic>{
      'suggestions': instance.suggestions,
    };
