import 'package:json_annotation/json_annotation.dart';
import 'package:wger/models/nutrition/meal.dart';

part 'nutritional_plan.g.dart';

@JsonSerializable(explicitToJson: true)
class NutritionalPlan {
  @JsonKey(required: true)
  final int id;

  @JsonKey(required: true)
  final String description;

  @JsonKey(required: true, name: 'creation_date')
  final DateTime creationDate;

  @JsonKey(required: false)
  final List<Meal> meals;

  NutritionalPlan({
    this.id,
    this.description,
    this.creationDate,
    this.meals,
  });

  // Boilerplate
  factory NutritionalPlan.fromJson(Map<String, dynamic> json) => _$NutritionalPlanFromJson(json);
  Map<String, dynamic> toJson() => _$NutritionalPlanToJson(this);
}
