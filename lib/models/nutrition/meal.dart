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
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/json.dart';
import 'package:wger/helpers/misc.dart';
import 'package:wger/models/nutrition/log.dart';
import 'package:wger/models/nutrition/meal_item.dart';
import 'package:wger/models/nutrition/nutritional_values.dart';

part 'meal.g.dart';

@JsonSerializable()
class Meal {
  @JsonKey(required: false)
  late int? id;

  @JsonKey(name: 'plan')
  late int planId;

  @JsonKey(toJson: timeToString, fromJson: stringToTime)
  TimeOfDay? time;

  @JsonKey(name: 'name')
  late String name;

  @JsonKey(includeFromJson: false, includeToJson: false, defaultValue: [])
  List<MealItem> mealItems = [];

  @JsonKey(includeFromJson: false, includeToJson: false, defaultValue: [])
  List<Log> diaryEntries = [];

  List<Log> get diaryEntriesToday =>
      diaryEntries.where((element) => element.datetime.isSameDayAs(DateTime.now())).toList();

  Meal({
    this.id,
    int? plan,
    this.time,
    String? name,
    List<MealItem>? mealItems,
    List<Log>? diaryEntries,
  }) {
    if (plan != null) {
      planId = plan;
    }

    this.mealItems = mealItems ?? [];
    this.diaryEntries = diaryEntries ?? [];
    this.name = name ?? '';
  }

  /// Calculate total nutritional value
  // This is already done on the server. It might be better to read it from there.
  NutritionalValues get plannedNutritionalValues {
    return mealItems.fold(NutritionalValues(), (a, b) => a + b.nutritionalValues);
  }

  /// Returns the logged nutritional values for today
  NutritionalValues get loggedNutritionalValuesToday {
    return diaryEntries
        .where((l) => l.datetime.isSameDayAs(DateTime.now()))
        .fold(NutritionalValues(), (a, b) => a + b.nutritionalValues);
  }

  bool get isRealMeal {
    return id != null && id != PSEUDO_MEAL_ID;
  }

  // Boilerplate
  factory Meal.fromJson(Map<String, dynamic> json) => _$MealFromJson(json);

  Map<String, dynamic> toJson() => _$MealToJson(this);

  Meal copyWith({
    int? id,
    int? planId,
    TimeOfDay? time,
    String? name,
    List<MealItem>? mealItems,
    List<Log>? diaryEntries,
  }) {
    return Meal(
      id: id ?? this.id,
      plan: planId ?? this.planId,
      time: time ?? this.time,
      name: name ?? this.name,
      mealItems: mealItems ?? this.mealItems,
      diaryEntries: diaryEntries ?? this.diaryEntries,
    );
  }
}
