import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/util/legacy_to_async_migration_util.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/providers/nutrition.dart';

/// A helper class that manages preferences using SharedPreferencesAsync
/// and handles migration from the legacy SharedPreferences to
/// SharedPreferencesAsync.
class PreferenceHelper {
  SharedPreferencesAsync _asyncPref = SharedPreferencesAsync();

  PreferenceHelper._instantiate();

  static final PreferenceHelper _instance = PreferenceHelper._instantiate();

  static SharedPreferencesAsync get asyncPref => _instance._asyncPref;

  static PreferenceHelper get instance => _instance;

  /// Migration function that ensures any legacy data stored in
  /// SharedPreferences is migrated to SharedPreferencesAsync. This migration
  /// only happens once, as checked by the migrationCompletedKey.
  ///
  /// [migrationCompletedKey] is used to track if the migration has been
  /// completed.
  Future<void> migrationSupportFunctionForSharedPreferences() async {
    const SharedPreferencesOptions sharedPreferencesOptions = SharedPreferencesOptions();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await migrateLegacySharedPreferencesToSharedPreferencesAsyncIfNecessary(
      legacySharedPreferencesInstance: prefs,
      sharedPreferencesAsyncOptions: sharedPreferencesOptions,
      migrationCompletedKey: 'migrationCompleted',
    );
    _asyncPref = SharedPreferencesAsync();
  }

  //ingredients filters
  //1.vegan
  Future<void> saveIngredientVeganFilter(bool value) async {
    await PreferenceHelper.asyncPref.setBool('ingredientVeganFilter', value);
  }

  Future<bool> getIngredientVeganFilter() async {
    return await PreferenceHelper.asyncPref.getBool('ingredientVeganFilter') ?? false;
  }

  //2.vegetarian
  Future<void> saveIngredientVegetarianFilter(bool value) async {
    await PreferenceHelper.asyncPref.setBool('ingredientVegetarianFilter', value);
  }

  Future<bool> getIngredientVegetarianFilter() async {
    return await PreferenceHelper.asyncPref.getBool('ingredientVegetarianFilter') ?? false;
  }

  //3.language
  Future<void> saveIngredientSearchLanguage(IngredientSearchLanguage language) async {
    await PreferenceHelper.asyncPref.setString('search_language', language.name);
  }

  Future<IngredientSearchLanguage> getIngredientSearchLanguage() async {
    final value = await PreferenceHelper.asyncPref.getString('search_language');
    if (value == null) {
      return IngredientSearchLanguage.currentAndEnglish;
    } else {
      return IngredientSearchLanguage.values.firstWhere(
        (e) => e.name == value,
        orElse: () => IngredientSearchLanguage.currentAndEnglish,
      );
    }
  }

  //4.nutri-score worst acceptable grade (null means the filter is off)
  Future<void> saveIngredientNutriscoreMax(NutriScore? value) async {
    if (value == null) {
      await PreferenceHelper.asyncPref.remove('ingredientNutriscoreMax');
    } else {
      await PreferenceHelper.asyncPref.setString('ingredientNutriscoreMax', value.name);
    }
  }

  Future<NutriScore?> getIngredientNutriscoreMax() async {
    final value = await PreferenceHelper.asyncPref.getString('ingredientNutriscoreMax');
    if (value == null) {
      return null;
    }
    return NutriScore.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NutriScore.c,
    );
  }
}
