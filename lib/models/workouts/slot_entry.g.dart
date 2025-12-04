// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slot_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SlotEntry _$SlotEntryFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'slot',
      'order',
      'comment',
      'type',
      'exercise',
      'repetition_unit',
      'repetition_rounding',
      'weight_unit',
      'weight_rounding',
      'config',
    ],
  );
  return SlotEntry(
    id: (json['id'] as num?)?.toInt(),
    slotId: (json['slot'] as num).toInt(),
    order: (json['order'] as num?)?.toInt() ?? 1,
    type:
        $enumDecodeNullable(_$SlotEntryTypeEnumMap, json['type']) ??
        SlotEntryType.normal,
    exerciseId: (json['exercise'] as num).toInt(),
    repetitionUnitId: (json['repetition_unit'] as num?)?.toInt(),
    repetitionRounding: stringToNumNull(json['repetition_rounding'] as String?),
    weightUnitId: (json['weight_unit'] as num?)?.toInt(),
    weightRounding: stringToNumNull(json['weight_rounding'] as String?),
    comment: json['comment'] as String? ?? '',
    weightConfigs:
        (json['weight_configs'] as List<dynamic>?)
            ?.map((e) => BaseConfig.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    maxWeightConfigs:
        (json['max_weight_configs'] as List<dynamic>?)
            ?.map((e) => BaseConfig.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    nrOfSetsConfigs:
        (json['set_nr_configs'] as List<dynamic>?)
            ?.map((e) => BaseConfig.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    maxNrOfSetsConfigs:
        (json['max_set_nr_configs'] as List<dynamic>?)
            ?.map((e) => BaseConfig.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    rirConfigs:
        (json['rir_configs'] as List<dynamic>?)
            ?.map((e) => BaseConfig.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    maxRirConfigs:
        (json['max_rir_configs'] as List<dynamic>?)
            ?.map((e) => BaseConfig.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    restTimeConfigs:
        (json['rest_configs'] as List<dynamic>?)
            ?.map((e) => BaseConfig.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    maxRestTimeConfigs:
        (json['max_rest_configs'] as List<dynamic>?)
            ?.map((e) => BaseConfig.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    repetitionsConfigs:
        (json['repetitions_configs'] as List<dynamic>?)
            ?.map((e) => BaseConfig.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    maxRepetitionsConfigs:
        (json['max_repetitions_configs'] as List<dynamic>?)
            ?.map((e) => BaseConfig.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
  )..config = json['config'];
}

Map<String, dynamic> _$SlotEntryToJson(SlotEntry instance) => <String, dynamic>{
  'slot': instance.slotId,
  'order': instance.order,
  'comment': instance.comment,
  'type': _$SlotEntryTypeEnumMap[instance.type]!,
  'exercise': instance.exerciseId,
  'repetition_unit': instance.repetitionUnitId,
  'repetition_rounding': instance.repetitionRounding,
  'weight_unit': instance.weightUnitId,
  'weight_rounding': instance.weightRounding,
  'config': instance.config,
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
