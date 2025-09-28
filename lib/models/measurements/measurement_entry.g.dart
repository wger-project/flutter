// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'measurement_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeasurementEntry _$MeasurementEntryFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'uuid',
      'source',
      'category',
      'created',
      'date',
      'value',
      'notes',
    ],
  );
  return MeasurementEntry(
    id: (json['id'] as num?)?.toInt(),
    category: (json['category'] as num).toInt(),
    date: DateTime.parse(json['date'] as String),
    value: json['value'] as num,
    notes: json['notes'] as String? ?? '',
    created: json['created'] == null
        ? null
        : DateTime.parse(json['created'] as String),
    source: json['source'] as String?,
    uuid: json['uuid'] as String?,
  );
}

Map<String, dynamic> _$MeasurementEntryToJson(MeasurementEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uuid': instance.uuid,
      'source': instance.source,
      'category': instance.category,
      'created': instance.created.toIso8601String(),
      'date': instance.date.toIso8601String(),
      'value': instance.value,
      'notes': instance.notes,
    };
