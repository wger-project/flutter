// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'measurement_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeasurementCategory _$MeasurementCategoryFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'name', 'internal_name', 'unit', 'externally_synced'],
  );
  return MeasurementCategory(
    id: (json['id'] as num?)?.toInt(),
    name: json['name'] as String,
    unit: json['unit'] as String,
    entries:
        (json['entries'] as List<dynamic>?)
            ?.map((e) => MeasurementEntry.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
    internalName: json['internal_name'] as String?,
    externallySynced: json['externally_synced'] as bool? ?? false,
  );
}

Map<String, dynamic> _$MeasurementCategoryToJson(MeasurementCategory instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'internal_name': instance.internalName,
  'unit': instance.unit,
  'externally_synced': instance.externallySynced,
  'entries': MeasurementCategory._nullValue(instance.entries),
};
