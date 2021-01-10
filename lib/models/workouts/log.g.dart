// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Log _$LogFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const [
    'id',
    'exercise',
    'workout',
    'reps',
    'repetition_unit',
    'weight',
    'weight_unit',
    'date'
  ]);
  return Log(
    id: json['id'] as int,
    exercise: json['exercise'] as int,
    workoutPlan: json['workout'] as int,
    repetitionUnit: json['repetition_unit'] as int,
    reps: json['reps'] as int,
    rir: (json['rir'] as num)?.toDouble(),
    weight: toNum(json['weight'] as String),
    weightUnit: json['weight_unit'] as int,
    date: json['date'] == null ? null : DateTime.parse(json['date'] as String),
  );
}

Map<String, dynamic> _$LogToJson(Log instance) => <String, dynamic>{
      'id': instance.id,
      'exercise': instance.exercise,
      'workout': instance.workoutPlan,
      'reps': instance.reps,
      'rir': instance.rir,
      'repetition_unit': instance.repetitionUnit,
      'weight': toString(instance.weight),
      'weight_unit': instance.weightUnit,
      'date': instance.date?.toIso8601String(),
    };
