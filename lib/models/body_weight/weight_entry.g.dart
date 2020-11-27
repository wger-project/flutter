// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeightEntry _$WeightEntryFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id', 'weight', 'date']);
  return WeightEntry(
    id: json['id'] as int,
    weight: toNum(json['weight'] as String),
    date: json['date'] == null ? null : DateTime.parse(json['date'] as String),
  );
}

Map<String, dynamic> _$WeightEntryToJson(WeightEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'weight': toString(instance.weight),
      'date': instance.date?.toIso8601String(),
    };
