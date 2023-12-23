// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExerciseBase _$ExerciseBaseFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'uuid',
      'variations',
      'created',
      'last_update',
      'category',
      'muscles',
      'muscles_secondary',
      'equipment'
    ],
  );
  return ExerciseBase(
    id: json['id'] as int?,
    uuid: json['uuid'] as String?,
    created: json['created'] == null ? null : DateTime.parse(json['created'] as String),
    lastUpdate: json['last_update'] == null ? null : DateTime.parse(json['last_update'] as String),
    variationId: json['variations'] as int?,
    category: json['categories'] == null
        ? null
        : ExerciseCategory.fromJson(json['categories'] as Map<String, dynamic>),
  )
    ..categoryId = json['category'] as int
    ..musclesIds = (json['muscles'] as List<dynamic>).map((e) => e as int).toList()
    ..musclesSecondaryIds =
        (json['muscles_secondary'] as List<dynamic>).map((e) => e as int).toList()
    ..equipmentIds = (json['equipment'] as List<dynamic>).map((e) => e as int).toList()
    ..translations = (json['translations'] as List<dynamic>)
        .map((e) => Translation.fromJson(e as Map<String, dynamic>))
        .toList();
}

Map<String, dynamic> _$ExerciseBaseToJson(ExerciseBase instance) => <String, dynamic>{
      'id': instance.id,
      'uuid': instance.uuid,
      'variations': instance.variationId,
      'created': instance.created?.toIso8601String(),
      'last_update': instance.lastUpdate?.toIso8601String(),
      'category': instance.categoryId,
      'categories': instance.category?.toJson(),
      'muscles': instance.musclesIds,
      'muscless': instance.muscles.map((e) => e.toJson()).toList(),
      'muscles_secondary': instance.musclesSecondaryIds,
      'musclesSecondary': instance.musclesSecondary.map((e) => e.toJson()).toList(),
      'equipment': instance.equipmentIds,
      'equipments': instance.equipment.map((e) => e.toJson()).toList(),
      'images': instance.images.map((e) => e.toJson()).toList(),
      'translations': instance.translations.map((e) => e.toJson()).toList(),
      'videos': instance.videos.map((e) => e.toJson()).toList(),
    };
