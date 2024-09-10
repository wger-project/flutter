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

import 'package:json_annotation/json_annotation.dart';
import 'package:powersync/sqlite3.dart' as sqlite;
import 'package:wger/helpers/json.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/models/nutrition/ingredient_weight_unit.dart';
import 'package:wger/models/nutrition/meal_item.dart';
import 'package:wger/models/nutrition/nutritional_values.dart';
import 'package:wger/models/schema.dart';
import 'package:wger/powersync.dart';

part 'log.g.dart';

@JsonSerializable()
class Log {
  @JsonKey(required: true)
  int? id;

  @JsonKey(required: false, name: 'meal')
  int? mealId;

  @JsonKey(required: true, name: 'plan')
  int planId;

  @JsonKey(required: true)
  late DateTime datetime;

  String? comment;

  @JsonKey(required: true, name: 'ingredient')
  late int ingredientId;

  @JsonKey(includeFromJson: false, includeToJson: false)
  late Ingredient ingredient;

  @JsonKey(required: true, name: 'weight_unit')
  int? weightUnitId;

  @JsonKey(includeFromJson: false, includeToJson: false)
  IngredientWeightUnit? weightUnitObj;

  @JsonKey(required: true, fromJson: stringToNum)
  late num amount;

  Log({
    this.id,
    required this.mealId,
    required this.ingredientId,
    required this.weightUnitId,
    required this.amount,
    required this.planId,
    required this.datetime,
    this.comment,
  });

  Log.fromMealItem(MealItem mealItem, this.planId, this.mealId, [DateTime? dateTime]) {
    ingredientId = mealItem.ingredientId;
    ingredient = mealItem.ingredient;
    weightUnitId = mealItem.weightUnitId;
    datetime = dateTime ?? DateTime.now();
    amount = mealItem.amount;
  }

  factory Log.fromRow(sqlite.Row row) {
    return Log(
      id: row['id'],
      mealId: row['meal_id'],
      ingredientId: row['ingredient_id'],
      weightUnitId: row['weight_unit_id'],
      amount: row['amount'],
      planId: row['plan_id'],
      datetime: row['datetime'],
      comment: row['comment'],
    );
  }

  // Boilerplate
  factory Log.fromJson(Map<String, dynamic> json) => _$LogFromJson(json);

  Map<String, dynamic> toJson() => _$LogToJson(this);

  /// Calculations
  NutritionalValues get nutritionalValues {
    // This is already done on the server. It might be better to read it from there.

    final weight =
        weightUnitObj == null ? amount : amount * weightUnitObj!.amount * weightUnitObj!.grams;

    return ingredient.nutritionalValues / (100 / weight);
  }
/*
  Future<void> delete() async {
    await db.execute('DELETE FROM $logItemsTable WHERE id = ?', [id]);
  }

  static Future<void> addPhoto(String photoId, String id) async {
    await db.execute('UPDATE $logItemsTable SET photo_id = ? WHERE id = ?', [photoId, id]);
  }
}

  static Stream<List<TodoList>> watchLists() {
    // This query is automatically re-run when data in "lists" or "todos" is modified.
    return db.watch('SELECT * FROM lists ORDER BY created_at, id').map((results) {
      return results.map(TodoList.fromRow).toList(growable: false);
    });
  }
  
 static Future<TodoList> create(String name) async {
    final results = await db.execute('''
      INSERT INTO
        lists(id, created_at, name, owner_id)
        VALUES(uuid(), datetime(), ?, ?)
      RETURNING *
      ''', [name, await getUserId()]);
    return TodoList.fromRow(results.first);
  }
  */
}
