import 'package:json_annotation/json_annotation.dart';
import 'package:wger/models/measurements/measurement_entry.dart';
import 'package:equatable/equatable.dart';

part 'measurement_category.g.dart';

@JsonSerializable(explicitToJson: true)
class MeasurementCategory extends Equatable {
  @JsonKey(required: true)
  final int id;

  @JsonKey(required: true)
  final String name;

  @JsonKey(required: true)
  final String unit;

  @JsonKey(
    defaultValue: [],
  )
  List<MeasurementEntry> entries;

  MeasurementCategory({
    required this.id,
    required this.name,
    required this.unit,
    this.entries = const [],
  });

  // Boilerplate
  factory MeasurementCategory.fromJson(Map<String, dynamic> json) =>
      _$MeasurementCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$MeasurementCategoryToJson(this);

  @override
  List<Object> get props => [id, name, unit, entries];
}
