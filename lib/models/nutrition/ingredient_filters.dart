//model is used to store ingredient filters values
import 'package:wger/providers/nutrition_repository.dart';

class IngredientFilters {
  final bool isVegan;
  final bool isVegetarian;
  final IngredientSearchLanguage searchLanguage;
  IngredientFilters({
    required this.isVegan,
    required this.isVegetarian,
    required this.searchLanguage,
  });

  IngredientFilters copyWith({
    bool? isVegan,
    bool? isVegetarian,
    IngredientSearchLanguage? searchLanguage,
  }) {
    return IngredientFilters(
      isVegan: isVegan ?? this.isVegan,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      searchLanguage: searchLanguage ?? this.searchLanguage,
    );
  }
}
