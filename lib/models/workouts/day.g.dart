// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Day _$DayFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'training', 'description', 'day'],
  );
  return Day()
    ..id = (json['id'] as num?)?.toInt()
    ..workoutId = (json['training'] as num).toInt()
    ..description = json['description'] as String
    ..daysOfWeek =
        (json['day'] as List<dynamic>).map((e) => (e as num).toInt()).toList();
}

Map<String, dynamic> _$DayToJson(Day instance) => <String, dynamic>{
      'id': instance.id,
      'training': instance.workoutId,
      'description': instance.description,
      'day': instance.daysOfWeek,
    };
