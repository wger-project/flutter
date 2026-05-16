
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'measurement_group.g.dart';

/// A named group linking related measurement categories together.
/// Example: "Blood Pressure" groups Systolic + Diastolic categories.
@JsonSerializable()
class MeasurementGroup extends Equatable {
  @JsonKey(required: true)
  final int id;

  @JsonKey(required: true)
  final String uuid;

  @JsonKey(required: true)
  final String name;

  @JsonKey(defaultValue: '')
  final String description;

  const MeasurementGroup({
    required this.id,
    required this.uuid,
    required this.name,
    this.description = '',
  });

  factory MeasurementGroup.fromJson(Map<String, dynamic> json) =>
      _$MeasurementGroupFromJson(json);

  Map<String, dynamic> toJson() => _$MeasurementGroupToJson(this);

  @override
  List<Object?> get props => [id, uuid, name, description];
}