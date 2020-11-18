import 'package:json_annotation/json_annotation.dart';

part 'weight_unit.g.dart';

@JsonSerializable()
class WeightUnit {
  @JsonKey(required: true)
  final int id;

  @JsonKey(required: true)
  final String name;

  WeightUnit({
    this.id,
    this.name,
  });

  // Boilerplate
  factory WeightUnit.fromJson(Map<String, dynamic> json) => _$WeightUnitFromJson(json);
  Map<String, dynamic> toJson() => _$WeightUnitToJson(this);
}
