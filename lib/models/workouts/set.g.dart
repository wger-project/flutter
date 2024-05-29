// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Set _$SetFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'sets', 'order', 'comment'],
  );
  return Set(
    day: (json['exerciseday'] as num).toInt(),
    sets: (json['sets'] as num).toInt(),
    order: (json['order'] as num).toInt(),
  )
    ..id = (json['id'] as num?)?.toInt()
    ..comment = json['comment'] as String? ?? '';
}

Map<String, dynamic> _$SetToJson(Set instance) => <String, dynamic>{
      'id': instance.id,
      'sets': instance.sets,
      'exerciseday': instance.day,
      'order': instance.order,
      'comment': instance.comment,
    };
