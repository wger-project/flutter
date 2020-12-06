import 'package:json_annotation/json_annotation.dart';
import 'package:wger/helpers/json.dart';

part 'weight_entry.g.dart';

@JsonSerializable()
class WeightEntry {
  @JsonKey(required: true)
  final int id;

  @JsonKey(required: true, fromJson: toNum, toJson: toString)
  num weight;

  @JsonKey(required: true, toJson: toDate)
  DateTime date;

  WeightEntry({
    this.id,
    this.weight,
    this.date,
  });

  // Boilerplate
  factory WeightEntry.fromJson(Map<String, dynamic> json) => _$WeightEntryFromJson(json);
  Map<String, dynamic> toJson() => _$WeightEntryToJson(this);
}
