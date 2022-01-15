// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Log _$LogFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'plan',
      'datetime',
      'ingredient',
      'weight_unit',
      'amount'
    ],
  );
  return Log(
    id: json['id'] as int?,
    mealId: json['meal'] as int?,
    ingredientId: json['ingredient'] as int,
    weightUnitId: json['weight_unit'] as int?,
    amount: stringToNum(json['amount'] as String?),
    planId: json['plan'] as int,
    datetime: DateTime.parse(json['datetime'] as String),
    comment: json['comment'] as String?,
  );
}

Map<String, dynamic> _$LogToJson(Log instance) => <String, dynamic>{
      'id': instance.id,
      'meal': instance.mealId,
      'plan': instance.planId,
      'datetime': instance.datetime.toIso8601String(),
      'comment': instance.comment,
      'ingredient': instance.ingredientId,
      'weight_unit': instance.weightUnitId,
      'amount': instance.amount,
    };
