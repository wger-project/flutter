/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
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

import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/core/exceptions/http_exception.dart';
import 'package:wger/core/exceptions/no_such_entry_exception.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/models/nutrition/ingredient_image.dart';
import 'package:wger/models/nutrition/ingredient_weight_unit.dart';
import 'package:wger/models/nutrition/log.dart';
import 'package:wger/models/nutrition/meal.dart';
import 'package:wger/models/nutrition/meal_item.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/providers/ingredient_repository.dart';
import 'package:wger/providers/nutrition_repository.dart';

part 'nutrition_notifier.g.dart';

@Riverpod(keepAlive: true)
class NutritionNotifier extends _$NutritionNotifier {
  final _logger = Logger('NutritionNotifier');

  late IngredientRepository _ingredientRepo;
  late NutritionRepository _nutritionRepo;

  @override
  Future<List<NutritionalPlan>> build() async {
    _nutritionRepo = ref.read(nutritionRepositoryProvider);
    _ingredientRepo = ref.read(ingredientRepositoryProvider);

    // Auto-fetch the sparse plan list on first read. Consumers that need
    // a forced refresh (e.g. RefreshIndicator) can still call
    // [fetchAndSetAllPlansSparse] explicitly.
    final data = await _nutritionRepo.fetchAllPlans();
    return data.map((e) => NutritionalPlan.fromJson(e)).toList()
      ..sort((a, b) => b.creationDate.compareTo(a.creationDate));
  }

  List<NutritionalPlan> get _plans => state.asData?.value ?? [];

  void _setPlans(List<NutritionalPlan> plans) {
    state = AsyncData(List.of(plans));
  }

  /// Notifies listeners after in-place mutation on the plans list (e.g. when
  /// meals or logs on a plan are mutated via object references). Equivalent to
  /// the old `notifyListeners()`.
  void _notifyAfterInPlaceMutation() {
    _setPlans(_plans);
  }

  /// Returns the current active nutritional plan.
  ///
  /// A plan is considered active if its start date is before now and its end
  /// date is after now (or not set). With multiple matches, the most recently
  /// created plan wins.
  NutritionalPlan? get currentPlan {
    final now = DateTime.now();
    return _plans
        .where(
          (plan) =>
              plan.startDate.isBefore(now) && (plan.endDate == null || plan.endDate!.isAfter(now)),
        )
        .toList()
        .sorted((a, b) => b.creationDate.compareTo(a.creationDate))
        .firstOrNull;
  }

  NutritionalPlan findById(int id) {
    return _plans.firstWhere(
      (plan) => plan.id == id,
      orElse: () => throw const NoSuchEntryException(),
    );
  }

  Meal? findMealById(int id) {
    for (final plan in _plans) {
      final meal = plan.meals.firstWhereOrNull((m) => m.id == id);
      if (meal != null) {
        return meal;
      }
    }
    return null;
  }

  /// Clears all plans. Called on logout.
  void clear() {
    _setPlans([]);
  }

  // --- Plans ---

  /// Fetches all plans sparsely (no meals, items or logs).
  Future<void> fetchAndSetAllPlansSparse() async {
    final data = await _nutritionRepo.fetchAllPlans();
    final plans = data.map((e) => NutritionalPlan.fromJson(e)).toList()
      ..sort((a, b) => b.creationDate.compareTo(a.creationDate));
    _setPlans(plans);
  }

  Future<void> fetchAndSetAllPlansFull() async {
    final data = await _nutritionRepo.fetchAllPlans();
    await Future.wait(data.map((e) => fetchAndSetPlanFull(e['id'])).toList());
  }

  Future<NutritionalPlan> fetchAndSetPlanSparse(int planId) async {
    final data = await _nutritionRepo.fetchPlanSparse(planId);
    final plan = NutritionalPlan.fromJson(data);
    final plans = List<NutritionalPlan>.of(_plans)..add(plan);
    plans.sort((a, b) => b.creationDate.compareTo(a.creationDate));
    _setPlans(plans);
    return plan;
  }

