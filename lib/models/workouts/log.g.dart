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
      'exercise',
      'routine',
      'reps',
      'repetition_unit',
      'weight',
      'weight_unit',
      'date'
    ],
  );
  return Log(
    id: (json['id'] as num?)?.toInt(),
    exerciseId: (json['exercise'] as num).toInt(),
    routineId: (json['routine'] as num).toInt(),
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
      'exercise': instance.exerciseId,
      'routine': instance.routineId,
      'reps': instance.reps,
      'rir': instance.rir,
      'repetition_unit': instance.repetitionUnitId,
      'weight': numToString(instance.weight),
      'weight_unit': instance.weightUnitId,
      'date': dateToYYYYMMDD(instance.date),
    };
