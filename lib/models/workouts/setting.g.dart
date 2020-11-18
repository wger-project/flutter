// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Setting _$SettingFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const [
    'id',
    'exercise',
    'repetition_unit',
    'reps',
    'weight',
    'weight_unit',
    'comment',
    'repsText'
  ]);
  return Setting(
    id: json['id'] as int,
    exercise: json['exercise'] == null
        ? null
        : Exercise.fromJson(json['exercise'] as Map<String, dynamic>),
    repetitionUnit: json['repetition_unit'] == null
        ? null
        : RepetitionUnit.fromJson(
            json['repetition_unit'] as Map<String, dynamic>),
    reps: json['reps'] as int,
    weight: (json['weight'] as num)?.toDouble(),
    weightUnit: json['weight_unit'] == null
        ? null
        : WeightUnit.fromJson(json['weight_unit'] as Map<String, dynamic>),
    comment: json['comment'] as String,
    repsText: json['repsText'] as String,
  );
}

Map<String, dynamic> _$SettingToJson(Setting instance) => <String, dynamic>{
      'id': instance.id,
      'exercise': instance.exercise,
      'repetition_unit': instance.repetitionUnit,
      'reps': instance.reps,
      'weight': instance.weight,
      'weight_unit': instance.weightUnit,
      'comment': instance.comment,
      'repsText': instance.repsText,
    };
