/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
import 'package:json_annotation/json_annotation.dart';
import 'package:wger/helpers/json.dart';

part 'ingredient.g.dart';

@JsonSerializable()
class Ingredient {
  @JsonKey(required: true)
  final int id;

  /// Name of the product
  @JsonKey(required: true)
  final String name;

  @JsonKey(required: true, name: 'creation_date', toJson: toDate)
  final DateTime creationDate;

  /// Energy in kJ per 100g of product
  @JsonKey(required: true)
  final int energy;

  /// g per 100g of product
  @JsonKey(required: true, fromJson: toNum, toJson: toString)
  final num carbohydrates;

  /// g per 100g of product
  @JsonKey(required: true, fromJson: toNum, toJson: toString, name: 'carbohydrates_sugar')
  final num carbohydratesSugar;

  /// g per 100g of product
  @JsonKey(required: true, fromJson: toNum, toJson: toString)
  final num protein;

  /// g per 100g of product
  @JsonKey(required: true, fromJson: toNum, toJson: toString)
  final num fat;

  /// g per 100g of product
  @JsonKey(required: true, fromJson: toNum, toJson: toString, name: 'fat_saturated')
  final num fatSaturated;

  /// g per 100g of product
  @JsonKey(required: true, fromJson: toNum, toJson: toString)
  final num fibres;

  /// g per 100g of product
  @JsonKey(required: true, fromJson: toNum, toJson: toString)
  final num sodium;

  const Ingredient({
    required this.id,
    required this.name,
    required this.creationDate,
    required this.energy,
    required this.carbohydrates,
    required this.carbohydratesSugar,
    required this.protein,
    required this.fat,
    required this.fatSaturated,
    required this.fibres,
    required this.sodium,
  });

  // Boilerplate
  factory Ingredient.fromJson(Map<String, dynamic> json) => _$IngredientFromJson(json);
  Map<String, dynamic> toJson() => _$IngredientToJson(this);
}
