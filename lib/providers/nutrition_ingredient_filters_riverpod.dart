/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 - 2026 wger Team
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

import 'package:flutter_riverpod/flutter_riverpod.dart' show Provider;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/helpers/shared_preferences.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/models/nutrition/ingredient_filters.dart';
import 'package:wger/providers/nutrition.dart';

part 'nutrition_ingredient_filters_riverpod.g.dart';

@riverpod
class IngredientFiltersNotifier extends _$IngredientFiltersNotifier {
  @override
  Future<IngredientFilters> build() async {
    final preferenceHelper = PreferenceHelper.instance;

    final isVegan = await preferenceHelper.getIngredientVeganFilter();
    final isVegetarian = await preferenceHelper.getIngredientVegetarianFilter();
    final searchLanguage = await preferenceHelper.getIngredientSearchLanguage();
    final filterNutriscore = await preferenceHelper.getIngredientFilterNutriscore();
    final nutriscoreMax = await preferenceHelper.getIngredientNutriscoreMax();
    return IngredientFilters(
      isVegan: isVegan,
      isVegetarian: isVegetarian,
      searchLanguage: searchLanguage,
      filterNutriscore: filterNutriscore,
      nutriscoreMax: nutriscoreMax,
    );
  }

  // Return the current IngredientFilters value or a single canonical default.
  IngredientFilters _current() {
    return state.asData?.value ??
        IngredientFilters(
          isVegan: false,
          isVegetarian: false,
          searchLanguage: IngredientSearchLanguage.current,
        );
  }

  Future<void> toggleVegan(bool value) async {
    final current = _current();
    state = AsyncData(current.copyWith(isVegan: value));
    await PreferenceHelper.instance.saveIngredientVeganFilter(value);
  }

  Future<void> toggleVegetarian(bool value) async {
    final current = _current();
    state = AsyncData(current.copyWith(isVegetarian: value));
    await PreferenceHelper.instance.saveIngredientVegetarianFilter(value);
  }

  Future<void> chooseLanguage(IngredientSearchLanguage value) async {
    final current = _current();
    state = AsyncData(current.copyWith(searchLanguage: value));
    await PreferenceHelper.instance.saveIngredientSearchLanguage(value);
  }

  Future<void> toggleNutriscore(bool value) async {
    final current = _current();
    state = AsyncData(current.copyWith(filterNutriscore: value));
    await PreferenceHelper.instance.saveIngredientFilterNutriscore(value);
  }

  Future<void> chooseNutriscoreMax(NutriScore value) async {
    final current = _current();
    state = AsyncData(current.copyWith(nutriscoreMax: value));
    await PreferenceHelper.instance.saveIngredientNutriscoreMax(value);
  }
}

// Synchronous helper provider to unwrap the AsyncValue produced by `ingredientFiltersProvider`
final ingredientFiltersSyncProvider = Provider<IngredientFilters>((ref) {
  final async = ref.watch(ingredientFiltersProvider);
  return async.asData?.value ??
      IngredientFilters(
        isVegan: false,
        isVegetarian: false,
        searchLanguage: IngredientSearchLanguage.current,
      );
});
