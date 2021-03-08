import 'package:json_annotation/json_annotation.dart';
import 'package:wger/helpers/json.dart';

part 'log.g.dart';

@JsonSerializable()
class Log {
  @JsonKey(required: true)
  final int id;

  @JsonKey(required: true)
  int exercise;

  @JsonKey(required: true, name: 'workout')
  int workoutPlan;

  @JsonKey(required: true)
  int reps;

  @JsonKey(required: false)
  double rir;

  @JsonKey(required: true, name: 'repetition_unit')
  int repetitionUnit;

  @JsonKey(required: true, fromJson: toNum, toJson: toString)
  num weight;

  @JsonKey(required: true, name: 'weight_unit')
  int weightUnit;

  @JsonKey(required: true, toJson: toDate)
  DateTime date;

  //@JsonKey(required: true)
  //String comment;

  Log({
    this.id,
    this.exercise,
    this.workoutPlan,
    this.repetitionUnit,
    this.reps,
    this.rir,
    this.weight,
    this.weightUnit,
    this.date,
  });

  // Boilerplate
  factory Log.fromJson(Map<String, dynamic> json) => _$LogFromJson(json);
  Map<String, dynamic> toJson() => _$LogToJson(this);
}
