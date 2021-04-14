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
    id: json['id'] as int?,
    exerciseId: json['exercise'] as int,
    workoutPlan: json['workout'] as int,
    reps: json['reps'] as int,
    rir: json['rir'] as String?,
    repetitionUnitId: json['repetition_unit'] as int,
    weight: toNum(json['weight'] as String?),
    weightUnitId: json['weight_unit'] as int,
    date: DateTime.parse(json['date'] as String),
  );
}

Map<String, dynamic> _$LogToJson(Log instance) => <String, dynamic>{
      'id': instance.id,
      'exercise': instance.exerciseId,
      'workout': instance.workoutPlan,
      'reps': instance.reps,
      'rir': instance.rir,
      'repetition_unit': instance.repetitionUnitId,
      'weight': toString(instance.weight),
      'weight_unit': instance.weightUnitId,
      'date': toDate(instance.date),
    };
