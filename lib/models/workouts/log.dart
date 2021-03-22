import 'package:json_annotation/json_annotation.dart';
import 'package:wger/helpers/json.dart';

part 'log.g.dart';

@JsonSerializable()
class Log {
  @JsonKey(required: true)
  int? id;

  @JsonKey(required: true)
  late int exercise;

  @JsonKey(required: true, name: 'workout')
  late int workoutPlan;

  @JsonKey(required: true)
  late int reps;

  @JsonKey(required: false)
  late String rir;

  @JsonKey(required: true, name: 'repetition_unit')
  late int repetitionUnit;

  @JsonKey(required: true, fromJson: toNum, toJson: toString)
  late num weight;

  @JsonKey(required: true, name: 'weight_unit')
  late int weightUnit;

  @JsonKey(required: true, toJson: toDate)
  late DateTime date;

  //@JsonKey(required: true)
  //String comment;

  Log();

  Log.withData({
    this.id,
    required this.exercise,
    required this.workoutPlan,
    required this.repetitionUnit,
    required this.reps,
    required this.rir,
    required this.weight,
    required this.weightUnit,
    required this.date,
  });

  // Boilerplate
  factory Log.fromJson(Map<String, dynamic> json) => _$LogFromJson(json);
  Map<String, dynamic> toJson() => _$LogToJson(this);
}
