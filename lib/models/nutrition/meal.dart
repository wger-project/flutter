import 'package:json_annotation/json_annotation.dart';
import 'package:wger/models/nutrition/meal_item.dart';

part 'meal.g.dart';

@JsonSerializable()
class Meal {
  @JsonKey(required: true)
  final int id;

  @JsonKey(required: true)
  final DateTime time;

  @JsonKey(required: true, name: 'meal_items')
  final List<MealItem> mealItems;

  Meal({
    this.id,
    this.time,
    this.mealItems,
  });

  // Boilerplate
  factory Meal.fromJson(Map<String, dynamic> json) => _$MealFromJson(json);
  Map<String, dynamic> toJson() => _$MealToJson(this);
}
