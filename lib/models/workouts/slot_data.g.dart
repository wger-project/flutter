// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slot_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SlotData _$SlotDataFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['comment', 'is_superset', 'exercises', 'sets'],
  );
  return SlotData(
    comment: json['comment'] as String,
    isSuperset: json['is_superset'] as bool,
    exerciseIds: (json['exercises'] as List<dynamic>).map((e) => (e as num).toInt()).toList(),
  )..setConfigs = (json['sets'] as List<dynamic>)
      .map((e) => SetConfigData.fromJson(e as Map<String, dynamic>))
      .toList();
}

Map<String, dynamic> _$SlotDataToJson(SlotData instance) => <String, dynamic>{
      'comment': instance.comment,
      'is_superset': instance.isSuperset,
      'exercises': instance.exerciseIds,
      'sets': instance.setConfigs,
    };
