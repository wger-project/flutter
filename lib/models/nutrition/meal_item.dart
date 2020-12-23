/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wger/helpers/json.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/models/nutrition/ingredient_weight_unit.dart';

part 'meal_item.g.dart';

@JsonSerializable()
class MealItem {
  @JsonKey(required: true)
  final int id;

  @JsonKey(required: true)
  final Ingredient ingredient;

  @JsonKey(required: true, name: 'weight_unit')
  final IngredientWeightUnit weightUnit;

  @JsonKey(required: true, fromJson: toNum, toJson: toString)
  final num amount;

  MealItem({
    @required this.id,
    @required this.ingredient,
    @required this.weightUnit,
    @required this.amount,
  });

  // Boilerplate
  factory MealItem.fromJson(Map<String, dynamic> json) => _$MealItemFromJson(json);

  Map<String, dynamic> toJson() => _$MealItemToJson(this);

  /// Calculations
  get nutritionalValues {
    // This is already done on the server. It might be better to read it from there.
    var out = {
      'energy': 0.0,
      'energyKj': 0.0,
      'protein': 0.0,
      'carbohydrates': 0.0,
      'carbohydrates_sugar': 0.0,
      'fat': 0.0,
      'fat_saturated': 0.0,
      'fibres': 0.0,
      'sodium': 0.0
    };

    final weight = this.weightUnit == null ? amount : amount * weightUnit.amount * weightUnit.grams;

    out['energy'] += ingredient.energy * weight / 100;
    out['energyKj'] += out['energy'] * 4.184;
    out['protein'] += ingredient.protein * weight / 100;
    out['carbohydrates'] += ingredient.carbohydrates * weight / 100;
    out['fat'] += ingredient.fat * weight / 100;

    if (ingredient.fatSaturated != null) {
      out['fat_saturated'] += ingredient.fatSaturated * weight / 100;
    }

    if (ingredient.fibres != null) {
      out['fibres'] += ingredient.fibres * weight / 100;
    }

    if (ingredient.sodium != null) {
      out['sodium'] += ingredient.sodium * weight / 100;
    }

    return out;
  }
}
