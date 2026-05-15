//model is used to store ingredient filters values
import 'package:wger/helpers/consts.dart';
import 'package:wger/models/core/search_options.dart';
import 'package:wger/models/nutrition/ingredient.dart';

class IngredientFilters {
  final bool isVegan;
  final bool isVegetarian;
  final SearchLanguage searchLanguage;

  /// Worst acceptable Nutri-Score grade, sent to the backend as
  /// `nutriscore__lte`. `null` means the filter is off (slider at the
  /// "No filter" position).
  final NutriScore? nutriscoreMax;

  const IngredientFilters({
    this.isVegan = false,
    this.isVegetarian = false,
    this.searchLanguage = SearchLanguage.currentAndEnglish,
    this.nutriscoreMax,
  });

  /// Locale-aware default filter set.
  ///
  /// In an English locale "current + English" collapses to "current", there
  /// is no extra fallback to add. Everywhere else, falling back to English is
  /// the default. All other fields take the constructor defaults.
  factory IngredientFilters.defaultFor(String localeCode) => IngredientFilters(
    searchLanguage: localeCode == LANGUAGE_SHORT_ENGLISH
        ? SearchLanguage.current
        : SearchLanguage.currentAndEnglish,
  );

  IngredientFilters copyWith({
    bool? isVegan,
    bool? isVegetarian,
    SearchLanguage? searchLanguage,
    NutriScore? nutriscoreMax,
    bool clearNutriscoreMax = false,
  }) {
    return IngredientFilters(
      isVegan: isVegan ?? this.isVegan,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      searchLanguage: searchLanguage ?? this.searchLanguage,
      nutriscoreMax: clearNutriscoreMax ? null : (nutriscoreMax ?? this.nutriscoreMax),
    );
  }

  /// Number of fields that deviate from the locale-aware defaults.
  ///
  /// Used to surface "filters are active" feedback in the UI (e.g. as a badge
  /// on the filter icon).
  int activeFilterCount(String currentLocaleCode) {
    final defaults = IngredientFilters.defaultFor(currentLocaleCode);
    var count = 0;
    if (isVegan != defaults.isVegan) {
      count++;
    }
    if (isVegetarian != defaults.isVegetarian) {
      count++;
    }
    if (searchLanguage != defaults.searchLanguage) {
      count++;
    }
    if (nutriscoreMax != defaults.nutriscoreMax) {
      count++;
    }
    return count;
  }
}
