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
      'repeat',
      'requirements'
    ],
  );
  return BaseConfig(
    id: (json['id'] as num?)?.toInt(),
    slotEntryId: (json['slot_entry'] as num).toInt(),
    iteration: (json['iteration'] as num).toInt(),
    repeat: json['repeat'] as bool? ?? false,
    value: stringOrIntToNum(json['value']),
    operation: json['operation'] as String? ?? 'r',
    step: json['step'] as String? ?? 'abs',
    needLogToApply: json['need_log_to_apply'] as bool? ?? false,
    requirements: json['requirements'] ?? null,
  );
}

Map<String, dynamic> _$BaseConfigToJson(BaseConfig instance) => <String, dynamic>{
      'slot_entry': instance.slotEntryId,
      'iteration': instance.iteration,
      'value': instance.value,
      'operation': instance.operation,
      'step': instance.step,
      'need_log_to_apply': instance.needLogToApply,
      'repeat': instance.repeat,
      'requirements': instance.requirements,
    };
