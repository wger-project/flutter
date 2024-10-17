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

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:powersync/sqlite3.dart' as sqlite;
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/json.dart';
import 'package:wger/models/nutrition/log.dart';
import 'package:wger/models/nutrition/meal.dart';
import 'package:wger/models/nutrition/meal_item.dart';
import 'package:wger/models/nutrition/nutritional_goals.dart';
import 'package:wger/models/nutrition/nutritional_values.dart';
import 'package:wger/models/schema.dart';
import 'package:wger/powersync.dart';

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

  @JsonKey(required: true, name: 'goal_fiber')
  late num? goalFiber;

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
    this.goalFiber,
    List<Meal>? meals,
    List<Log>? diaryEntries,
  }) {
    this.meals = meals ?? [];
    this.diaryEntries = diaryEntries ?? [];
  }

  factory NutritionalPlan.fromRow(sqlite.Row row) {
    return NutritionalPlan(
      id: int.parse(row['id']),
      description: row['description'],
      creationDate: DateTime.parse(row['creation_date']),
      onlyLogging: row['only_logging'] == 1,
      goalEnergy: row['goal_energy'],
      goalProtein: row['goal_protein'],
      goalCarbohydrates: row['goal_carbohydrates'],
      goalFat: row['goal_fat'],
      goalFiber: row['goal_fiber'],
    );
  }

  NutritionalPlan copyWith({
    int? id,
    String? description,
    DateTime? creationDate,
    bool? onlyLogging,
    num? goalEnergy,
    num? goalProtein,
    num? goalCarbohydrates,
    num? goalFat,
    num? goalFiber,
    List<Meal>? meals,
    List<Log>? diaryEntries,
  }) {
    return NutritionalPlan(
      id: id ?? this.id,
      description: description ?? this.description,
      creationDate: creationDate ?? this.creationDate,
      onlyLogging: onlyLogging ?? this.onlyLogging,
      goalEnergy: goalEnergy ?? this.goalEnergy,
      goalProtein: goalProtein ?? this.goalProtein,
      goalCarbohydrates: goalCarbohydrates ?? this.goalCarbohydrates,
      goalFat: goalFat ?? this.goalFat,
      goalFiber: goalFiber ?? this.goalFiber,
      meals: meals ?? this.meals,
      diaryEntries: diaryEntries ?? this.diaryEntries,
    );
  }

  Future<NutritionalPlan> loadChildren() async {
    return copyWith(
      diaryEntries: await Log.readByPlanId(id!),
      meals: await Meal.readByPlanId(id!),
    );
  }

  NutritionalPlan.empty() {
    creationDate = DateTime.now();
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
    final out = <Log>[];
    for (final log in diaryEntries) {
      final found = out.firstWhereOrNull(
        (e) => e.amount == log.amount && e.ingredientId == log.ingredientId,
      );
      if (found == null) {
        out.add(log);
      }
    }
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

  static Future<NutritionalPlan> read(int id) async {
    final row = await db.get('SELECT * FROM $tableNutritionPlans WHERE id = ?', [id]);
    return NutritionalPlan.fromRow(row).loadChildren();
  }

// this is a bit complicated.
// what we need at the end of the day, is a stream of List<NutritionPlan>, where
// a new value is emitted any time a plan is changed. But the plan is not just the plan record
// we need to load data for Logs and Meals corresponding to the plan also.
// so our options are:
// 1) db.watch with a select query on plans; and extra dart code to load the logs/meals stuff,
//    but this only triggers for updates on the plans table, and misses logs/meals updates
// 2) db.watch with a huge join query across all tables from which we need info,
//    so we have all the data in our resultset to create the datastructures with, but:
//    - this creates long rows with lots of duplicated data (e.g. all the plan data) for every row
//       which would only differ for e.g. the meal or the log item
//    - it would probably get a bit messy to parse the resultset into the datastructures
// 3) the best of both worlds: load the data we need in dart at runtime, but explicitly
//    trigger our code execution when *any* of the relevant tables changes
//
  static Stream<List<NutritionalPlan>> watchNutritionPlans() {
    return db.onChange([tableNutritionPlans, tableLogItems, tableMeals]).asyncMap((event) async {
      final data = await db.getAll('SELECT * FROM $tableNutritionPlans ORDER BY creation_date');
      final futures = Future.wait(data.map((row) => NutritionalPlan.fromRow(row).loadChildren()));
      return (await futures).toList(growable: false);
    });
  }

  static Stream<NutritionalPlan?> watchNutritionPlan(int id) {
    return db.onChange([tableNutritionPlans, tableLogItems, tableMeals]).asyncMap((event) async {
      final row = await db.getOptional('SELECT * FROM $tableNutritionPlans WHERE id = ?', [id]);
      return row == null ? null : NutritionalPlan.fromRow(row).loadChildren();
    });
  }

  static Stream<NutritionalPlan> watchNutritionPlanLast() {
    return db.onChange([tableNutritionPlans, tableLogItems, tableMeals]).asyncMap((event) async {
      final row =
          await db.get('SELECT * FROM $tableNutritionPlans ORDER BY creation_date DESC LIMIT 1');
      return NutritionalPlan.fromRow(row).loadChildren();
    });
  }
/*
  static Stream<List<NutritionalPlan>> watchNutritionPlan(int id) {
    return db
        .watch('SELECT * FROM $tableNutritionPlans WHERE id = ?', parameters: [id]).map((results) {
      return results.map(NutritionalPlan.fromRow).toList(growable: false);
    });
  }

  static Stream<List<NutritionalPlan>> watchNutritionPlans() {
    return db.watch('SELECT * FROM $tableNutritionPlans ORDER BY creation_date').map((results) {
      return results.map(NutritionalPlan.fromRow).toList(growable: false);
    });
  }
  */

  Future<void> delete() async {
    await db.execute('DELETE FROM $tableNutritionPlans WHERE id = ?', [id]);
  }
}
