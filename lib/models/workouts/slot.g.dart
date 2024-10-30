// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Slot _$SlotFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'order', 'comment', 'config'],
  );
  return Slot(
    id: (json['id'] as num?)?.toInt(),
    day: (json['day'] as num).toInt(),
    comment: json['comment'] as String? ?? '',
    order: (json['order'] as num).toInt(),
    config: json['config'] as Object,
  );
}

Map<String, dynamic> _$SlotToJson(Slot instance) => <String, dynamic>{
      'id': instance.id,
      'day': instance.day,
      'order': instance.order,
      'comment': instance.comment,
      'config': instance.config,
    };
