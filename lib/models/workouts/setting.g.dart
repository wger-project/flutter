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
  return Setting(
    id: json['id'] as int,
    setId: json['set'] as int,
    exerciseObj: json['exerciseObj'] == null
        ? null
        : Exercise.fromJson(json['exerciseObj'] as Map<String, dynamic>),
    repetitionUnit: json['repetition_unit'] as int,
    reps: json['reps'] as int,
    weight: toNum(json['weight'] as String),
    weightUnit: json['weight_unit'] as int,
    comment: json['comment'] as String ?? '',
    repsText: json['repsText'] as String,
  )..exerciseId = json['exercise'] as int;
}

Map<String, dynamic> _$SettingToJson(Setting instance) => <String, dynamic>{
      'id': instance.id,
      'set': instance.setId,
      'exerciseObj': instance.exerciseObj,
      'exercise': instance.exerciseId,
      'repetition_unit': instance.repetitionUnit,
      'reps': instance.reps,
      'weight': toString(instance.weight),
      'weight_unit': instance.weightUnit,
      'comment': instance.comment,
      'repsText': instance.repsText,
    };
