// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trophy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Trophy _$TrophyFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'uuid',
      'name',
      'description',
      'image',
      'trophy_type',
      'is_hidden',
      'is_progressive',
    ],
  );
  return Trophy(
    id: (json['id'] as num).toInt(),
    uuid: json['uuid'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    image: json['image'] as String,
    type: $enumDecode(_$TrophyTypeEnumMap, json['trophy_type']),
    isHidden: json['is_hidden'] as bool,
    isProgressive: json['is_progressive'] as bool,
  );
}

Map<String, dynamic> _$TrophyToJson(Trophy instance) => <String, dynamic>{
  'id': instance.id,
  'uuid': instance.uuid,
  'name': instance.name,
  'description': instance.description,
  'image': instance.image,
  'trophy_type': _$TrophyTypeEnumMap[instance.type]!,
  'is_hidden': instance.isHidden,
  'is_progressive': instance.isProgressive,
};

const _$TrophyTypeEnumMap = {
  TrophyType.time: 'time',
  TrophyType.volume: 'volume',
  TrophyType.count: 'count',
  TrophyType.sequence: 'sequence',
  TrophyType.date: 'date',
  TrophyType.pr: 'pr',
  TrophyType.other: 'other',
};
