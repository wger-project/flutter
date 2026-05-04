// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_trophy_context_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContextData _$ContextDataFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'log_id',
      'date',
      'session_id',
      'exercise_id',
      'repetitions_unit_id',
      'repetitions',
      'weight_unit_id',
      'weight',
      'iteration',
      'one_rep_max_estimate',
    ],
  );
  return ContextData(
    logId: (json['log_id'] as num).toInt(),
    date: utcIso8601ToLocalDate(json['date'] as String),
    sessionId: (json['session_id'] as num).toInt(),
    exerciseId: (json['exercise_id'] as num).toInt(),
    repetitionsUnitId: (json['repetitions_unit_id'] as num).toInt(),
    repetitions: json['repetitions'] as num,
    weightUnitId: (json['weight_unit_id'] as num).toInt(),
    weight: json['weight'] as num,
    iteration: (json['iteration'] as num?)?.toInt(),
    oneRepMaxEstimate: json['one_rep_max_estimate'] as num,
  );
}

Map<String, dynamic> _$ContextDataToJson(ContextData instance) => <String, dynamic>{
  'log_id': instance.logId,
  'date': instance.date.toIso8601String(),
  'session_id': instance.sessionId,
  'exercise_id': instance.exerciseId,
  'repetitions_unit_id': instance.repetitionsUnitId,
  'repetitions': instance.repetitions,
  'weight_unit_id': instance.weightUnitId,
  'weight': instance.weight,
  'iteration': instance.iteration,
  'one_rep_max_estimate': instance.oneRepMaxEstimate,
};
