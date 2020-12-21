// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutritional_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NutritionalPlan _$NutritionalPlanFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id', 'description', 'creation_date']);
  return NutritionalPlan(
    id: json['id'] as int,
    description: json['description'] as String,
    creationDate: json['creation_date'] == null
        ? null
        : DateTime.parse(json['creation_date'] as String),
    meals: (json['meals'] as List)
        ?.map(
            (e) => e == null ? null : Meal.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$NutritionalPlanToJson(NutritionalPlan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'creation_date': toDate(instance.creationDate),
      'meals': instance.meals?.map((e) => e?.toJson())?.toList(),
    };
