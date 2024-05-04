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

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/models/nutrition/nutritional_values.dart';

part 'nutritional_goals.freezed.dart';

@freezed
class NutritionalGoals {
  final double? energy;
  final double? protein;
  final double? carbohydrates;
  final double? carbohydratesSugar;
  final double? fat;
  final double? fatSaturated;
  final double? fibres;
  final double? sodium;

  factory NutritionalGoals({
    double? energy,
    double? protein,
    double? carbohydrates,
    double? carbohydratesSugar,
    double? fat,
    double? fatSaturated,
    double? fibres,
    double? sodium,
  }) {
    // infer values where we can
    if (energy == null) {
      if (protein != null && carbohydrates != null && fat != null) {
        energy = protein * ENERGY_PROTEIN + carbohydrates * ENERGY_CARBOHYDRATES + fat * ENERGY_FAT;
      }
    } else {
      // TODO: input validation when the user modifies/creates the plan, to assure energy is high enough
      if (protein == null && carbohydrates != null && fat != null) {
        protein =
            (energy - carbohydrates * ENERGY_CARBOHYDRATES - fat * ENERGY_FAT) / ENERGY_PROTEIN;
        assert(protein > 0);
      } else if (carbohydrates == null && protein != null && fat != null) {
        carbohydrates =
            (energy - protein * ENERGY_PROTEIN - fat * ENERGY_FAT) / ENERGY_CARBOHYDRATES;
        assert(carbohydrates > 0);
      } else if (fat == null && protein != null && carbohydrates != null) {
        fat =
            (energy - protein * ENERGY_PROTEIN - carbohydrates * ENERGY_CARBOHYDRATES) / ENERGY_FAT;
        assert(fat > 0);
      }
    }
    return NutritionalGoals._(
      energy: energy,
      protein: protein,
      carbohydrates: carbohydrates,
      carbohydratesSugar: carbohydratesSugar,
      fat: fat,
      fatSaturated: fatSaturated,
      fibres: fibres,
      sodium: sodium,
    );
  }

  NutritionalGoals._({
    this.energy,
    this.protein,
    this.carbohydrates,
    this.carbohydratesSugar,
    this.fat,
    this.fatSaturated,
    this.fibres,
    this.sodium,
  });

  NutritionalGoals operator /(double v) {
    return NutritionalGoals(
      energy: energy != null ? energy! / v : null,
      protein: protein != null ? protein! / v : null,
      carbohydrates: carbohydrates != null ? carbohydrates! / v : null,
      carbohydratesSugar: carbohydratesSugar != null ? carbohydratesSugar! / v : null,
      fat: fat != null ? fat! / v : null,
      fatSaturated: fatSaturated != null ? fatSaturated! / v : null,
      fibres: fibres != null ? fibres! / v : null,
      sodium: sodium != null ? sodium! / v : null,
    );
  }

  bool isComplete() {
    return energy != null && protein != null && carbohydrates != null && fat != null;
  }

  /// Convert goals into values.
  /// This turns unset goals into values of 0.
  /// Only use this if you know what you're doing, e.g. if isComplete() is true
  NutritionalValues toValues() {
    return NutritionalValues.values(
      energy ?? 0,
      protein ?? 0,
      carbohydrates ?? 0,
      carbohydratesSugar ?? 0,
      fat ?? 0,
      fatSaturated ?? 0,
      fibres ?? 0,
      sodium ?? 0,
    );
  }

  /// Calculates the percentage each macro nutrient adds to the total energy
  NutritionalGoals energyPercentage() {
    final goals = NutritionalGoals();
    if (energy == null) {
      return goals;
    }
    assert(energy! > 0);

    double? proteinPct;
    double? carbohydratesPct;
    double? fatPct;

    if (protein != null) {
      proteinPct = (100 * protein! * ENERGY_PROTEIN) / energy!;
    }
    if (carbohydrates != null) {
      carbohydratesPct = (100 * carbohydrates! * ENERGY_CARBOHYDRATES) / energy!;
    }
    if (fat != null) {
      fatPct = (100 * fat! * ENERGY_FAT) / energy!;
    }
    return NutritionalGoals._(
      energy: energy,
      protein: proteinPct,
      carbohydrates: carbohydratesPct,
      fat: fatPct,
    );
  }

  double? prop(String name) {
    return switch (name) {
      'energy' => energy,
      'protein' => protein,
      'carbohydrates' => carbohydrates,
      'carbohydratesSugar' => carbohydratesSugar,
      'fat' => fat,
      'fatSaturated' => fatSaturated,
      'fibres' => fibres,
      'sodium' => sodium,
      _ => 0,
    };
  }
}
