/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2026 wger Team
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
import 'package:flutter/material.dart';
import 'package:wger/database/powersync/database.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/date.dart';
import 'package:wger/models/nutrition/log.dart';
import 'package:wger/models/nutrition/meal_item.dart';
import 'package:wger/models/nutrition/nutritional_values.dart';

class Meal {
  String? id;

  /// FK to the parent plan
  late String planId;

  TimeOfDay? time;

  late String name;

  /// Server-side ordering inside the plan. Replicated down for completeness;
  /// the client computes new values as `MAX(order) + 1` on insert.
  int order = 1;

  List<MealItem> mealItems = [];

  List<LogItem> diaryEntries = [];

  List<LogItem> get diaryEntriesToday =>
      diaryEntries.where((element) => element.datetime.isSameDayAs(DateTime.now())).toList();

  Meal({
    this.id,
    String? plan,
    this.time,
    String? name,
    List<MealItem>? mealItems,
    List<LogItem>? diaryEntries,
  }) {
    if (plan != null) {
      planId = plan;
    }

    this.mealItems = mealItems ?? [];
    this.diaryEntries = diaryEntries ?? [];
    this.name = name ?? '';
  }

  /// Constructor used by Drift's generated row factory.
  ///
  /// The column names declared on `MealTable` map onto the named parameters
  /// here; `mealItems`/`diaryEntries` aren't synced and are filled in later
  /// by the repository hydration step.
  Meal.fromDrift({
    this.id,
    required String planId,
    required int order,
    this.time,
    required String name,
  }) {
    this.planId = planId;
    this.order = order;
    this.name = name;
    mealItems = [];
    diaryEntries = [];
  }

  /// Total nutritional values across all child meal items.
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

  /// Drift companion for inserts/updates against `nutrition_meal`.
  ///
  /// On insert, leave `id` absent so the table's `clientDefault` UUID kicks
  /// in (or set [includeId] true if you've already generated it). For an
  /// update, the row id must be present, we throw if it's missing.
  MealTableCompanion toCompanion({bool includeId = true}) {
    final mealId = id;
    if (includeId && mealId == null) {
      throw StateError('Cannot persist meal without id');
    }
    return MealTableCompanion(
      id: includeId && mealId != null ? drift.Value(mealId) : const drift.Value.absent(),
      planId: drift.Value(planId),
      order: drift.Value(order),
      time: time == null ? const drift.Value.absent() : drift.Value(time!),
      name: drift.Value(name),
    );
  }

  Meal copyWith({
    String? id,
    String? planId,
    TimeOfDay? time,
    String? name,
    List<MealItem>? mealItems,
    List<LogItem>? diaryEntries,
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
