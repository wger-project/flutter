import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ingredient.g.dart';

@JsonSerializable()
class Ingredient {
  @JsonKey(required: true)
  final int id;

  @JsonKey(required: true)
  final String name;

  @JsonKey(required: true, name: 'creation_date')
  final DateTime creationDate;

  @JsonKey(required: true)
  final int energy;

  @JsonKey(required: true)
  final double carbohydrates;

  @JsonKey(required: true)
  final double carbohydrates_sugar;

  @JsonKey(required: true)
  final double fat;

  @JsonKey(required: true)
  final double fat_saturated;

  @JsonKey(required: true)
  final double fibres;

  Ingredient({
    @required this.id,
    @required this.name,
    @required this.creationDate,
    @required this.energy,
    @required this.carbohydrates,
    @required this.carbohydrates_sugar,
    @required this.fat,
    @required this.fat_saturated,
    @required this.fibres,
  });

  // Boilerplate
  factory Ingredient.fromJson(Map<String, dynamic> json) => _$IngredientFromJson(json);
  Map<String, dynamic> toJson() => _$IngredientToJson(this);
}
