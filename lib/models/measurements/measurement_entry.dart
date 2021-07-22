import 'package:json_annotation/json_annotation.dart';

part 'measurement_entry.g.dart';

@JsonSerializable()
class MeasurementEntry {
  @JsonKey(required: true)
  final int id;

  @JsonKey(required: true)
  final int category;

  @JsonKey(required: true)
  final String date;

  @JsonKey(required: true)
  final num value;

  @JsonKey(required: true)
  final String notes;

  MeasurementEntry({
    required this.id,
    required this.category,
    required this.date,
    required this.value,
    required this.notes,
  });

  // Boilerplate
  factory MeasurementEntry.fromJson(Map<String, dynamic> json) => _$MeasurementEntryFromJson(json);

  Map<String, dynamic> toJson() => _$MeasurementEntryToJson(this);
}
