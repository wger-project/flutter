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

import 'package:drift/drift.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:powersync/powersync.dart' as ps;
import 'package:wger/database/converters/time_of_day_converter.dart';
import 'package:wger/database/powersync/tables/ingredient.dart';
import 'package:wger/models/nutrition/log.dart';
import 'package:wger/models/nutrition/meal.dart';
import 'package:wger/models/nutrition/meal_item.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';

@UseRowClass(NutritionalPlan)
class NutritionalPlanTable extends Table {
  @override
  String get tableName => 'nutrition_nutritionplan';

  TextColumn get id => text().clientDefault(() => ps.uuid.v7())();
  TextColumn get description => text()();
  DateTimeColumn get creationDate => dateTime().named('creation_date')();
  DateTimeColumn get startDate => dateTime().named('start')();
  DateTimeColumn get endDate => dateTime().named('end').nullable()();
  BoolColumn get onlyLogging => boolean().named('only_logging')();
  IntColumn get goalEnergy => integer().named('goal_energy').nullable()();
  IntColumn get goalProtein => integer().named('goal_protein').nullable()();
  IntColumn get goalCarbohydrates => integer().named('goal_carbohydrates').nullable()();
  IntColumn get goalFiber => integer().named('goal_fiber').nullable()();
  IntColumn get goalFat => integer().named('goal_fat').nullable()();
  BoolColumn get hasGoalCalories => boolean().named('has_goal_calories')();
}

const PowersyncNutritionalPlanTable = ps.Table(
  'nutrition_nutritionplan',
  [
    ps.Column.text('description'),
    ps.Column.text('creation_date'),
    ps.Column.text('start'),
    ps.Column.text('end'),
    ps.Column.integer('only_logging'),
    ps.Column.integer('goal_energy'),
    ps.Column.integer('goal_protein'),
    ps.Column.integer('goal_carbohydrates'),
    ps.Column.integer('goal_fiber'),
    ps.Column.integer('goal_fat'),
    ps.Column.integer('has_goal_calories'),
  ],
);

/// Diary log entries (`nutrition_logitem`).
///
/// The client identifies rows by uuid; the sync rules emit
/// `SELECT uuid AS id` so locally we just see a TEXT primary key. The
/// integer `LogItem.id` from the backend stays server-side.
@UseRowClass(LogItem)
class LogItemTable extends Table {
  @override
  String get tableName => 'nutrition_logitem';

  TextColumn get id => text().clientDefault(() => ps.uuid.v7())();
  TextColumn get planId => text().named('plan_id').references(NutritionalPlanTable, #id)();
  TextColumn get mealId => text().nullable().named('meal_id')();
  IntColumn get ingredientId => integer().named('ingredient_id').references(IngredientTable, #id)();
  IntColumn get weightUnitId => integer().nullable().named('weight_unit_id')();
  DateTimeColumn get datetime => dateTime()();
  RealColumn get amount => real()();
  TextColumn get comment => text().nullable()();
}

const PowersyncLogItemTable = ps.Table(
  'nutrition_logitem',
  [
    ps.Column.text('plan_id'),
    ps.Column.text('meal_id'),
    ps.Column.integer('ingredient_id'),
    ps.Column.integer('weight_unit_id'),
    ps.Column.text('datetime'),
    ps.Column.real('amount'),
    ps.Column.text('comment'),
  ],
  indexes: [
    ps.Index('plan_idx', [ps.IndexedColumn('plan_id')]),
    ps.Index('ingredient_idx', [ps.IndexedColumn('ingredient_id')]),
  ],
);

/// A meal inside a nutritional plan (`nutrition_meal`).
///
/// Identified by uuid client-side; creation, edits and deletes all flow
/// through PowerSync. The `time` is stored as a `HH:MM:SS` string and
/// translated to/from [TimeOfDay] via [TimeOfDayConverter].
@UseRowClass(Meal, constructor: 'fromDrift')
class MealTable extends Table {
  @override
  String get tableName => 'nutrition_meal';

  TextColumn get id => text().clientDefault(() => ps.uuid.v7())();
  TextColumn get planId => text().named('plan_id').references(NutritionalPlanTable, #id)();
  IntColumn get order => integer().withDefault(const Constant(1))();
  TextColumn get time => text().map(const TimeOfDayConverter()).nullable()();
  TextColumn get name => text().withDefault(const Constant(''))();
}

const PowersyncMealTable = ps.Table(
  'nutrition_meal',
  [
    ps.Column.text('plan_id'),
    ps.Column.integer('order'),
    ps.Column.text('time'),
    ps.Column.text('name'),
  ],
  indexes: [
    ps.Index('plan_idx', [ps.IndexedColumn('plan_id')]),
  ],
);

/// A single ingredient + amount inside a meal (`nutrition_mealitem`).
///
/// Identified by uuid client-side; the `meal_id` FK is the parent meal's
/// uuid (not the server-side integer PK). `amount` is a
/// `DecimalField(decimal_places=2, max_digits=6)` server-side, stored here
/// as REAL — the rounding happens implicitly when DRF coerces back.
@UseRowClass(MealItem, constructor: 'fromDrift')
class MealItemTable extends Table {
  @override
  String get tableName => 'nutrition_mealitem';

  TextColumn get id => text().clientDefault(() => ps.uuid.v7())();
  TextColumn get mealId => text().named('meal_id').references(MealTable, #id)();
  IntColumn get ingredientId => integer().named('ingredient_id').references(IngredientTable, #id)();
  IntColumn get weightUnitId => integer().named('weight_unit_id').nullable()();
  IntColumn get order => integer().withDefault(const Constant(1))();
  RealColumn get amount => real()();
}

const PowersyncMealItemTable = ps.Table(
  'nutrition_mealitem',
  [
    ps.Column.text('meal_id'),
    ps.Column.integer('ingredient_id'),
    ps.Column.integer('weight_unit_id'),
    ps.Column.integer('order'),
    ps.Column.real('amount'),
  ],
  indexes: [
    ps.Index('meal_idx', [ps.IndexedColumn('meal_id')]),
    ps.Index('ingredient_idx', [ps.IndexedColumn('ingredient_id')]),
  ],
);
