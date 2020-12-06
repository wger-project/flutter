/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/foundation.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/models/nutrition/ingredient_weight_unit.dart';

class Log {
  final int id;
  final int nutritionalPlanId;
  final DateTime date;
  final String comment;
  final Ingredient ingredient;
  final IngredientWeightUnit weightUnit;
  final double amount;

  Log({
    @required this.id,
    @required this.ingredient,
    @required this.weightUnit,
    @required this.amount,
    @required this.nutritionalPlanId,
    @required this.date,
    @required this.comment,
  });
}
