import 'package:wger/models/workouts/day.dart';

class WorkoutPlan {
  final int id;
  DateTime creationDate;
  String description;
  List<Day> days = [];

  WorkoutPlan({
    this.id,
    this.creationDate,
    this.description,
    this.days,
  });
}
