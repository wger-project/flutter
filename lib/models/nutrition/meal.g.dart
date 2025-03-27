// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Meal _$MealFromJson(Map<String, dynamic> json) => Meal(
      id: (json['id'] as num?)?.toInt(),
      time: stringToTime(json['time'] as String?),
      name: json['name'] as String?,
    )..planId = (json['plan'] as num).toInt();

Map<String, dynamic> _$MealToJson(Meal instance) => <String, dynamic>{
      'id': instance.id,
      'plan': instance.planId,
      'time': timeToString(instance.time),
      'name': instance.name,
    };
