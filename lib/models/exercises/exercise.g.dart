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
      'variations',
      'created',
      'last_update',
      'last_update_global',
      'category',
      'muscles',
      'muscles_secondary',
      'equipment'
    ],
  );
  return Exercise(
    id: (json['id'] as num?)?.toInt(),
    uuid: json['uuid'] as String?,
    created: json['created'] == null
        ? null
        : DateTime.parse(json['created'] as String),
    lastUpdate: json['last_update'] == null
        ? null
        : DateTime.parse(json['last_update'] as String),
    lastUpdateGlobal: json['last_update_global'] == null
        ? null
        : DateTime.parse(json['last_update_global'] as String),
    variationId: (json['variations'] as num?)?.toInt(),
    translations: (json['translations'] as List<dynamic>?)
        ?.map((e) => Translation.fromJson(e as Map<String, dynamic>))
        .toList(),
    category: json['categories'] == null
        ? null
        : ExerciseCategory.fromJson(json['categories'] as Map<String, dynamic>),
  )
    ..categoryId = (json['category'] as num).toInt()
    ..musclesIds = (json['muscles'] as List<dynamic>)
        .map((e) => (e as num).toInt())
        .toList()
    ..musclesSecondaryIds = (json['muscles_secondary'] as List<dynamic>)
        .map((e) => (e as num).toInt())
        .toList()
    ..equipmentIds = (json['equipment'] as List<dynamic>)
        .map((e) => (e as num).toInt())
        .toList();
}

Map<String, dynamic> _$ExerciseToJson(Exercise instance) => <String, dynamic>{
      'id': instance.id,
      'uuid': instance.uuid,
      'variations': instance.variationId,
      'created': instance.created?.toIso8601String(),
      'last_update': instance.lastUpdate?.toIso8601String(),
      'last_update_global': instance.lastUpdateGlobal?.toIso8601String(),
      'category': instance.categoryId,
      'categories': instance.category?.toJson(),
      'muscles': instance.musclesIds,
      'muscles_secondary': instance.musclesSecondaryIds,
      'musclesSecondary':
          instance.musclesSecondary.map((e) => e.toJson()).toList(),
      'equipment': instance.equipmentIds,
    };
