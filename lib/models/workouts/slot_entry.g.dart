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
      'type',
      'exercise',
      'repetition_unit',
      'repetition_rounding',
      'reps',
      'weight',
      'weight_unit',
      'weight_rounding',
      'comment',
      'config'
    ],
  );
  return SlotEntry(
    id: (json['id'] as num?)?.toInt(),
    slotId: (json['slot'] as num).toInt(),
    order: (json['order'] as num).toInt(),
    type: json['type'] as String,
    exerciseId: (json['exercise'] as num).toInt(),
    repetitionUnitId: (json['repetition_unit'] as num).toInt(),
    repetitionRounding: json['repetition_rounding'] as num,
    reps: (json['reps'] as num?)?.toInt(),
    weightUnitId: (json['weight_unit'] as num).toInt(),
    weightRounding: json['weight_rounding'] as num,
    comment: json['comment'] as String,
  )
    ..weight = stringToNum(json['weight'] as String?)
    ..config = json['config'] as Object;
}

Map<String, dynamic> _$SlotEntryToJson(SlotEntry instance) => <String, dynamic>{
      'id': instance.id,
      'slot': instance.slotId,
      'order': instance.order,
      'type': instance.type,
      'exercise': instance.exerciseId,
      'repetition_unit': instance.repetitionUnitId,
      'repetition_rounding': instance.repetitionRounding,
      'reps': instance.reps,
      'weight': numToString(instance.weight),
      'weight_unit': instance.weightUnitId,
      'weight_rounding': instance.weightRounding,
      'comment': instance.comment,
      'config': instance.config,
    };
