import 'package:flutter/foundation.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/repetition_unit.dart';
import 'package:wger/models/workouts/weight_unit.dart';

class Setting {
  final int id;
  final Exercise exercise;
  final RepetitionUnit repetitionUnit;
  final int reps;
  final double weight;
  final WeightUnit weightUnit;
  final String comment;

  Setting({
    @required this.id,
    @required this.exercise,
    @required this.repetitionUnit,
    @required this.reps,
    @required this.weight,
    @required this.weightUnit,
    @required this.comment,
  });
}
