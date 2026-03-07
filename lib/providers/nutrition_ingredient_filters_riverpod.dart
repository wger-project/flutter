import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wger/helpers/shared_preferences.dart';
import 'package:wger/models/nutrition/ingredient_filters.dart';
import 'package:wger/providers/nutrition.dart';

class IngredientFiltersNotifier extends Notifier<IngredientFilters> {
  final bool initialVegan;
  final bool initialVegetarian;
  final IngredientSearchLanguage initialSearchLanguage;
  IngredientFiltersNotifier({
    required this.initialVegan,
    required this.initialVegetarian,
    required this.initialSearchLanguage,
  });
  @override
  IngredientFilters build() {
    return IngredientFilters(
      isVegan: initialVegan,
      isVegetarian: initialVegetarian,
      searchLanguage: initialSearchLanguage,
    );
  }

  Future<void> toggleVegan(bool value) async {
    state = state.copyWith(isVegan: value);
    await PreferenceHelper.instance.saveIngredientVeganFilter(value);
  }

  Future<void> toggleVegetarian(bool value) async {
    state = state.copyWith(isVegetarian: value);
    await PreferenceHelper.instance.saveIngredientVegetarianFilter(value);
  }

  Future<void> chooseLanguage(IngredientSearchLanguage value) async {
    state = state.copyWith(searchLanguage: value);
    await PreferenceHelper.instance.saveIngredientSearchLanguage(value);
  }
}

// provider for notifier
final ingredientFiltersNotifierProvider =
    NotifierProvider<IngredientFiltersNotifier, IngredientFilters>(
      () => IngredientFiltersNotifier(
        initialVegan: false,
        initialVegetarian: false,
        initialSearchLanguage: IngredientSearchLanguage.current,
      ),
    );
