import 'package:json_annotation/json_annotation.dart';
import 'package:wger/models/workouts/day.dart';

part 'workout_plan.g.dart';

@JsonSerializable()
class WorkoutPlan {
  @JsonKey(required: true)
  final int id;

  @JsonKey(required: true, name: 'creation_date')
  DateTime creationDate;

  @JsonKey(required: true, name: 'comment')
  String description;

  @JsonKey(required: false, name: 'days')
  List<Day> days = [];

  WorkoutPlan({
    this.id,
    this.creationDate,
    this.description,
    this.days,
  });

  // Boilerplate
  factory WorkoutPlan.fromJson(Map<String, dynamic> json) => _$WorkoutPlanFromJson(json);
  Map<String, dynamic> toJson() => _$WorkoutPlanToJson(this);
}
