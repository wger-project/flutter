import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wger/helpers/json.dart';

part 'session.g.dart';

const ImpressionMap = {1: 'bad', 2: 'neutral', 3: 'good'};

@JsonSerializable()
class WorkoutSession {
  @JsonKey(required: true)
  int id;

  @JsonKey(required: true, name: 'workout')
  int workoutId;

  @JsonKey(required: true, toJson: toDate)
  DateTime date;

  @JsonKey(required: true, fromJson: toNum, toJson: toString)
  num impression;

  @JsonKey(required: false, defaultValue: '')
  String notes;

  @JsonKey(required: true, name: 'time_start', toJson: timeToString, fromJson: stringToTime)
  TimeOfDay timeStart;

  @JsonKey(required: true, name: 'time_end', toJson: timeToString, fromJson: stringToTime)
  TimeOfDay timeEnd;

  WorkoutSession({
    this.id,
    this.workoutId,
    this.date,
    this.impression,
    this.notes,
    this.timeStart,
    this.timeEnd,
  });

  // Boilerplate
  factory WorkoutSession.fromJson(Map<String, dynamic> json) => _$WorkoutSessionFromJson(json);
  Map<String, dynamic> toJson() => _$WorkoutSessionToJson(this);

  get impressionAsString {
    return ImpressionMap[impression];
  }
}
