import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:wger/models/workouts/set.dart';

class Day {
  final int id;
  final String description;
  List<int> daysOfWeek = [];
  List<Set> sets = [];

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

  Day({
    @required this.id,
    @required this.description,
    this.daysOfWeek,
    this.sets,
  });
}
