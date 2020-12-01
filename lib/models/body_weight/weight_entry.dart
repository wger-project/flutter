import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wger/helpers/json.dart';

part 'weight_entry.g.dart';

@JsonSerializable()
class WeightEntry {
  @JsonKey(required: true)
  final int id;

  @JsonKey(required: true, fromJson: toNum, toJson: toString)
  final num weight;

  @JsonKey(required: true)
  final DateTime date;

  WeightEntry({
    this.id,
    @required this.weight,
    @required this.date,
  });

  // Boilerplate
  factory WeightEntry.fromJson(Map<String, dynamic> json) => _$WeightEntryFromJson(json);
  Map<String, dynamic> toJson() => _$WeightEntryToJson(this);
}
