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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:wger/helpers/shared_preferences.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/providers/nutrition_ingredient_filters_riverpod.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
  });

  test('changing vegan filter updates provider and saves value', () async {
    // Arrange
    final container = ProviderContainer.test();
    await container.read(ingredientFiltersProvider.future);
    final notifier = container.read(ingredientFiltersProvider.notifier);
    var filters = await container.read(ingredientFiltersProvider.future);
    expect(filters.isVegan, false);
    expect(filters.isVegetarian, false);
    expect(filters.searchLanguage, IngredientSearchLanguage.currentAndEnglish);

    // Act
    await notifier.toggleVegan(true);
    await notifier.toggleVegetarian(true);
    await notifier.chooseLanguage(IngredientSearchLanguage.all);

    // Assert
    filters = await container.read(ingredientFiltersProvider.future);
    expect(filters.isVegan, true);
    expect(filters.isVegetarian, true);
    expect(filters.searchLanguage, IngredientSearchLanguage.all);

    expect(await PreferenceHelper.instance.getIngredientVeganFilter(), true);
    expect(await PreferenceHelper.instance.getIngredientVeganFilter(), true);
    expect(
      await PreferenceHelper.instance.getIngredientSearchLanguage(),
      IngredientSearchLanguage.all,
    );
  });
}
