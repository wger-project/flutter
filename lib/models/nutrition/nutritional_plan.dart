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
import 'package:wger/models/nutrition/meal.dart';

import 'nutritrional_values.dart';

part 'nutritional_plan.g.dart';

@JsonSerializable(explicitToJson: true)
class NutritionalPlan {
  @JsonKey(required: true)
  int id;

  @JsonKey(required: true)
  String description;

  @JsonKey(required: true, name: 'creation_date', toJson: toDate)
  DateTime creationDate;

  @JsonKey(required: false)
  List<Meal> meals;

  NutritionalPlan({
    this.id,
    this.description,
    this.creationDate,
    this.meals,
  });

  // Boilerplate
  factory NutritionalPlan.fromJson(Map<String, dynamic> json) => _$NutritionalPlanFromJson(json);
  Map<String, dynamic> toJson() => _$NutritionalPlanToJson(this);

  /// Calculations
  NutritionalValues get nutritionalValues {
    // This is already done on the server. It might be better to read it from there.
    var out = NutritionalValues();

    for (var meal in meals) {
      out.add(meal.nutritionalValues);
    }

    return out;
  }
}
