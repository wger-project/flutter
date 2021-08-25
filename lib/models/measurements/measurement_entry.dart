import 'package:json_annotation/json_annotation.dart';
import 'package:wger/helpers/json.dart';

part 'measurement_entry.g.dart';

@JsonSerializable()
class MeasurementEntry {
  @JsonKey(required: true)
  final int id;

  @JsonKey(required: true)
  final int category;

  @JsonKey(required: true, toJson: toDate)
  final DateTime date;

  @JsonKey(required: true, fromJson: stringToNum, toJson: numToString)
  final num value;

  @JsonKey(required: true, defaultValue: '')
  late String notes;

  MeasurementEntry({
    required this.id,
    required this.category,
    required this.date,
    required this.value,
    notes,
  }) {
    this.notes = notes ?? '';
  }

  // Boilerplate
  factory MeasurementEntry.fromJson(Map<String, dynamic> json) => _$MeasurementEntryFromJson(json);

  Map<String, dynamic> toJson() => _$MeasurementEntryToJson(this);
}
