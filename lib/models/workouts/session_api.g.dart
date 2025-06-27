// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutSessionApi _$WorkoutSessionApiFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['session'],
  );
  return WorkoutSessionApi(
    session: WorkoutSession.fromJson(json['session'] as Map<String, dynamic>),
    logs: (json['logs'] as List<dynamic>?)
            ?.map((e) => Log.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
  );
}

Map<String, dynamic> _$WorkoutSessionApiToJson(WorkoutSessionApi instance) => <String, dynamic>{
      'session': instance.session,
    };
