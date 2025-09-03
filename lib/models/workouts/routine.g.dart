// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Routine _$RoutineFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'created', 'name', 'description', 'fit_in_week', 'start', 'end'],
  );
  return Routine(
    id: (json['id'] as num?)?.toInt(),
    created: json['created'] == null ? null : DateTime.parse(json['created'] as String),
    name: json['name'] as String,
    start: json['start'] == null ? null : DateTime.parse(json['start'] as String),
    end: json['end'] == null ? null : DateTime.parse(json['end'] as String),
    fitInWeek: json['fit_in_week'] as bool? ?? false,
    description: json['description'] as String?,
    days: (json['days'] as List<dynamic>?)
            ?.map((e) => Day.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
    sessions: (json['sessions'] as List<dynamic>?)
            ?.map((e) => WorkoutSessionApi.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
  );
}

Map<String, dynamic> _$RoutineToJson(Routine instance) => <String, dynamic>{
      'created': dateToUtcIso8601(instance.created),
      'name': instance.name,
      'description': instance.description,
      'fit_in_week': instance.fitInWeek,
      'start': dateToYYYYMMDD(instance.start),
      'end': dateToYYYYMMDD(instance.end),
    };