  /// Fetches a plan with meals, meal items, and log entries.
  Future<NutritionalPlan> fetchAndSetPlanFull(int planId) async {
    _logger.fine('Fetching full nutritional plan $planId');

    NutritionalPlan plan;
    try {
      plan = findById(planId);
    } on NoSuchEntryException {
      plan = await fetchAndSetPlanSparse(planId);
    }

    final fullPlanData = await _nutritionRepo.fetchPlanFull(planId);

    // Meals
    final List<Meal> meals = [];
    for (final mealData in fullPlanData['meals']) {
      final List<MealItem> mealItems = [];
      final meal = Meal.fromJson(mealData);

      for (final mealItemData in mealData['meal_items']) {
        final mealItem = MealItem.fromJson(mealItemData);

        final ingredient = Ingredient.fromJson(mealItemData['ingredient_obj']);
        if (mealItemData['image'] != null) {
          ingredient.image = IngredientImage.fromJson(mealItemData['image']);
        }
        mealItem.ingredient = ingredient;
        mealItems.add(mealItem);
      }
      meal.mealItems = mealItems;
      meals.add(meal);
    }
    plan.meals = meals;

    // Logs
    await fetchAndSetLogs(plan);
    for (final meal in meals) {
      meal.diaryEntries = plan.diaryEntries.where((e) => e.mealId == meal.id).toList();
    }

    _notifyAfterInPlaceMutation();
    return plan;
  }

  Future<NutritionalPlan> addPlan(NutritionalPlan planData) async {
    final data = await _nutritionRepo.createPlan(planData.toJson());
    final plan = NutritionalPlan.fromJson(data);
    final plans = List<NutritionalPlan>.of(_plans)..add(plan);
    plans.sort((a, b) => b.creationDate.compareTo(a.creationDate));
    _setPlans(plans);
    return plan;
  }

  Future<void> editPlan(NutritionalPlan plan) async {
    await _nutritionRepo.updatePlan(plan.id!, plan.toJson());
    _notifyAfterInPlaceMutation();
  }

  Future<void> deletePlan(int id) async {
    final plans = List<NutritionalPlan>.of(_plans);
    final index = plans.indexWhere((element) => element.id == id);
    final existing = plans[index];
    plans.removeAt(index);
    _setPlans(plans);

    final response = await _nutritionRepo.deletePlan(id);

    if (response.statusCode >= 400) {
      plans.insert(index, existing);
      _setPlans(plans);
      throw WgerHttpException(response);
    }
  }

  // --- Meals ---

  Future<Meal> addMeal(Meal meal, int planId) async {
    final plan = findById(planId);
    meal.planId = planId;
    final data = await _nutritionRepo.createMeal(meal.toJson());
    final saved = Meal.fromJson(data);
    plan.meals.add(saved);
    _notifyAfterInPlaceMutation();
    return saved;
  }

  Future<Meal> editMeal(Meal meal) async {
    final data = await _nutritionRepo.updateMeal(meal.id!, meal.toJson());
    final updated = Meal.fromJson(data);
    _notifyAfterInPlaceMutation();
    return updated;
  }

  Future<void> deleteMeal(Meal meal) async {
    final plan = findById(meal.planId);
    final mealIndex = plan.meals.indexWhere((e) => e.id == meal.id);
    final existing = plan.meals[mealIndex];
    plan.meals.removeAt(mealIndex);
    _notifyAfterInPlaceMutation();

    final response = await _nutritionRepo.deleteMeal(meal.id!);
    if (response.statusCode >= 400) {
      plan.meals.insert(mealIndex, existing);
      _notifyAfterInPlaceMutation();
      throw WgerHttpException(response);
    }
  }

  // --- Meal items ---

