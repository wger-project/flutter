import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wger/helpers/json.dart';

part 'log.g.dart';

@JsonSerializable()
class Log {
  @JsonKey(required: true)
  final int id;

  @JsonKey(required: true)
  final int exercise;

  @JsonKey(required: true, name: 'workout')
  final int workoutPlan;

  @JsonKey(required: true)
  final int reps;

  @JsonKey(required: false)
  final double rir;

  @JsonKey(required: true, name: 'repetition_unit')
  final int repetitionUnit;

  @JsonKey(required: true, fromJson: toNum, toJson: toString)
  final num weight;

  @JsonKey(required: true, name: 'weight_unit')
  final int weightUnit;

  @JsonKey(required: true)
  final DateTime date;

  Log({
    @required this.id,
    @required this.exercise,
    @required this.workoutPlan,
    @required this.repetitionUnit,
    @required this.reps,
    @required this.rir,
    @required this.weight,
    @required this.weightUnit,
    @required this.date,
  });

  // Boilerplate
  factory Log.fromJson(Map<String, dynamic> json) => _$LogFromJson(json);
  Map<String, dynamic> toJson() => _$LogToJson(this);
}
