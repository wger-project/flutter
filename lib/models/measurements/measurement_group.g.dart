// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'measurement_group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeasurementGroup _$MeasurementGroupFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id', 'uuid', 'name']);
  return MeasurementGroup(
    id: (json['id'] as num).toInt(),
    uuid: json['uuid'] as String? ?? '',
    name: json['name'] as String,
    description: json['description'] as String? ?? '',
  );
}

Map<String, dynamic> _$MeasurementGroupToJson(MeasurementGroup instance) => <String, dynamic>{
  'id': instance.id,
  'uuid': instance.uuid,
  'name': instance.name,
  'description': instance.description,
};
