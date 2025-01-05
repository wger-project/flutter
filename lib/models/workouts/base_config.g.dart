// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseConfig _$BaseConfigFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'slot_entry',
      'iteration',
      'value',
      'operation',
      'step',
      'need_log_to_apply',
      'requirements'
    ],
  );
  return BaseConfig(
    id: (json['id'] as num?)?.toInt(),
    slotEntryId: (json['slot_entry'] as num).toInt(),
    iteration: (json['iteration'] as num).toInt(),
    value: stringOrIntToNum(json['value']),
    operation: json['operation'] as String,
    step: json['step'] as String,
    needLogToApply: json['need_log_to_apply'] as bool,
    requirements: json['requirements'],
  );
}

Map<String, dynamic> _$BaseConfigToJson(BaseConfig instance) => <String, dynamic>{
      'slot_entry': instance.slotEntryId,
      'iteration': instance.iteration,
      'value': instance.value,
      'operation': instance.operation,
      'step': instance.step,
      'need_log_to_apply': instance.needLogToApply,
      'requirements': instance.requirements,
    };
