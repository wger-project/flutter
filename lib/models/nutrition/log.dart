/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
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

import 'package:drift/drift.dart' as drift;
import 'package:wger/database/powersync/database.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/models/nutrition/ingredient_weight_unit.dart';
import 'package:wger/models/nutrition/meal_item.dart';
import 'package:wger/models/nutrition/nutritional_values.dart';

/// Diary log entry — one ingredient consumed at a point in time.
///
/// Lives entirely in PowerSync/Drift now: row IDs are client-generated UUIDs
/// (so we can write before the server has assigned an integer PK), and the
/// `Ingredient` / `IngredientWeightUnit` relations are hydrated from the same
/// local Drift database by the repository's watch. No JSON round-trip.
///
/// Named `LogItem` to mirror the Django model and Drift table name, and to
/// avoid clashing with the workouts `Log`.
class LogItem {
  /// Client-generated UUID. `null` only for instances built in-memory before
  /// the first persist; Drift fills it in via the table's `clientDefault`.
  String? id;

  String planId;

  /// Optional parent meal (`null` for free-form diary entries that don't belong to a meal)
  String? mealId;

  int ingredientId;
  int? weightUnitId;
  late DateTime datetime;
  late num amount;
  String? comment;

  /// Hydrated by the repository after a Drift JOIN.
  late Ingredient ingredient;

  /// Optional weight unit reference; `null` means the amount is in grams.
  IngredientWeightUnit? weightUnitObj;

  LogItem({
    this.id,
    this.mealId,
    required this.ingredientId,
    this.weightUnitId,
    required num amount,
    required this.planId,
    required DateTime datetime,
    this.comment,
  }) {
    this.amount = amount;
    this.datetime = datetime;
  }

  /// Builds a new log row from a meal-plan item, e.g. when the user taps
  /// "log this meal". The `id` stays null and is assigned by Drift on insert.
  LogItem.fromMealItem(MealItem mealItem, this.planId, this.mealId, [DateTime? dateTime])
    : ingredientId = mealItem.ingredientId,
      weightUnitId = mealItem.weightUnitId {
    ingredient = mealItem.ingredient;
    datetime = dateTime ?? DateTime.now();
    amount = mealItem.amount;
  }

  /// Drift companion for inserts/updates against `nutrition_logitem`.
  ///
  /// On insert we leave `id` absent so the table's `clientDefault` UUID kicks
  /// in. On update set `includeId: true` to address the existing row.
  LogItemTableCompanion toCompanion({bool includeId = false}) {
    return LogItemTableCompanion(
      id: includeId && id != null ? drift.Value(id!) : const drift.Value.absent(),
      planId: drift.Value(planId),
      mealId: mealId == null ? const drift.Value.absent() : drift.Value(mealId!),
      ingredientId: drift.Value(ingredientId),
      weightUnitId: weightUnitId == null ? const drift.Value.absent() : drift.Value(weightUnitId!),
      datetime: drift.Value(datetime.toUtc()),
      amount: drift.Value(amount.toDouble()),
      comment: comment == null ? const drift.Value.absent() : drift.Value(comment!),
    );
  }

  /// Total nutritional contribution of this entry. Server pre-computes the
  /// same value, but doing it locally keeps offline mode honest.
  NutritionalValues get nutritionalValues {
    final weight = weightUnitObj == null ? amount : amount * weightUnitObj!.grams;
    return ingredient.nutritionalValues / (100 / weight);
  }
}
