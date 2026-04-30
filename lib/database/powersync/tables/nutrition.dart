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
import 'package:powersync/powersync.dart' as ps;
import 'package:wger/database/powersync/tables/ingredient.dart';
import 'package:wger/models/nutrition/log.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';

@UseRowClass(NutritionalPlan)
class NutritionalPlanTable extends Table {
  @override
  String get tableName => 'nutrition_nutritionplan';

  IntColumn get id => integer()();
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

  TextColumn get id => text().clientDefault(() => ps.uuid.v4())();
  IntColumn get planId => integer().named('plan_id').references(NutritionalPlanTable, #id)();
  IntColumn get mealId => integer().nullable().named('meal_id')();
  IntColumn get ingredientId => integer().named('ingredient_id').references(IngredientTable, #id)();
  IntColumn get weightUnitId => integer().nullable().named('weight_unit_id')();
  DateTimeColumn get datetime => dateTime()();
  RealColumn get amount => real()();
  TextColumn get comment => text().nullable()();
}

const PowersyncLogItemTable = ps.Table(
  'nutrition_logitem',
  [
    ps.Column.integer('plan_id'),
    ps.Column.integer('meal_id'),
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
