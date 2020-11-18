// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Day _$DayFromJson(Map<String, dynamic> json) {
  $checkKeys(json,
      requiredKeys: const ['id', 'description', 'days_of_week', 'sets']);
  return Day(
    id: json['id'] as int,
    description: json['description'] as String,
    daysOfWeek: (json['days_of_week'] as List)?.map((e) => e as int)?.toList(),
    sets: (json['sets'] as List)
        ?.map((e) => e == null ? null : Set.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$DayToJson(Day instance) => <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'days_of_week': instance.daysOfWeek,
      'sets': instance.sets,
    };
