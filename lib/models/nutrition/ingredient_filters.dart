//model is used to store ingredient filters values
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/providers/nutrition.dart';

class IngredientFilters {
  final bool isVegan;
  final bool isVegetarian;
  final IngredientSearchLanguage searchLanguage;

  /// Worst acceptable Nutri-Score grade, sent to the backend as
  /// `nutriscore__lte`. `null` means the filter is off (slider at the
  /// "No filter" position).
  final NutriScore? nutriscoreMax;

  IngredientFilters({
    required this.isVegan,
    required this.isVegetarian,
    required this.searchLanguage,
    this.nutriscoreMax,
  });

  IngredientFilters copyWith({
    bool? isVegan,
    bool? isVegetarian,
    IngredientSearchLanguage? searchLanguage,
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
}
