import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'equipment.g.dart';

@JsonSerializable()
class Equipment {
  @JsonKey(required: true)
  final int id;

  @JsonKey(required: true)
  final String name;

  Equipment({
    @required this.id,
    @required this.name,
  });

  // Boilerplate
  factory Equipment.fromJson(Map<String, dynamic> json) => _$EquipmentFromJson(json);
  Map<String, dynamic> toJson() => _$EquipmentToJson(this);
}
