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
    final container = ProviderContainer(
      overrides: [
        ingredientFiltersNotifierProvider.overrideWith(
          () => IngredientFiltersNotifier(
            initialVegan: false,
            initialVegetarian: false,
            initialSearchLanguage: IngredientSearchLanguage.current,
          ),
        ),
      ],
    );

    addTearDown(container.dispose);

    await container.read(ingredientFiltersNotifierProvider.notifier).toggleVegan(true);

    expect(
      container.read(ingredientFiltersNotifierProvider).isVegan,
      true,
    );
    final savedValue = await PreferenceHelper.instance.getIngredientVeganFilter();

    expect(savedValue, true);
  });
}
