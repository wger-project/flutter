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
      'repetitions',
      'max_repetitions',
      'repetitions_unit',
      'repetitions_rounding',
      'rir',
      'max_rir',
      'rpe',
      'rest',
      'max_rest',
      'comment',
    ],
  );
  return SetConfigData(
    exerciseId: (json['exercise'] as num).toInt(),
    slotEntryId: (json['slot_entry_id'] as num).toInt(),
    type: $enumDecodeNullable(_$SlotEntryTypeEnumMap, json['type']) ?? SlotEntryType.normal,
    nrOfSets: json['sets'] as num?,
    maxNrOfSets: json['max_sets'] as num?,
    weight: stringToNumNull(json['weight'] as String?),
    maxWeight: stringToNumNull(json['max_weight'] as String?),
    weightUnitId: (json['weight_unit'] as num?)?.toInt() ?? WEIGHT_UNIT_KG,
    weightRounding: stringToNumNull(json['weight_rounding'] as String?),
    repetitions: stringToNumNull(json['repetitions'] as String?),
    maxRepetitions: stringToNumNull(json['max_repetitions'] as String?),
    repetitionsUnitId: (json['repetitions_unit'] as num?)?.toInt() ?? REP_UNIT_REPETITIONS_ID,
    repetitionsRounding: stringToNumNull(
      json['repetitions_rounding'] as String?,
    ),
    rir: stringToNumNull(json['rir'] as String?),
    maxRir: stringToNumNull(json['max_rir'] as String?),
    rpe: stringToNumNull(json['rpe'] as String?),
    restTime: stringToNumNull(json['rest'] as String?),
    maxRestTime: stringToNumNull(json['max_rest'] as String?),
    comment: json['comment'] as String? ?? '',
    textRepr: json['text_repr'] as String? ?? '',
  );
}

Map<String, dynamic> _$SetConfigDataToJson(SetConfigData instance) => <String, dynamic>{
  'exercise': instance.exerciseId,
  'slot_entry_id': instance.slotEntryId,
  'type': _$SlotEntryTypeEnumMap[instance.type]!,
  'text_repr': instance.textRepr,
  'sets': instance.nrOfSets,
  'max_sets': instance.maxNrOfSets,
  'weight': instance.weight,
  'max_weight': instance.maxWeight,
  'weight_unit': instance.weightUnitId,
  'weight_rounding': instance.weightRounding,
  'repetitions': instance.repetitions,
  'max_repetitions': instance.maxRepetitions,
  'repetitions_unit': instance.repetitionsUnitId,
  'repetitions_rounding': instance.repetitionsRounding,
  'rir': instance.rir,
  'max_rir': instance.maxRir,
  'rpe': instance.rpe,
  'rest': instance.restTime,
  'max_rest': instance.maxRestTime,
  'comment': instance.comment,
};

const _$SlotEntryTypeEnumMap = {
  SlotEntryType.normal: 'normal',
  SlotEntryType.dropset: 'dropset',
  SlotEntryType.myo: 'myo',
  SlotEntryType.partial: 'partial',
  SlotEntryType.forced: 'forced',
  SlotEntryType.tut: 'tut',
  SlotEntryType.iso: 'iso',
  SlotEntryType.jump: 'jump',
};
