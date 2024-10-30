// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DayData _$DayDataFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['iteration', 'date', 'label'],
  );
  return DayData(
    iteration: (json['iteration'] as num).toInt(),
    date: DateTime.parse(json['date'] as String),
    label: json['label'] as String?,
    day: Day.fromJson(json['day'] as Map<String, dynamic>),
    slots: (json['slots'] as List<dynamic>)
        .map((e) => SlotData.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$DayDataToJson(DayData instance) => <String, dynamic>{
      'iteration': instance.iteration,
      'date': instance.date.toIso8601String(),
      'label': instance.label,
      'day': instance.day,
      'slots': instance.slots,
    };
