import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wger/helpers/json.dart';

part 'session.g.dart';

const ImpressionMap = {1: 'bad', 2: 'neutral', 3: 'good'};

@JsonSerializable()
class WorkoutSession {
  @JsonKey(required: true)
  int? id;

  @JsonKey(required: true, name: 'workout')
  late int workoutId;

  @JsonKey(required: true, toJson: toDate)
  late DateTime date;

  @JsonKey(required: true, fromJson: toNum, toJson: toString)
  late num impression;

  @JsonKey(required: false, defaultValue: '')
  late String notes;

  @JsonKey(required: true, name: 'time_start', toJson: timeToString, fromJson: stringToTime)
  late TimeOfDay timeStart;

  @JsonKey(required: true, name: 'time_end', toJson: timeToString, fromJson: stringToTime)
  late TimeOfDay timeEnd;

  WorkoutSession();

  WorkoutSession.withData({
    required this.id,
    required this.workoutId,
    required this.date,
    required this.impression,
    required this.notes,
    required this.timeStart,
    required this.timeEnd,
  });

  // Boilerplate
  factory WorkoutSession.fromJson(Map<String, dynamic> json) => _$WorkoutSessionFromJson(json);
  Map<String, dynamic> toJson() => _$WorkoutSessionToJson(this);

  get impressionAsString {
    return ImpressionMap[impression];
  }
}
