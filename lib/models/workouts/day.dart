import 'package:json_annotation/json_annotation.dart';
import 'package:wger/models/workouts/set.dart';
import 'package:wger/models/workouts/workout_plan.dart';

part 'day.g.dart';

@JsonSerializable()
class Day {
  @JsonKey(required: true)
  int? id;

  @JsonKey(required: true)
  late String description;

  @JsonKey(required: false, name: 'day', defaultValue: [])
  List<int> daysOfWeek = [];

  //@JsonKey(required: false)
  List<Set> sets = [];

  @JsonKey(required: true, name: 'training')
  late int workoutId;

  //@JsonKey(required: true, name: 'training')
  late WorkoutPlan workout;

  Day() {
    this.daysOfWeek = [];
    this.sets = [];
  }

  Day.withData({
    required this.id,
    required this.workoutId,
    required this.description,
    List<int>? daysOfWeek,
    List<Set>? sets,
  }) {
    this.daysOfWeek = daysOfWeek ?? [];
    this.sets = sets ?? [];
  }

  static const Map<int, String> weekdays = {
    1: 'Monday',
    2: 'Tuesday',
    3: 'Wednesday',
    4: 'Thursday',
    5: 'Friday',
    6: 'Saturday',
    7: 'Sunday',
  };

  String getDayName(int weekDay) {
    return weekdays[weekDay]!;
  }

  String get getDaysText {
    return daysOfWeek.map((e) => getDayName(e)).join(', ');
  }

  // Boilerplate
  factory Day.fromJson(Map<String, dynamic> json) => _$DayFromJson(json);
  Map<String, dynamic> toJson() => _$DayToJson(this);
}
