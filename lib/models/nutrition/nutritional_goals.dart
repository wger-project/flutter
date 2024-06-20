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

import 'package:wger/helpers/consts.dart';
import 'package:wger/models/nutrition/nutritional_values.dart';

class NutritionalGoals {
  double? energy = 0;
  double? protein = 0;
  double? carbohydrates = 0;
  double? carbohydratesSugar = 0;
  double? fat = 0;
  double? fatSaturated = 0;
  double? fiber = 0;
  double? sodium = 0;

  NutritionalGoals({
    this.energy,
    this.protein,
    this.carbohydrates,
    this.carbohydratesSugar,
    this.fat,
    this.fatSaturated,
    this.fiber,
    this.sodium,
  }) {
    // infer values where we can
    if (energy == null) {
      if (protein != null && carbohydrates != null && fat != null) {
        energy =
            protein! * ENERGY_PROTEIN + carbohydrates! * ENERGY_CARBOHYDRATES + fat! * ENERGY_FAT;
      }
      return;
    }
    // TODO: input validation when the user modifies/creates the plan, to assure energy is high enough
    if (protein == null && carbohydrates != null && fat != null) {
      protein =
          (energy! - carbohydrates! * ENERGY_CARBOHYDRATES - fat! * ENERGY_FAT) / ENERGY_PROTEIN;
      assert(protein! > 0);
    } else if (carbohydrates == null && protein != null && fat != null) {
      carbohydrates =
          (energy! - protein! * ENERGY_PROTEIN - fat! * ENERGY_FAT) / ENERGY_CARBOHYDRATES;
      assert(carbohydrates! > 0);
    } else if (fat == null && protein != null && carbohydrates != null) {
      fat = (energy! - protein! * ENERGY_PROTEIN - carbohydrates! * ENERGY_CARBOHYDRATES) /
          ENERGY_FAT;
      assert(fat! > 0);
    }
  }

  NutritionalGoals operator /(double v) {
    return NutritionalGoals(
      energy: energy != null ? energy! / v : null,
      protein: protein != null ? protein! / v : null,
      carbohydrates: carbohydrates != null ? carbohydrates! / v : null,
      carbohydratesSugar: carbohydratesSugar != null ? carbohydratesSugar! / v : null,
      fat: fat != null ? fat! / v : null,
      fatSaturated: fatSaturated != null ? fatSaturated! / v : null,
      fiber: fiber != null ? fiber! / v : null,
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
      fiber ?? 0,
      sodium ?? 0,
    );
  }

  /// Calculates the percentage each macro nutrient adds to the total energy
  NutritionalGoals energyPercentage() {
    final goals = NutritionalGoals();
    // when you create a new plan or meal, somehow goals like energy is set to 0
    // whereas strictly speaking it should be null. However,
    // we know the intention so treat 0 as null here.
    if (energy == null || energy == 0) {
      return goals;
    }

    if (protein != null) {
      goals.protein = (100 * protein! * ENERGY_PROTEIN) / energy!;
    }
    if (carbohydrates != null) {
      goals.carbohydrates = (100 * carbohydrates! * ENERGY_CARBOHYDRATES) / energy!;
    }
    if (fat != null) {
      goals.fat = (100 * fat! * ENERGY_FAT) / energy!;
    }
    return goals;
  }

  double? prop(String name) {
    return switch (name) {
      'energy' => energy,
      'protein' => protein,
      'carbohydrates' => carbohydrates,
      'carbohydratesSugar' => carbohydratesSugar,
      'fat' => fat,
      'fatSaturated' => fatSaturated,
      'fiber' => fiber,
      'sodium' => sodium,
      _ => 0,
    };
  }

  @override
  String toString() {
    return 'e: $energy, p: $protein, c: $carbohydrates, cS: $carbohydratesSugar, f: $fat, fS: $fatSaturated, fi: $fiber, s: $sodium';
  }

  @override
  //ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => Object.hash(
        energy,
        protein,
        carbohydrates,
        carbohydratesSugar,
        fat,
        fatSaturated,
        fiber,
        sodium,
      );

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is NutritionalGoals &&
        other.energy == energy &&
        other.protein == protein &&
        other.carbohydrates == carbohydrates &&
        other.carbohydratesSugar == carbohydratesSugar &&
        other.fat == fat &&
        other.fatSaturated == fatSaturated &&
        other.fiber == fiber &&
        other.sodium == sodium;
  }
}
