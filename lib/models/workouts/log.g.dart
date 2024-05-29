// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Log _$LogFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'exercise_base',
      'workout',
      'reps',
      'repetition_unit',
      'weight',
      'weight_unit',
      'date'
    ],
  );
  return Log(
    id: (json['id'] as num?)?.toInt(),
    exerciseBaseId: (json['exercise_base'] as num).toInt(),
    workoutPlan: (json['workout'] as num).toInt(),
    reps: (json['reps'] as num).toInt(),
    rir: json['rir'] as String?,
    repetitionUnitId: (json['repetition_unit'] as num).toInt(),
    weight: stringToNum(json['weight'] as String?),
    weightUnitId: (json['weight_unit'] as num).toInt(),
    date: DateTime.parse(json['date'] as String),
  );
}

Map<String, dynamic> _$LogToJson(Log instance) => <String, dynamic>{
      'id': instance.id,
      'exercise_base': instance.exerciseBaseId,
      'workout': instance.workoutPlan,
      'reps': instance.reps,
      'rir': instance.rir,
      'repetition_unit': instance.repetitionUnitId,
      'weight': numToString(instance.weight),
      'weight_unit': instance.weightUnitId,
      'date': toDate(instance.date),
    };
