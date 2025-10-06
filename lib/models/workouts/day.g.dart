// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Day _$DayFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'routine',
      'name',
      'description',
      'type',
      'is_rest',
      'need_logs_to_advance',
      'order',
      'config',
    ],
  );
  return Day(
    id: (json['id'] as num?)?.toInt(),
    routineId: (json['routine'] as num).toInt(),
    name: json['name'] as String,
    description: json['description'] as String? ?? '',
    isRest: json['is_rest'] as bool? ?? false,
    needLogsToAdvance: json['need_logs_to_advance'] as bool? ?? false,
    type: $enumDecodeNullable(_$DayTypeEnumMap, json['type']) ?? DayType.custom,
    order: json['order'] as num? ?? 1,
    config: json['config'],
    slots:
        (json['slots'] as List<dynamic>?)
            ?.map((e) => Slot.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
  );
}

Map<String, dynamic> _$DayToJson(Day instance) => <String, dynamic>{
  'routine': instance.routineId,
  'name': instance.name,
  'description': instance.description,
  'type': _$DayTypeEnumMap[instance.type]!,
  'is_rest': instance.isRest,
  'need_logs_to_advance': instance.needLogsToAdvance,
  'order': instance.order,
  'config': instance.config,
};

const _$DayTypeEnumMap = {
  DayType.custom: 'custom',
  DayType.enom: 'enom',
  DayType.amrap: 'amrap',
  DayType.hiit: 'hiit',
  DayType.tabata: 'tabata',
  DayType.edt: 'edt',
  DayType.rft: 'rft',
  DayType.afap: 'afap',
};
