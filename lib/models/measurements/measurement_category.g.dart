// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'measurement_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeasurementCategory _$MeasurementCategoryFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id', 'name', 'unit']);
  return MeasurementCategory(
    id: json['id'] as int,
    name: json['name'] as String,
    unit: json['unit'] as String,
  );
}

Map<String, dynamic> _$MeasurementCategoryToJson(
        MeasurementCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'unit': instance.unit,
    };
