// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'muscle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Muscle _$MuscleFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'name', 'is_front'],
  );
  return Muscle(
    id: json['id'] as int,
    name: json['name'] as String,
    isFront: json['is_front'] as bool,
  );
}

Map<String, dynamic> _$MuscleToJson(Muscle instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'is_front': instance.isFront,
    };
