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

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wger/helpers/json.dart';
import 'package:wger/models/nutrition/meal_item.dart';

part 'meal.g.dart';

@JsonSerializable()
class Meal {
  @JsonKey(required: true)
  final int id;

  @JsonKey(required: false)
  int plan;

  @JsonKey(required: true, toJson: timeToString, fromJson: stringToTime)
  TimeOfDay time;

  @JsonKey(name: 'meal_items', defaultValue: [])
  List<MealItem> mealItems = [];

  Meal({
    this.id,
    this.plan,
    this.time,
    this.mealItems,
  });

  // Boilerplate
  factory Meal.fromJson(Map<String, dynamic> json) => _$MealFromJson(json);
  Map<String, dynamic> toJson() => _$MealToJson(this);
}
