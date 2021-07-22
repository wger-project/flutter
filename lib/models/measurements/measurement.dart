import 'package:json_annotation/json_annotation.dart';
import 'package:wger/models/measurements/measurement_entry.dart';

part 'measurement.g.dart';

@JsonSerializable()
class Measurement {
  @JsonKey(required: true)
  final int id;

  @JsonKey(required: true)
  final String name;

  @JsonKey(required: true)
  final String unit;

  @JsonKey(required: true)
  final List<MeasurementEntry> measurementEntries;

  Measurement({
    required this.id,
    required this.name,
    required this.unit,
    required this.measurementEntries,
  });

  // Boilerplate
  factory Measurement.fromJson(Map<String, dynamic> json) => _$MeasurementFromJson(json);

  Map<String, dynamic> toJson() => _$MeasurementToJson(this);
}
