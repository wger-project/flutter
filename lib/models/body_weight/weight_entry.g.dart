// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeightEntry _$WeightEntryFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'weight', 'date'],
  );
  return WeightEntry(
    id: (json['id'] as num?)?.toInt(),
    weight: stringToNum(json['weight'] as String?),
    date: json['date'] == null ? null : DateTime.parse(json['date'] as String),
  );
}

Map<String, dynamic> _$WeightEntryToJson(WeightEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'weight': numToString(instance.weight),
      'date': toDate(instance.date),
    };
