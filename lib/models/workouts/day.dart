import 'package:flutter/foundation.dart';
import 'package:wger/models/workouts/set.dart';

class Day {
  final int id;
  final String description;
  List<int> daysOfWeek = [];
  List<Set> sets = [];

  Day({
    @required this.id,
    @required this.description,
    this.daysOfWeek,
    this.sets,
  });
}
