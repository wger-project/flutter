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

class NutritionalValues {
  double energy = 0;
  double protein = 0;
  double carbohydrates = 0;
  double carbohydratesSugar = 0;
  double fat = 0;
  double fatSaturated = 0;
  double fiber = 0;
  double sodium = 0;

  NutritionalValues();

  NutritionalValues.values(
    this.energy,
    this.protein,
    this.carbohydrates,
    this.carbohydratesSugar,
    this.fat,
    this.fatSaturated,
    this.fiber,
    this.sodium,
  );

  /// Convert to kilo joules
  double get energyKj {
    return energy * 4.184;
  }

  void add(NutritionalValues data) {
    energy += data.energy;
    protein += data.protein;
    carbohydrates += data.carbohydrates;
    carbohydratesSugar += data.carbohydratesSugar;
    fat += data.fat;
    fatSaturated += data.fatSaturated;
    fiber += data.fiber;
    sodium += data.sodium;
  }

  NutritionalValues operator +(NutritionalValues o) {
    return NutritionalValues.values(
      energy + o.energy,
      protein + o.protein,
      carbohydrates + o.carbohydrates,
      carbohydratesSugar + o.carbohydratesSugar,
      fat + o.fat,
      fatSaturated + o.fatSaturated,
      fiber + o.fiber,
      sodium + o.sodium,
    );
  }

  NutritionalValues operator /(double o) {
    return NutritionalValues.values(
      energy / o,
      protein / o,
      carbohydrates / o,
      carbohydratesSugar / o,
      fat / o,
      fatSaturated / o,
      fiber / o,
      sodium / o,
    );
  }

  @override
  //ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(other) {
    return other is NutritionalValues &&
        energy == other.energy &&
        protein == other.protein &&
        carbohydrates == other.carbohydrates &&
        carbohydratesSugar == other.carbohydratesSugar &&
        fat == other.fat &&
        fatSaturated == other.fatSaturated &&
        fiber == other.fiber &&
        sodium == other.sodium;
  }

  double prop(String name) {
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
}
