// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutSession _$WorkoutSessionFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'routine', 'day', 'date', 'impression', 'time_start', 'time_end'],
  );
  return WorkoutSession(
    id: (json['id'] as num?)?.toInt(),
    dayId: (json['day'] as num?)?.toInt(),
    routineId: (json['routine'] as num).toInt(),
    impression: json['impression'] == null ? 2 : int.parse(json['impression'] as String),
    notes: json['notes'] as String? ?? '',
    timeStart: stringToTimeNull(json['time_start'] as String?),
    timeEnd: stringToTimeNull(json['time_end'] as String?),
    logs: (json['logs'] as List<dynamic>?)
            ?.map((e) => Log.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    date: json['date'] == null ? null : DateTime.parse(json['date'] as String),
  );
}

Map<String, dynamic> _$WorkoutSessionToJson(WorkoutSession instance) => <String, dynamic>{
      'id': instance.id,
      'routine': instance.routineId,
      'day': instance.dayId,
      'date': dateToYYYYMMDD(instance.date),
      'impression': numToString(instance.impression),
      'notes': instance.notes,
      'time_start': timeToString(instance.timeStart),
      'time_end': timeToString(instance.timeEnd),
    };
