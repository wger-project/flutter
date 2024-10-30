// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_config_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetConfigData _$SetConfigDataFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'exercise',
      'slot_entry_id',
      'type',
      'sets',
      'weight',
      'max_weight',
      'weight_unit',
      'weight_rounding',
      'reps',
      'max_reps',
      'reps_unit',
      'reps_rounding',
      'rir',
      'rpe',
      'rest',
      'max_rest',
      'comment'
    ],
  );
  return SetConfigData(
    exerciseId: (json['exercise'] as num).toInt(),
    slotEntryId: (json['slot_entry_id'] as num).toInt(),
    type: json['type'] as String,
    weight: stringToNumNull(json['weight'] as String?),
    weightUnitId: (json['weight_unit'] as num?)?.toInt(),
    weightRounding: stringToNumNull(json['weight_rounding'] as String?),
    reps: stringToNumNull(json['reps'] as String?),
    maxReps: stringToNumNull(json['max_reps'] as String?),
    repsUnitId: (json['reps_unit'] as num?)?.toInt(),
    repsRounding: stringToNumNull(json['reps_rounding'] as String?),
    rir: json['rir'] as String?,
    rpe: json['rpe'] as String?,
    restTime: stringToNum(json['rest'] as String?),
    maxRestTime: stringToNum(json['max_rest'] as String?),
    comment: json['comment'] as String,
  )
    ..nrOfSets = json['sets'] as num?
    ..maxWeight = stringToNumNull(json['max_weight'] as String?);
}

Map<String, dynamic> _$SetConfigDataToJson(SetConfigData instance) => <String, dynamic>{
      'exercise': instance.exerciseId,
      'slot_entry_id': instance.slotEntryId,
      'type': instance.type,
      'sets': instance.nrOfSets,
      'weight': instance.weight,
      'max_weight': instance.maxWeight,
      'weight_unit': instance.weightUnitId,
      'weight_rounding': instance.weightRounding,
      'reps': instance.reps,
      'max_reps': instance.maxReps,
      'reps_unit': instance.repsUnitId,
      'reps_rounding': instance.repsRounding,
      'rir': instance.rir,
      'rpe': instance.rpe,
      'rest': instance.restTime,
      'max_rest': instance.maxRestTime,
      'comment': instance.comment,
    };
