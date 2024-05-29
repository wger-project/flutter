// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Setting _$SettingFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'set',
      'order',
      'exercise_base',
      'repetition_unit',
      'reps',
      'weight',
      'weight_unit',
      'comment',
      'rir'
    ],
  );
  return Setting(
    id: (json['id'] as num?)?.toInt(),
    setId: (json['set'] as num).toInt(),
    order: (json['order'] as num).toInt(),
    exerciseId: (json['exercise_base'] as num).toInt(),
    repetitionUnitId: (json['repetition_unit'] as num).toInt(),
    reps: (json['reps'] as num?)?.toInt(),
    weightUnitId: (json['weight_unit'] as num).toInt(),
    comment: json['comment'] as String,
    rir: json['rir'] as String?,
  )..weight = stringToNum(json['weight'] as String?);
}

Map<String, dynamic> _$SettingToJson(Setting instance) => <String, dynamic>{
      'id': instance.id,
      'set': instance.setId,
      'order': instance.order,
      'exercise_base': instance.exerciseId,
      'repetition_unit': instance.repetitionUnitId,
      'reps': instance.reps,
      'weight': numToString(instance.weight),
      'weight_unit': instance.weightUnitId,
      'comment': instance.comment,
      'rir': instance.rir,
    };
