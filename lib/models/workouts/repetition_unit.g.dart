// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repetition_unit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RepetitionUnit _$RepetitionUnitFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'name'],
  );
  return RepetitionUnit(
    id: (json['id'] as num).toInt(),
    name: json['name'] as String,
  );
}

Map<String, dynamic> _$RepetitionUnitToJson(RepetitionUnit instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };
