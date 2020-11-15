import 'package:flutter/foundation.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/repetition_unit.dart';
import 'package:wger/models/workouts/weight_unit.dart';
import 'package:wger/models/workouts/workout_plan.dart';

class Log {
  final int id;
  final Exercise exercise;
  final WorkoutPlan workoutPlan;

  final int reps;
  final RepetitionUnit repetitionUnit;

  final double weight;
  final WeightUnit weightUnit;

  final DateTime date;

  Log({
    @required this.id,
    @required this.exercise,
    @required this.workoutPlan,
    @required this.repetitionUnit,
    @required this.reps,
    @required this.weight,
    @required this.weightUnit,
    @required this.date,
  });
}
