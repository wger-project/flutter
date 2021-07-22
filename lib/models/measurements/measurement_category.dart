import 'package:json_annotation/json_annotation.dart';
import 'package:wger/models/measurements/measurement_entry.dart';

part 'measurement_category.g.dart';

@JsonSerializable()
class MeasurementCategory {
  @JsonKey(required: true)
  final int id;

  @JsonKey(required: true)
  final String name;

  @JsonKey(required: true)
  final String unit;

  @JsonKey(required: true)
  final List<MeasurementEntry> measurementEntries;

  MeasurementCategory({
    required this.id,
    required this.name,
    required this.unit,
    required this.measurementEntries,
  });

  // Boilerplate
  factory MeasurementCategory.fromJson(Map<String, dynamic> json) =>
      _$MeasurementCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$MeasurementToJson(this);
}
