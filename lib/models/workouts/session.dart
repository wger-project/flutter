import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wger/helpers/json.dart';

part 'session.g.dart';

const ImpressionMap = {1: 'bad', 2: 'neutral', 3: 'good'};

@JsonSerializable()
class WorkoutSession {
  @JsonKey(required: true)
  final int id;

  @JsonKey(required: true)
  final DateTime date;

  @JsonKey(required: true, fromJson: toNum, toJson: toString)
  final num impression;

  @JsonKey(required: false, defaultValue: '')
  final String notes;

  @JsonKey(required: true, name: 'time_start', toJson: timeToString, fromJson: stringToTime)
  final TimeOfDay timeStart;

  @JsonKey(required: true, name: 'time_end', toJson: timeToString, fromJson: stringToTime)
  final TimeOfDay timeEnd;

  WorkoutSession({
    @required this.id,
    @required this.date,
    @required this.impression,
    @required this.notes,
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
