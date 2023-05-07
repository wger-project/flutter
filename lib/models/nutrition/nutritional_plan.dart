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

import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/json.dart';
import 'package:wger/models/nutrition/log.dart';
import 'package:wger/models/nutrition/meal.dart';
import 'package:wger/models/nutrition/meal_item.dart';
import 'package:wger/models/nutrition/nutritional_values.dart';

part 'nutritional_plan.g.dart';

@JsonSerializable(explicitToJson: true)
class NutritionalPlan {
  @JsonKey(required: true)
  int? id;

  @JsonKey(required: true)
  late String description;

  @JsonKey(required: true, name: 'creation_date', toJson: toDate)
  late DateTime creationDate;

  @JsonKey(includeFromJson: false, includeToJson: false, defaultValue: [])
  List<Meal> meals = [];

  @JsonKey(includeFromJson: false, includeToJson: false, defaultValue: [])
  List<Log> logs = [];

  NutritionalPlan({
    this.id,
    required this.description,
    required this.creationDate,
    List<Meal>? meals,
    List<Log>? logs,
  }) {
    this.meals = meals ?? [];
    this.logs = logs ?? [];
  }

  NutritionalPlan.empty() {
    creationDate = DateTime.now();
    description = '';
  }

  // Boilerplate
  factory NutritionalPlan.fromJson(Map<String, dynamic> json) => _$NutritionalPlanFromJson(json);

  Map<String, dynamic> toJson() => _$NutritionalPlanToJson(this);

  String getLabel(BuildContext context) {
    return description != '' ? description : AppLocalizations.of(context).nutritionalPlan;
  }

  /// Calculations
  NutritionalValues get nutritionalValues {
    // This is already done on the server. It might be better to read it from there.
    var out = NutritionalValues();

    for (final meal in meals) {
      out += meal.nutritionalValues;
    }

    return out;
  }

  /// Calculates the percentage each macro nutrient adds to the total energy
  BaseNutritionalValues energyPercentage(NutritionalValues values) {
    return BaseNutritionalValues(
      values.protein > 0 ? ((values.protein * ENERGY_PROTEIN * 100) / values.energy) : 0,
      values.carbohydrates > 0
          ? ((values.carbohydrates * ENERGY_CARBOHYDRATES * 100) / values.energy)
          : 0,
      values.fat > 0 ? ((values.fat * ENERGY_FAT * 100) / values.energy) : 0,
    );
  }

  /// Calculates the grams per body-kg for each macro nutrient
  BaseNutritionalValues gPerBodyKg(num weight, NutritionalValues values) {
    assert(weight > 0);

    return BaseNutritionalValues(
      values.protein / weight,
      values.carbohydrates / weight,
      values.fat / weight,
    );
  }

  Map<DateTime, NutritionalValues> get logEntriesValues {
    final out = <DateTime, NutritionalValues>{};
    for (final log in logs) {
      final date = DateTime(log.datetime.year, log.datetime.month, log.datetime.day);

      if (!out.containsKey(date)) {
        out[date] = NutritionalValues();
      }

      out[date]!.add(log.nutritionalValues);
    }

    return out;
  }

  /// Returns the nutritional values for the given date
  NutritionalValues? getValuesForDate(DateTime date) {
    final values = logEntriesValues;
    final dateKey = DateTime(date.year, date.month, date.day);

    return values.containsKey(dateKey) ? values[dateKey] : null;
  }

  /// Returns the nutritional logs for the given date
  List<Log> getLogsForDate(DateTime date) {
    final List<Log> out = [];
    for (final log in logs) {
      final dateKey = DateTime(date.year, date.month, date.day);
      final logKey = DateTime(log.datetime.year, log.datetime.month, log.datetime.day);

      if (dateKey == logKey) {
        out.add(log);
      }
    }

    return out;
  }

  /// Helper that returns all meal items for the current plan
  ///
  /// Duplicated ingredients are removed
  List<MealItem> get allMealItems {
    final List<MealItem> out = [];
    for (final meal in meals) {
      for (final mealItem in meal.mealItems) {
        final ingredientInList = out.where((e) => e.ingredientId == mealItem.ingredientId);

        if (ingredientInList.isEmpty) {
          out.add(mealItem);
        }
      }
    }
    return out;
  }
}
