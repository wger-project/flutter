// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'measurement_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeasurementEntry _$MeasurementEntryFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'category', 'date', 'value', 'notes'],
  );
  return MeasurementEntry(
    id: (json['id'] as num?)?.toInt(),
    category: (json['category'] as num).toInt(),
    date: DateTime.parse(json['date'] as String),
    value: json['value'] as num,
    notes: json['notes'] as String? ?? '',
  );
}

Map<String, dynamic> _$MeasurementEntryToJson(MeasurementEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category': instance.category,
      'date': toDate(instance.date),
      'value': instance.value,
      'notes': instance.notes,
    };
