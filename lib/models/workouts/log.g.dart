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
      'repetitions',
      'repetitions_target',
      'repetitions_unit',
      'weight',
      'weight_target',
      'weight_unit',
      'date'
    ],
  );
  return Log(
    id: (json['id'] as num?)?.toInt(),
    exerciseId: (json['exercise'] as num).toInt(),
    routineId: (json['routine'] as num).toInt(),
    repetitions: (json['repetitions'] as num).toInt(),
    repetitionsTarget: (json['repetitions_target'] as num?)?.toInt(),
    repetitionsUnitId: (json['repetitions_unit'] as num).toInt(),
    rir: json['rir'] as String?,
    rirTarget: json['rir_target'] as String?,
    weight: stringToNum(json['weight'] as String?),
    weightTarget: stringToNum(json['weight_target'] as String?),
    weightUnitId: (json['weight_unit'] as num).toInt(),
    date: DateTime.parse(json['date'] as String),
  );
}

Map<String, dynamic> _$LogToJson(Log instance) => <String, dynamic>{
      'id': instance.id,
      'exercise': instance.exerciseId,
      'routine': instance.routineId,
      'rir': instance.rir,
      'rir_target': instance.rirTarget,
      'repetitions': instance.repetitions,
      'repetitions_target': instance.repetitionsTarget,
      'repetitions_unit': instance.repetitionsUnitId,
      'weight': numToString(instance.weight),
      'weight_target': numToString(instance.weightTarget),
      'weight_unit': instance.weightUnitId,
      'date': dateToYYYYMMDD(instance.date),
    };
