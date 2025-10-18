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

import 'dart:collection';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:logging/logging.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/json.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/nutrition/log.dart';
import 'package:wger/models/nutrition/meal.dart';
import 'package:wger/models/nutrition/meal_item.dart';
import 'package:wger/models/nutrition/nutritional_goals.dart';
import 'package:wger/models/nutrition/nutritional_values.dart';

part 'nutritional_plan.g.dart';

@JsonSerializable(explicitToJson: true)
class NutritionalPlan {
  final _logger = Logger('NutritionalPlan Model');

  @JsonKey(required: true)
  int? id;

  @JsonKey(required: true)
  late String description;

  @JsonKey(required: true, name: 'creation_date', toJson: dateToUtcIso8601)
  late DateTime creationDate;

  @JsonKey(required: true, name: 'start', toJson: dateToYYYYMMDD)
  late DateTime startDate;

  @JsonKey(required: true, name: 'end', toJson: dateToYYYYMMDD)
  late DateTime? endDate;

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

  @JsonKey(required: true, name: 'goal_fiber')
  late num? goalFiber;

  @JsonKey(includeFromJson: false, includeToJson: false, defaultValue: [])
  List<Meal> meals = [];

  @JsonKey(includeFromJson: false, includeToJson: false, defaultValue: [])
  List<Log> diaryEntries = [];

  NutritionalPlan({
    this.id,
    required this.description,
    DateTime? creationDate,
    required this.startDate,
    this.endDate,
    this.onlyLogging = false,
    this.goalEnergy,
    this.goalProtein,
    this.goalCarbohydrates,
    this.goalFat,
    this.goalFiber,
    List<Meal>? meals,
    List<Log>? diaryEntries,
  }) : creationDate = creationDate ?? DateTime.now() {
    this.meals = meals ?? [];
    this.diaryEntries = diaryEntries ?? [];

    if (endDate != null && endDate!.isBefore(startDate)) {
      _logger.warning(
        'The end date of a nutritional plan is before the start. Setting to null! '
        'PlanId: $id, startDate: $startDate, endDate: $endDate',
      );
      endDate = null;
    }
  }

  NutritionalPlan.empty() {
    creationDate = DateTime.now();
    startDate = DateTime.now();
    endDate = null;
    description = '';
    onlyLogging = false;
    goalEnergy = null;
    goalProtein = null;
    goalCarbohydrates = null;
    goalFiber = null;
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

  bool get hasAnyAdvancedGoals {
    return goalFiber != null;
  }

  /// Calculations
  ///
  /// note that (some of) this is already done on the server. It might be better
  /// to read it from there, but on the other hand we might want to do more locally
  /// so that a mostly offline mode is possible.
  NutritionalGoals get nutritionalGoals {
    // If there are set goals, they take preference over any meals
    if (hasAnyGoals || hasAnyAdvancedGoals) {
      return NutritionalGoals(
        energy: goalEnergy?.toDouble(),
        fat: goalFat?.toDouble(),
        protein: goalProtein?.toDouble(),
        carbohydrates: goalCarbohydrates?.toDouble(),
        fiber: goalFiber?.toDouble(),
      );
    }
    // if there are no set goals and no defined meals, the goals are still undefined
    if (meals.isEmpty) {
      return NutritionalGoals();
    }
    // otherwise, add up all the nutritional values of the meals and use that as goals
    final sumValues = meals.fold(
      NutritionalValues(),
      (a, b) => a + b.plannedNutritionalValues,
    );
    return NutritionalGoals(
      energy: sumValues.energy,
      fat: sumValues.fat,
      protein: sumValues.protein,
      carbohydrates: sumValues.carbohydrates,
      carbohydratesSugar: sumValues.carbohydratesSugar,
      fatSaturated: sumValues.fatSaturated,
      fiber: sumValues.fiber,
      sodium: sumValues.sodium,
    );
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
            .fold(NutritionalValues(), (a, b) => a + b.nutritionalValues) /
        7;
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

  /// returns meal items across all meals
  /// deduped by the combination of amount and ingredient ID
  List<MealItem> get dedupMealItems {
    final List<MealItem> out = [];
    for (final meal in meals) {
      for (final mealItem in meal.mealItems) {
        final found = out.firstWhereOrNull(
          (e) => e.amount == mealItem.amount && e.ingredientId == mealItem.ingredientId,
        );

        if (found == null) {
          out.add(mealItem);
        }
      }
    }
    return out;
  }

  /// returns diary entries
  /// deduped by the combination of amount and ingredient ID
  List<Log> get dedupDiaryEntries {
    //Get unique and sort by frequency
    const Duration recentWindow = Duration(days: -90);
    var uniqueLogs = <String, Log>{};
    for (final log in diaryEntries) {
      final int howMany = diaryEntries
          .where((diaryEntries) =>
              diaryEntries.ingredientId == log.ingredientId &&
              diaryEntries.amount == log.amount &&
              diaryEntries.datetime.isAfter(DateTime.now().add(recentWindow)))
          .length;
      //Padding allows for sorting string as if number
      final String howManyPadded = howMany.toString().padLeft(10, '0');
      final uniqueAndCountString = '${howManyPadded}_${log.ingredientId}_${log.amount}';
      uniqueLogs[uniqueAndCountString] = log;
    }

    final sortedByFrequency = SplayTreeMap<String, Log>.from(uniqueLogs, (b, a) => a.compareTo(b));
    final out = sortedByFrequency.values.toList();

    return out;
  }

  Meal pseudoMealOthers(String name) {
    return Meal(
      id: PSEUDO_MEAL_ID,
      plan: id,
      name: name,
      diaryEntries: diaryEntries.where((e) => e.mealId == null).toList(),
    );
  }
}
