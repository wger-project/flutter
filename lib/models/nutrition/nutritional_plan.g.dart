// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutritional_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NutritionalPlan _$NutritionalPlanFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id', 'description', 'creation_date']);
  return NutritionalPlan(
    id: json['id'] as int?,
    description: json['description'] as String,
    creationDate: DateTime.parse(json['creation_date'] as String),
  );
}

Map<String, dynamic> _$NutritionalPlanToJson(NutritionalPlan instance) => <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'creation_date': toDate(instance.creationDate),
    };
