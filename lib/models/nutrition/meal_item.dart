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

import 'package:drift/drift.dart' as drift;
import 'package:wger/database/powersync/database.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/models/nutrition/ingredient_weight_unit.dart';
import 'package:wger/models/nutrition/nutritional_values.dart';

class MealItem {
  /// Client-generated UUID, is `null` only before the first persist
  String? id;

  /// FK to the parent meal, the meal's UUID, not the server-side integer PK.
  late String mealId;

  late int ingredientId;

  late Ingredient ingredient;

  int? weightUnitId;

  IngredientWeightUnit? weightUnitObj;

  late num amount;

  /// Server-side ordering inside the meal. Replicated down for completeness;
  /// the client computes new values as `MAX(order) + 1` on insert.
  int order = 1;

  MealItem({
    this.id,
    String? mealId,
    required this.ingredientId,
    this.weightUnitId,
    required this.amount,
    Ingredient? ingredient,
  }) {
    if (mealId != null) {
      this.mealId = mealId;
    }
    if (ingredient != null) {
      this.ingredient = ingredient;
      ingredientId = ingredient.id;
    }
  }

  MealItem.empty();

  /// Constructor used by Drift's generated row factory.
  ///
  /// The hydrated [ingredient]/[weightUnitObj] are filled in by the repository
  /// after a JOIN; instances built here have only the FK ids set.
  MealItem.fromDrift({
    this.id,
    required String mealId,
    required int ingredientId,
    this.weightUnitId,
    required int order,
    required double amount,
  }) {
    this.mealId = mealId;
    this.ingredientId = ingredientId;
    this.amount = amount;
    this.order = order;
  }

  /// Drift companion for inserts/updates against `nutrition_mealitem`.
  ///
  /// If [id] is null, Drift's `clientDefault` mints a fresh UUID on insert.
  /// If set, the value round-trips into the row as-is.
  MealItemTableCompanion toCompanion() {
    return MealItemTableCompanion(
      id: id != null ? drift.Value(id!) : const drift.Value.absent(),
      mealId: drift.Value(mealId),
      ingredientId: drift.Value(ingredientId),
      weightUnitId: weightUnitId == null ? const drift.Value.absent() : drift.Value(weightUnitId!),
      order: drift.Value(order),
      amount: drift.Value(amount.toDouble()),
    );
  }

  /// Calculations
  NutritionalValues get nutritionalValues {
    final weight = weightUnitObj == null ? amount : amount * weightUnitObj!.grams;

    return ingredient.nutritionalValues / (100 / weight);
  }

  MealItem copyWith({
    String? id,
    String? mealId,
    int? ingredientId,
    int? weightUnitId,
    num? amount,
    Ingredient? ingredient,
    IngredientWeightUnit? weightUnitObj,
  }) {
    final m = MealItem(
      id: id ?? this.id,
      mealId: mealId ?? this.mealId,
      ingredientId: ingredientId ?? this.ingredientId,
      weightUnitId: weightUnitId ?? this.weightUnitId,
      amount: amount ?? this.amount,
      ingredient: ingredient ?? this.ingredient,
    );
    m.weightUnitObj = weightUnitObj ?? this.weightUnitObj;
    return m;
  }
}
