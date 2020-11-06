import 'package:flutter/foundation.dart';

class Impression {
  static const bad = 1;
  static const neutral = 2;
  static const good = 3;
}

class WorkoutSession {
  final int id;
  final DateTime date;
  final Impression impression;
  final String notes;
  final DateTime timeStart;
  final DateTime timeEnd;

  WorkoutSession({
    @required this.id,
    @required this.date,
    @required this.impression,
    @required this.notes,
    this.timeStart,
    this.timeEnd,
  });
}
