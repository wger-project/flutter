import 'package:json_annotation/json_annotation.dart';

part 'muscle.g.dart';

@JsonSerializable()
class Muscle {
  @JsonKey(required: true)
  final int id;

  @JsonKey(required: true)
  final String name;

  @JsonKey(name: 'is_front', required: true)
  final bool isFront;

  Muscle({
    this.id,
    this.name,
    this.isFront,
  });

  // Boilerplate
  factory Muscle.fromJson(Map<String, dynamic> json) => _$MuscleFromJson(json);
  Map<String, dynamic> toJson() => _$MuscleToJson(this);
}
