// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutSession _$WorkoutSessionFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'routine', 'date', 'impression', 'time_start', 'time_end'],
  );
  return WorkoutSession()
    ..id = (json['id'] as num?)?.toInt()
    ..routineId = (json['routine'] as num).toInt()
    ..date = DateTime.parse(json['date'] as String)
    ..impression = stringToNum(json['impression'] as String?)
    ..notes = json['notes'] as String? ?? ''
    ..timeStart = stringToTime(json['time_start'] as String?)
    ..timeEnd = stringToTime(json['time_end'] as String?);
}

Map<String, dynamic> _$WorkoutSessionToJson(WorkoutSession instance) => <String, dynamic>{
      'id': instance.id,
      'routine': instance.routineId,
      'date': dateToYYYYMMDD(instance.date),
      'impression': numToString(instance.impression),
      'notes': instance.notes,
      'time_start': timeToString(instance.timeStart),
      'time_end': timeToString(instance.timeEnd),
    };
