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
      'session',
      'iteration',
      'slot_entry',
      'repetitions',
      'repetitions_target',
      'repetitions_unit',
      'weight',
      'weight_target',
      'weight_unit',
      'date',
    ],
  );
  return Log(
    id: (json['id'] as num?)?.toInt(),
    exerciseId: (json['exercise'] as num).toInt(),
    iteration: (json['iteration'] as num?)?.toInt(),
    slotEntryId: (json['slot_entry'] as num?)?.toInt(),
    routineId: (json['routine'] as num).toInt(),
    repetitions: stringToNumNull(json['repetitions'] as String?),
    repetitionsTarget: stringToNumNull(json['repetitions_target'] as String?),
    repetitionsUnitId: (json['repetitions_unit'] as num?)?.toInt() ?? REP_UNIT_REPETITIONS_ID,
    rir: stringToNumNull(json['rir'] as String?),
    rirTarget: stringToNumNull(json['rir_target'] as String?),
    weight: stringToNumNull(json['weight'] as String?),
    weightTarget: stringToNumNull(json['weight_target'] as String?),
    weightUnitId: (json['weight_unit'] as num?)?.toInt() ?? WEIGHT_UNIT_KG,
    date: utcIso8601ToLocalDate(json['date'] as String),
  )..sessionId = (json['session'] as num?)?.toInt();
}

Map<String, dynamic> _$LogToJson(Log instance) => <String, dynamic>{
  'id': instance.id,
  'exercise': instance.exerciseId,
  'routine': instance.routineId,
  'session': instance.sessionId,
  'iteration': instance.iteration,
  'slot_entry': instance.slotEntryId,
  'rir': instance.rir,
  'rir_target': instance.rirTarget,
  'repetitions': instance.repetitions,
  'repetitions_target': instance.repetitionsTarget,
  'repetitions_unit': instance.repetitionsUnitId,
  'weight': numToString(instance.weight),
  'weight_target': numToString(instance.weightTarget),
  'weight_unit': instance.weightUnitId,
  'date': dateToUtcIso8601(instance.date),
};
