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

  @JsonKey(required: true, name: 'only_logging')
  late bool onlyLogging;

  @JsonKey(required: true, name: 'goal_energy')
  late num? goalEnergy;

  @JsonKey(required: true, name: 'goal_protein')
  late num? goalProtein;

  @JsonKey(required: true, name: 'goal_carbohydrates')
  late num? goalCarbohydrates;

  @JsonKey(required: true, name: 'goal_fat')
  late num? goalFat;

  @JsonKey(includeFromJson: false, includeToJson: false, defaultValue: [])
  List<Meal> meals = [];

  @JsonKey(includeFromJson: false, includeToJson: false, defaultValue: [])
  List<Log> diaryEntries = [];

  NutritionalPlan({
    this.id,
    required this.description,
    required this.creationDate,
    this.onlyLogging = false,
    this.goalEnergy,
    this.goalProtein,
    this.goalCarbohydrates,
    this.goalFat,
    List<Meal>? meals,
    List<Log>? diaryEntries,
  }) {
    this.meals = meals ?? [];
    this.diaryEntries = diaryEntries ?? [];
  }

  NutritionalPlan.empty() {
    creationDate = DateTime.now();
    description = '';
    onlyLogging = false;
    goalEnergy = null;
    goalProtein = null;
    goalCarbohydrates = null;
    goalFat = null;
  }

  // Boilerplate
  factory NutritionalPlan.fromJson(Map<String, dynamic> json) => _$NutritionalPlanFromJson(json);

  Map<String, dynamic> toJson() => _$NutritionalPlanToJson(this);

  String getLabel(BuildContext context) {
    return description != '' ? description : AppLocalizations.of(context).nutritionalPlan;
  }

  bool get hasAnyGoals {
    return goalEnergy != null ||
        goalFat != null ||
        goalProtein != null ||
        goalCarbohydrates != null;
  }

  /// Calculations
  ///
  /// note that (some of) this is already done on the server. It might be better
  /// to read it from there, but on the other hand we might want to do more locally
  /// so that a mostly offline mode is possible.
  NutritionalValues get plannedNutritionalValues {
    // If there are set goals, they take preference over any meals
    if (hasAnyGoals) {
      var out = NutritionalValues();

      out.energy = goalEnergy != null ? goalEnergy!.toDouble() : 0;
      out.fat = goalFat != null ? goalFat!.toDouble() : 0;
      out.carbohydrates = goalCarbohydrates != null ? goalCarbohydrates!.toDouble() : 0;
      out.protein = goalProtein != null ? goalProtein!.toDouble() : 0;
      return out;
    }

    return meals.map((e) => e.plannedNutritionalValues).reduce((a, b) => a + b);
  }

  NutritionalValues get loggedNutritionalValuesToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return logEntriesValues.containsKey(today) ? logEntriesValues[today]! : NutritionalValues();
  }

  NutritionalValues get loggedNutritionalValues7DayAvg {
    final currentDate = DateTime.now();
    final sevenDaysAgo = currentDate.subtract(const Duration(days: 7));

    return diaryEntries
        .where((obj) => obj.datetime.isAfter(sevenDaysAgo))
        .map((e) => e.nutritionalValues)
        .reduce((a, b) => a + b);
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
    for (final log in diaryEntries) {
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
    for (final log in diaryEntries) {
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

  Meal pseudoMealOthers(String name) {
    return Meal(
      id: PSEUDO_MEAL_ID,
      plan: id,
      name: name,
      time: null,
      diaryEntries: diaryEntries.where((e) => e.mealId == null).toList(),
    );
  }
}
