import 'package:json_annotation/json_annotation.dart';

part 'repetition_unit.g.dart';

@JsonSerializable()
class RepetitionUnit {
  @JsonKey(required: true)
  final int id;

  @JsonKey(required: true)
  final String name;

  RepetitionUnit({
    required this.id,
    required this.name,
  });

  // Boilerplate
  factory RepetitionUnit.fromJson(Map<String, dynamic> json) => _$RepetitionUnitFromJson(json);
  Map<String, dynamic> toJson() => _$RepetitionUnitToJson(this);
}
