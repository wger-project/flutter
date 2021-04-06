// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Meal _$MealFromJson(Map<String, dynamic> json) {
  return Meal(
    id: json['id'] as int?,
    time: stringToTime(json['time'] as String?),
  )..planId = json['plan'] as int;
}

Map<String, dynamic> _$MealToJson(Meal instance) => <String, dynamic>{
      'id': instance.id,
      'plan': instance.planId,
      'time': timeToString(instance.time),
    };
