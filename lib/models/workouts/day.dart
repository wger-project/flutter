import 'package:json_annotation/json_annotation.dart';
import 'package:wger/models/workouts/set.dart';

part 'day.g.dart';

@JsonSerializable()
class Day {
  static const Map<int, String> weekdays = {
    1: 'Monday',
    2: 'Tuesday',
    3: 'Wednesday',
    4: 'Thursday',
    5: 'Friday',
    6: 'Saturday',
    7: 'Sunday',
  };

  @JsonKey(required: true)
  int? id;

  @JsonKey(required: true, name: 'training')
  late int workoutId;

  @JsonKey(required: true)
  late String description;

  @JsonKey(required: true, name: 'day')
  List<int> daysOfWeek = [];

  @JsonKey(ignore: true)
  List<Set> sets = [];

  //@JsonKey(ignore: true)
  //late WorkoutPlan workout;

  Day() {
    this.daysOfWeek = [];
    this.sets = [];
  }

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
