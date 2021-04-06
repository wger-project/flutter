import 'package:json_annotation/json_annotation.dart';
import 'package:wger/helpers/json.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/repetition_unit.dart';
import 'package:wger/models/workouts/weight_unit.dart';

part 'log.g.dart';

@JsonSerializable()
class Log {
  @JsonKey(required: true)
  int? id;

  @JsonKey(required: true)
  late int exercise;

  @JsonKey(ignore: true)
  late Exercise exerciseObj;

  @JsonKey(required: true, name: 'workout')
  late int workoutPlan;

  @JsonKey(required: true)
  late int reps;

  @JsonKey(required: false)
  late String rir;

  @JsonKey(required: true, name: 'repetition_unit')
  late int repetitionUnit;

  @JsonKey(ignore: true)
  late RepetitionUnit repetitionUnitObj;

  @JsonKey(required: true, fromJson: toNum, toJson: toString)
  late num weight;

  @JsonKey(required: true, name: 'weight_unit')
  late int weightUnit;

  @JsonKey(ignore: true)
  late WeightUnit weightUnitObj;

  @JsonKey(required: true, toJson: toDate)
  late DateTime date;

  //@JsonKey(required: true)
  //String comment;

  Log(
      {this.id,
      required this.exercise,
      required this.workoutPlan,
      required this.reps,
      required this.rir,
      required this.repetitionUnit,
      required this.weight,
      required this.weightUnit,
      required this.date});

  Log.empty();

  void setExercise(Exercise exercise) {
    this.exerciseObj = exercise;
    this.exercise = exercise.id;
  }

  void setWeightUnit(WeightUnit weightUnit) {
    this.weightUnitObj = weightUnit;
    this.weightUnit = weightUnit.id;
  }

  void setRepetitionUnit(RepetitionUnit repetitionUnit) {
    this.repetitionUnitObj = repetitionUnit;
    this.repetitionUnit = repetitionUnit.id;
  }

  // Boilerplate
  factory Log.fromJson(Map<String, dynamic> json) => _$LogFromJson(json);
  Map<String, dynamic> toJson() => _$LogToJson(this);
}
