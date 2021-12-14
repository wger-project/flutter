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
      'exercise',
      'repetition_unit',
      'reps',
      'weight',
      'weight_unit',
      'comment',
      'rir'
    ],
  );
  return Setting(
    id: json['id'] as int?,
    setId: json['set'] as int,
    order: json['order'] as int,
    exerciseId: json['exercise'] as int,
    repetitionUnitId: json['repetition_unit'] as int,
    reps: json['reps'] as int?,
    weightUnitId: json['weight_unit'] as int,
    comment: json['comment'] as String,
    rir: json['rir'] as String?,
  )..weight = stringToNum(json['weight'] as String?);
}

Map<String, dynamic> _$SettingToJson(Setting instance) => <String, dynamic>{
      'id': instance.id,
      'set': instance.setId,
      'order': instance.order,
      'exercise': instance.exerciseId,
      'repetition_unit': instance.repetitionUnitId,
      'reps': instance.reps,
      'weight': numToString(instance.weight),
      'weight_unit': instance.weightUnitId,
      'comment': instance.comment,
      'rir': instance.rir,
    };
