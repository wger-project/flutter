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
      'repeat',
      'requirements',
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
    requirements: json['requirements'] as Map<String, dynamic>? ?? null,
  );
}

Map<String, dynamic> _$BaseConfigToJson(BaseConfig instance) => <String, dynamic>{
  'slot_entry': instance.slotEntryId,
  'iteration': instance.iteration,
  'value': instance.value,
  'operation': instance.operation,
  'step': instance.step,
  'repeat': instance.repeat,
  'requirements': instance.requirements,
};
