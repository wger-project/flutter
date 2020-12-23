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
import 'package:json_annotation/json_annotation.dart';
import 'package:wger/helpers/json.dart';

part 'ingredient.g.dart';

@JsonSerializable()
class Ingredient {
  @JsonKey(required: true)
  final int id;

  @JsonKey(required: true)
  final String name;

  @JsonKey(required: true, name: 'creation_date', toJson: toDate)
  final DateTime creationDate;

  @JsonKey(required: true)
  final int energy;

  @JsonKey(required: true, fromJson: toNum, toJson: toString)
  final num carbohydrates;

  @JsonKey(required: true, fromJson: toNum, toJson: toString, name: 'carbohydrates_sugar')
  final num carbohydratesSugar;

  @JsonKey(required: true, fromJson: toNum, toJson: toString)
  final num protein;

  @JsonKey(required: true, fromJson: toNum, toJson: toString)
  final num fat;

  @JsonKey(required: true, fromJson: toNum, toJson: toString, name: 'fat_saturated')
  final num fatSaturated;

  @JsonKey(required: true, fromJson: toNum, toJson: toString)
  final num fibres;

  @JsonKey(required: true, fromJson: toNum, toJson: toString)
  final num sodium;

  Ingredient({
    @required this.id,
    @required this.name,
    @required this.creationDate,
    @required this.energy,
    @required this.carbohydrates,
    @required this.carbohydratesSugar,
    @required this.protein,
    @required this.fat,
    @required this.fatSaturated,
    @required this.fibres,
    @required this.sodium,
  });

  // Boilerplate
  factory Ingredient.fromJson(Map<String, dynamic> json) => _$IngredientFromJson(json);
  Map<String, dynamic> toJson() => _$IngredientToJson(this);
}
