//model is used to store ingredient filters values
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/providers/nutrition.dart';

class IngredientFilters {
  final bool isVegan;
  final bool isVegetarian;
  final IngredientSearchLanguage searchLanguage;

  /// When true, [nutriscoreMax] is applied as `nutriscore__lte` on the search.
  final bool filterNutriscore;

  /// Worst acceptable Nutri-Score grade (lexicographically sent as
  /// `nutriscore__lte` to the backend). Ignored when [filterNutriscore] is
  /// false.
  final NutriScore nutriscoreMax;

  IngredientFilters({
    required this.isVegan,
    required this.isVegetarian,
    required this.searchLanguage,
    this.filterNutriscore = false,
    this.nutriscoreMax = NutriScore.c,
  });

  IngredientFilters copyWith({
    bool? isVegan,
    bool? isVegetarian,
    IngredientSearchLanguage? searchLanguage,
    bool? filterNutriscore,
    NutriScore? nutriscoreMax,
  }) {
    return IngredientFilters(
      isVegan: isVegan ?? this.isVegan,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      searchLanguage: searchLanguage ?? this.searchLanguage,
      filterNutriscore: filterNutriscore ?? this.filterNutriscore,
      nutriscoreMax: nutriscoreMax ?? this.nutriscoreMax,
    );
  }
}
