import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/util/legacy_to_async_migration_util.dart';
import 'package:wger/core/search_options.dart';
import 'package:wger/features/exercises/models/exercise_filters.dart';
import 'package:wger/features/nutrition/models/ingredient.dart';
import 'package:wger/features/nutrition/models/ingredient_filters.dart';

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
  /// `migrationCompletedKey` is used to track if the migration has been
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
  Future<void> saveIngredientSearchLanguage(SearchLanguage language) async {
    await PreferenceHelper.asyncPref.setString('search_language', language.name);
  }

  Future<SearchLanguage> getIngredientSearchLanguage() async {
    const fallback = IngredientFilters();
    final value = await PreferenceHelper.asyncPref.getString('search_language');
    if (value == null) {
      return fallback.searchLanguage;
    } else {
      return SearchLanguage.values.firstWhere(
        (e) => e.name == value,
        orElse: () => fallback.searchLanguage,
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

  // --- Exercise search filters ---

  Future<void> saveExerciseSearchLanguage(SearchLanguage language) async {
    await PreferenceHelper.asyncPref.setString(
      'exercise_search_language',
      language.name,
    );
  }

  Future<SearchLanguage> getExerciseSearchLanguage() async {
    const fallback = ExerciseFilters();
    final value = await PreferenceHelper.asyncPref.getString('exercise_search_language');
    if (value == null) {
      return fallback.searchLanguage;
    }
    return SearchLanguage.values.firstWhere(
      (e) => e.name == value,
      orElse: () => fallback.searchLanguage,
    );
  }

  Future<void> saveExerciseSearchMode(ExerciseSearchMode mode) async {
    await PreferenceHelper.asyncPref.setString(
      'exercise_search_mode',
      mode.name,
    );
  }

  Future<ExerciseSearchMode> getExerciseSearchMode() async {
    const fallback = ExerciseFilters();
    final value = await PreferenceHelper.asyncPref.getString('exercise_search_mode');
    if (value == null) {
      return fallback.searchMode;
    }
    return ExerciseSearchMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => fallback.searchMode,
    );
  }

  // --- Health sync ---

  static const _healthSyncEnabledKey = 'healthSyncEnabled';
  static const _healthSyncWatermarksKey = 'healthSyncWatermarks';
  static const _healthSyncReadableTypesKey = 'healthSyncReadableTypes';
  static const _healthSyncEmptyMetricsKey = 'healthSyncEmptyMetrics';
  static const _healthSyncLastRunKey = 'healthSyncLastRun';

  Future<void> setHealthSyncEnabled(bool value) async {
    await PreferenceHelper.asyncPref.setBool(_healthSyncEnabledKey, value);
  }

  Future<bool> getHealthSyncEnabled() async {
    final value = await PreferenceHelper.asyncPref.getBool(_healthSyncEnabledKey);
    return value ?? false;
  }

  /// How far each metric has been imported, keyed by `MetricType.name` and
  /// held as ISO-8601 timestamps.
  ///
  /// Per metric rather than one for all of them, so an import interrupted
  /// halfway resumes where each metric got to instead of starting over, and
  /// so that a metric that cannot be imported holds nobody else back.
  Future<void> setHealthSyncWatermarks(Map<String, String> value) async {
    await PreferenceHelper.asyncPref.setString(_healthSyncWatermarksKey, jsonEncode(value));
  }

  Future<Map<String, String>> getHealthSyncWatermarks() async {
    final stored = await PreferenceHelper.asyncPref.getString(_healthSyncWatermarksKey);
    if (stored == null) {
      return {};
    }
    return (jsonDecode(stored) as Map<String, dynamic>).cast<String, String>();
  }

  /// The health data types the platform let us read during the last sync.
  ///
  /// A type that was not readable then has no history in wger, so the sync
  /// reads the full window once it becomes readable, instead of starting at
  /// the watermark and leaving everything before it missing.
  Future<void> setHealthSyncReadableTypes(List<String> value) async {
    await PreferenceHelper.asyncPref.setStringList(_healthSyncReadableTypesKey, value);
  }

  Future<List<String>?> getHealthSyncReadableTypes() async {
    return PreferenceHelper.asyncPref.getStringList(_healthSyncReadableTypesKey);
  }

  /// The metrics the platform had nothing at all for when their full history
  /// was last read.
  ///
  /// Such a metric never gets a category, and a missing category is what sends
  /// the sync back to the full window; without this it would do so on every
  /// run, for every metric.
  Future<void> setHealthSyncEmptyMetrics(List<String> value) async {
    await PreferenceHelper.asyncPref.setStringList(_healthSyncEmptyMetricsKey, value);
  }

  Future<List<String>?> getHealthSyncEmptyMetrics() async {
    return PreferenceHelper.asyncPref.getStringList(_healthSyncEmptyMetricsKey);
  }

  /// When the last import finished, as an ISO-8601 timestamp.
  ///
  /// Persisted rather than kept in memory: the automatic syncs are throttled
  /// against it, and an app restart would otherwise always look like the first
  /// run of the day.
  Future<void> setHealthSyncLastRun(DateTime value) async {
    await PreferenceHelper.asyncPref.setString(_healthSyncLastRunKey, value.toIso8601String());
  }

  Future<DateTime?> getHealthSyncLastRun() async {
    final stored = await PreferenceHelper.asyncPref.getString(_healthSyncLastRunKey);
    return stored == null ? null : DateTime.tryParse(stored);
  }

  Future<void> clearHealthSyncPreferences() async {
    await PreferenceHelper.asyncPref.remove(_healthSyncEnabledKey);
    await PreferenceHelper.asyncPref.remove(_healthSyncWatermarksKey);
    await PreferenceHelper.asyncPref.remove(_healthSyncReadableTypesKey);
    await PreferenceHelper.asyncPref.remove(_healthSyncEmptyMetricsKey);
    await PreferenceHelper.asyncPref.remove(_healthSyncLastRunKey);
  }
}