  Future<MealItem> addMealItem(MealItem mealItem, Meal meal) async {
    final data = await _nutritionRepo.createMealItem(mealItem.toJson());
    final saved = MealItem.fromJson(data);
    saved.ingredient = await fetchIngredient(saved.ingredientId);
    meal.mealItems.add(saved);
    _notifyAfterInPlaceMutation();
    return saved;
  }

  Future<void> deleteMealItem(MealItem mealItem) async {
    final meal = findMealById(mealItem.mealId)!;
    final mealItemIndex = meal.mealItems.indexWhere((e) => e.id == mealItem.id);
    final existing = meal.mealItems[mealItemIndex];
    meal.mealItems.removeAt(mealItemIndex);
    _notifyAfterInPlaceMutation();

    final response = await _nutritionRepo.deleteMealItem(mealItem.id!);
    if (response.statusCode >= 400) {
      meal.mealItems.insert(mealItemIndex, existing);
      _notifyAfterInPlaceMutation();
      throw WgerHttpException(response);
    }
  }

  // --- Ingredients ---

  /// Looks up an ingredient by id.
  ///
  /// Tries PowerSync-backed local storage first and only hits the server if the
  /// ingredient has not been synced yet.
  Future<Ingredient> fetchIngredient(int ingredientId) async {
    final local = await _ingredientRepo.getById(ingredientId);
    if (local != null) {
      _logger.finer("Loaded ingredient '${local.name}' from PowerSync");
      return local;
    }
    return _nutritionRepo.fetchIngredient(ingredientId);
  }

  Future<List<Ingredient>> searchIngredient(
    String name, {
    String languageCode = 'en',
    IngredientSearchLanguage searchLanguage = IngredientSearchLanguage.current,
    bool isVegan = false,
    bool isVegetarian = false,
  }) {
    return _nutritionRepo.searchIngredient(
      name,
      languageCode: languageCode,
      searchLanguage: searchLanguage,
      isVegan: isVegan,
      isVegetarian: isVegetarian,
    );
  }

  Future<Ingredient?> searchIngredientWithBarcode(String barcode) {
    return _nutritionRepo.searchIngredientWithBarcode(barcode);
  }

  Future<List<IngredientWeightUnit>> fetchWeightUnits(int ingredientId) {
    return _nutritionRepo.fetchWeightUnits(ingredientId);
  }

  // --- Logs (nutrition diary) ---

  Future<void> logMealToDiary(Meal meal, DateTime mealDateTime) async {
    final plan = findById(meal.planId);
    for (final item in meal.mealItems) {
      final log = Log.fromMealItem(item, plan.id!, meal.id, mealDateTime);
      final data = await _nutritionRepo.createLog(log.toJson());
      log.id = data['id'];
      plan.diaryEntries.add(log);
    }
    _notifyAfterInPlaceMutation();
  }

  Future<void> logIngredientToDiary(
    MealItem mealItem,
    int planId, [
    DateTime? dateTime,
  ]) async {
    final plan = findById(planId);
    mealItem.ingredient = await fetchIngredient(mealItem.ingredientId);
    final log = Log.fromMealItem(mealItem, plan.id!, null, dateTime);

    final data = await _nutritionRepo.createLog(log.toJson());
    log.id = data['id'];
    plan.diaryEntries.add(log);
    _notifyAfterInPlaceMutation();
  }

  Future<void> deleteLog(int logId, int planId) async {
    await _nutritionRepo.deleteLog(logId);
    final plan = findById(planId);
    plan.diaryEntries.removeWhere((element) => element.id == logId);
    _notifyAfterInPlaceMutation();
  }

  /// Loads nutrition diary entries for the given plan and resolves ingredient
  /// references.
  Future<void> fetchAndSetLogs(NutritionalPlan plan) async {
    final data = await _nutritionRepo.fetchLogsForPlan(plan.id!);

    plan.diaryEntries = [];
    for (final logData in data) {
      final log = Log.fromJson(logData);
      log.ingredient = await fetchIngredient(log.ingredientId);
      plan.diaryEntries.add(log);
    }
    _notifyAfterInPlaceMutation();
  }
}
