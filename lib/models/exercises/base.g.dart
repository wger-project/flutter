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
      'creation_date',
      'update_date',
      'category',
      'muscles',
      'muscles_secondary',
      'equipment'
    ],
  );
  return ExerciseBase(
    id: json['id'] as int,
    uuid: json['uuid'] as String,
    creationDate: DateTime.parse(json['creation_date'] as String),
    updateDate: DateTime.parse(json['update_date'] as String),
    variationId: json['variations'] as int?,
  )
    ..categoryId = json['category'] as int
    ..musclesIds =
        (json['muscles'] as List<dynamic>).map((e) => e as int).toList()
    ..musclesSecondaryIds = (json['muscles_secondary'] as List<dynamic>)
        .map((e) => e as int)
        .toList()
    ..equipmentIds =
        (json['equipment'] as List<dynamic>).map((e) => e as int).toList();
}

Map<String, dynamic> _$ExerciseBaseToJson(ExerciseBase instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uuid': instance.uuid,
      'variations': instance.variationId,
      'creation_date': instance.creationDate.toIso8601String(),
      'update_date': instance.updateDate.toIso8601String(),
      'category': instance.categoryId,
      'muscles': instance.musclesIds,
      'muscles_secondary': instance.musclesSecondaryIds,
      'equipment': instance.equipmentIds,
    };
