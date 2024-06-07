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
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/models/nutrition/weight_unit.dart';

part 'ingredient_weight_unit.g.dart';

@JsonSerializable()
class IngredientWeightUnit {
  @JsonKey(required: true)
  final int id;

  @JsonKey(required: true, name: 'weight_unit')
  final WeightUnit weightUnit;

  @JsonKey(required: true)
  final Ingredient ingredient;

  @JsonKey(required: true)
  final int grams;

  @JsonKey(required: true)
  final double amount;

  const IngredientWeightUnit({
    required this.id,
    required this.weightUnit,
    required this.ingredient,
    required this.grams,
    required this.amount,
  });

  // Boilerplate
  factory IngredientWeightUnit.fromJson(Map<String, dynamic> json) =>
      _$IngredientWeightUnitFromJson(json);
  Map<String, dynamic> toJson() => _$IngredientWeightUnitToJson(this);
}
