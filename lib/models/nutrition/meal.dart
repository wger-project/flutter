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

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wger/helpers/json.dart';
import 'package:wger/models/nutrition/meal_item.dart';

import 'nutritrional_values.dart';

part 'meal.g.dart';

@JsonSerializable()
class Meal {
  @JsonKey(required: false)
  late int? id;

  @JsonKey(name: 'plan')
  late int planId;

  @JsonKey(toJson: timeToString, fromJson: stringToTime)
  late TimeOfDay time;

  @JsonKey(ignore: true, name: 'meal_items', defaultValue: [])
  List<MealItem> mealItems = [];

  Meal({
    this.id,
    int? plan,
    TimeOfDay? time,
    List<MealItem>? mealItems,
  }) {
    if (plan != null) {
      this.planId = plan;
    }

    this.mealItems = mealItems ?? [];

    this.time = time ?? TimeOfDay.now();
  }

  // Boilerplate
  factory Meal.fromJson(Map<String, dynamic> json) => _$MealFromJson(json);
  Map<String, dynamic> toJson() => _$MealToJson(this);

  /// Calculations
  NutritionalValues get nutritionalValues {
    // This is already done on the server. It might be better to read it from there.
    var out = NutritionalValues();

    for (var item in mealItems) {
      out.add(item.nutritionalValues);
    }

    return out;
  }
}
