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

import 'package:json_annotation/json_annotation.dart';
import 'package:wger/helpers/json.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/models/nutrition/ingredient_weight_unit.dart';
import 'package:wger/models/nutrition/meal_item.dart';

import 'nutritrional_values.dart';

part 'log.g.dart';

@JsonSerializable()
class Log {
  @JsonKey(required: true)
  int id;

  @JsonKey(required: true, name: 'plan')
  int planId;

  @JsonKey(required: true)
  DateTime datetime;

  String comment;

  @JsonKey(required: true, name: 'ingredient')
  int ingredientId;

  Ingredient ingredientObj;

  @JsonKey(required: true, name: 'weight_unit')
  int weightUnit;

  IngredientWeightUnit weightUnitObj;

  @JsonKey(required: true, fromJson: toNum)
  num amount;

  Log({
    this.id,
    this.ingredientId,
    this.ingredientObj,
    this.weightUnit,
    this.weightUnitObj,
    this.amount,
    this.planId,
    this.datetime,
    this.comment,
  });

  Log.fromMealItem(MealItem mealItem) {
    this.ingredientId = mealItem.ingredientId;
    this.ingredientObj = mealItem.ingredientObj;
    this.weightUnit = null;
    this.amount = mealItem.amount;
  }

  // Boilerplate
  factory Log.fromJson(Map<String, dynamic> json) => _$LogFromJson(json);
  Map<String, dynamic> toJson() => _$LogToJson(this);

  /// Calculations
  NutritionalValues get nutritionalValues {
    // This is already done on the server. It might be better to read it from there.
    var out = NutritionalValues();

    final weight =
        this.weightUnitObj == null ? amount : amount * weightUnitObj.amount * weightUnitObj.grams;

    out.energy = ingredientObj.energy * weight / 100;
    out.protein = ingredientObj.protein * weight / 100;
    out.carbohydrates = ingredientObj.carbohydrates * weight / 100;
    out.fat = ingredientObj.fat * weight / 100;

    if (ingredientObj.fatSaturated != null) {
      out.fatSaturated = ingredientObj.fatSaturated * weight / 100;
    }

    if (ingredientObj.fibres != null) {
      out.fibres = ingredientObj.fibres * weight / 100;
    }

    if (ingredientObj.sodium != null) {
      out.sodium = ingredientObj.sodium * weight / 100;
    }

    return out;
  }
}
