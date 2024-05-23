// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_unit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeightUnit _$WeightUnitFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'name'],
  );
  return WeightUnit(
    id: (json['id'] as num).toInt(),
    name: json['name'] as String,
  );
}

Map<String, dynamic> _$WeightUnitToJson(WeightUnit instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };
