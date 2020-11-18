import 'package:json_annotation/json_annotation.dart';
import 'package:wger/models/workouts/set.dart';

part 'day.g.dart';

@JsonSerializable()
class Day {
  @JsonKey(required: true)
  final int id;

  @JsonKey(required: true)
  final String description;

  @JsonKey(required: true, name: 'days_of_week')
  List<int> daysOfWeek = [];

  @JsonKey(required: true)
  List<Set> sets = [];

  Day({
    this.id,
    this.description,
    this.daysOfWeek,
    this.sets,
  });

  String getDayName(int weekDay) {
    Map<int, String> weekdays = {
      1: 'Monday',
      2: 'Tuesday',
      3: 'Wednesday',
      4: 'Thursday',
      5: 'Friday',
      6: 'Saturday',
      7: 'Sunday',
    };

    return weekdays[weekDay];
  }

  String get getAllDays {
    return daysOfWeek.map((e) => getDayName(e)).join(', ');
  }

  // Boilerplate
  factory Day.fromJson(Map<String, dynamic> json) => _$DayFromJson(json);
  Map<String, dynamic> toJson() => _$DayToJson(this);
}
