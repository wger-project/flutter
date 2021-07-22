// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'measurement_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeasurementCategory _$MeasurementCategoryFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id', 'name', 'unit', 'measurementEntries']);
  return MeasurementCategory(
    id: json['id'] as int,
    name: json['name'] as String,
    unit: json['unit'] as String,
    measurementEntries: (json['measurementEntries'] as List<dynamic>)
        .map((e) => MeasurementEntry.fromJson(e as Map<String, dynamic>))
        .toList()
        .cast<MeasurementEntry>(),
  );
}

Map<String, dynamic> _$MeasurementToJson(MeasurementCategory instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'unit': instance.unit,
      'measurementEntries': instance.measurementEntries.map((e) => e.toJson()).toList(),
    };
