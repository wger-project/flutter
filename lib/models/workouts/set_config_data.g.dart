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
      'text_repr',
      'sets',
      'max_sets',
      'weight',
      'max_weight',
      'weight_unit',
      'weight_rounding',
      'reps',
      'max_reps',
      'reps_unit',
      'reps_rounding',
      'rir',
      'max_rir',
      'rpe',
      'rest',
      'max_rest',
      'comment'
    ],
  );
  return SetConfigData(
    exerciseId: (json['exercise'] as num).toInt(),
    slotEntryId: (json['slot_entry_id'] as num).toInt(),
    type: json['type'] as String? ?? 'normal',
    nrOfSets: json['sets'] as num?,
    maxNrOfSets: json['max_sets'] as num?,
    weight: stringToNumNull(json['weight'] as String?),
    maxWeight: stringToNumNull(json['max_weight'] as String?),
    weightUnitId: (json['weight_unit'] as num?)?.toInt() ?? WEIGHT_UNIT_KG,
    weightRounding: json['weight_rounding'] == null
        ? 1.25
        : stringToNumNull(json['weight_rounding'] as String?),
    reps: stringToNumNull(json['reps'] as String?),
    maxReps: stringToNumNull(json['max_reps'] as String?),
    repsUnitId: (json['reps_unit'] as num?)?.toInt() ?? REP_UNIT_REPETITIONS_ID,
    repsRounding:
        json['reps_rounding'] == null ? 1 : stringToNumNull(json['reps_rounding'] as String?),
    rir: json['rir'] as String?,
    maxRir: json['max_rir'] as String?,
    rpe: json['rpe'] as String?,
    restTime: stringToNum(json['rest'] as String?),
    maxRestTime: stringToNum(json['max_rest'] as String?),
    comment: json['comment'] as String? ?? '',
    textRepr: json['text_repr'] as String? ?? '',
  );
}

Map<String, dynamic> _$SetConfigDataToJson(SetConfigData instance) => <String, dynamic>{
      'exercise': instance.exerciseId,
      'slot_entry_id': instance.slotEntryId,
      'type': instance.type,
      'text_repr': instance.textRepr,
      'sets': instance.nrOfSets,
      'max_sets': instance.maxNrOfSets,
      'weight': instance.weight,
      'max_weight': instance.maxWeight,
      'weight_unit': instance.weightUnitId,
      'weight_rounding': instance.weightRounding,
      'reps': instance.reps,
      'max_reps': instance.maxReps,
      'reps_unit': instance.repsUnitId,
      'reps_rounding': instance.repsRounding,
      'rir': instance.rir,
      'max_rir': instance.maxRir,
      'rpe': instance.rpe,
      'rest': instance.restTime,
      'max_rest': instance.maxRestTime,
      'comment': instance.comment,
    };
