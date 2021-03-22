// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Setting _$SettingFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const [
    'id',
    'set',
    'exercise',
    'repetition_unit',
    'reps',
    'weight',
    'weight_unit',
    'comment'
  ]);
  return Setting()
    ..id = json['id'] as int?
    ..setId = json['set'] as int
    ..exerciseId = json['exercise'] as int
    ..repetitionUnitId = json['repetition_unit'] as int
    ..reps = json['reps'] as int
    ..weight = toNum(json['weight'] as String?)
    ..weightUnitId = json['weight_unit'] as int
    ..comment = json['comment'] as String? ?? ''
    ..rir = json['rir'] as String? ?? ''
    ..repsText = json['repsText'] as String;
}

Map<String, dynamic> _$SettingToJson(Setting instance) => <String, dynamic>{
      'id': instance.id,
      'set': instance.setId,
      'exercise': instance.exerciseId,
      'repetition_unit': instance.repetitionUnitId,
      'reps': instance.reps,
      'weight': toString(instance.weight),
      'weight_unit': instance.weightUnitId,
      'comment': instance.comment,
      'rir': instance.rir,
      'repsText': instance.repsText,
    };
