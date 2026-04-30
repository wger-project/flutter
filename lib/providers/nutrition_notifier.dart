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
import 'package:stream_transform/stream_transform.dart';
import 'package:wger/core/exceptions/http_exception.dart';
import 'package:wger/core/exceptions/no_such_entry_exception.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/models/nutrition/log.dart';
import 'package:wger/models/nutrition/meal.dart';
import 'package:wger/models/nutrition/meal_item.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/providers/ingredient_repository.dart';
import 'package:wger/providers/nutrition_repository.dart';

part 'nutrition_notifier.g.dart';

/// Snapshot exposed by [NutritionNotifier].
class NutritionState {
  const NutritionState({
    this.plans = const [],
  });

  final List<NutritionalPlan> plans;

  NutritionState copyWith({List<NutritionalPlan>? plans}) {
    return NutritionState(plans: plans ?? this.plans);
  }

  /// Returns the current active nutritional plan.
  ///
  /// A plan is considered active if its start date is before now and its end
  /// date is after now (or not set). With multiple matches, the most recently
  /// created plan wins.
  NutritionalPlan? get currentPlan {
    final now = DateTime.now();
    return plans
        .where(
          (plan) =>
              plan.startDate.isBefore(now) && (plan.endDate == null || plan.endDate!.isAfter(now)),
        )
        .toList()
        .sorted((a, b) => b.creationDate.compareTo(a.creationDate))
        .firstOrNull;
  }

  /// Throws [NoSuchEntryException] if no plan with the given id exists.
  NutritionalPlan findById(int id) {
    return plans.firstWhere(
      (plan) => plan.id == id,
      orElse: () => throw const NoSuchEntryException(),
    );
  }

  Meal? findMealById(int id) {
    for (final plan in plans) {
      final meal = plan.meals.firstWhereOrNull((m) => m.id == id);
      if (meal != null) {
        return meal;
      }
    }
    return null;
  }
}

@Riverpod(keepAlive: true)
class NutritionNotifier extends _$NutritionNotifier {
  final _logger = Logger('NutritionNotifier');

  @override
  Stream<NutritionState> build() {
    _logger.fine('Building NutritionNotifier');
    ref.keepAlive();

    // Top-level plans and diary entries both come from synced tables. The
    // hierarchy in between meals and meal items still lives behind REST and
    // is layered on top by callers via [fetchAndSetPlanFull]; we re-attach
    // it from the previous state on every emission so a remote edit doesn't
    // wipe locally-hydrated meals.
    //
    // [combineLatest] holds back the first emission until both streams have
    // produced a value, so the resulting plans always carry coherent diary
    // data
    final repo = ref.read(nutritionRepositoryProvider);
    return repo.watchAllDrift().combineLatest(repo.watchAllLogsHydrated(), (freshPlans, allLogs) {
      final existing = state.value?.plans ?? const <NutritionalPlan>[];
      for (final fresh in freshPlans) {
        final old = existing.firstWhereOrNull((p) => p.id == fresh.id);
        if (old != null) {
          fresh.meals = old.meals;
        }
        fresh.diaryEntries = allLogs.where((l) => l.planId == fresh.id).toList();
        for (final meal in fresh.meals) {
          meal.diaryEntries = fresh.diaryEntries.where((l) => l.mealId == meal.id).toList();
        }
      }
      return NutritionState(plans: freshPlans);
    });
  }

  // --- Convenience accessors (delegate to state) ---

  List<NutritionalPlan> get _plans => state.value?.plans ?? const [];

  /// Throws [NoSuchEntryException] if no plan with the given id exists.
  NutritionalPlan findById(int id) => (state.value ?? const NutritionState()).findById(id);

  Meal? findMealById(int id) => (state.value ?? const NutritionState()).findMealById(id);

  NutritionalPlan? get currentPlan => (state.value ?? const NutritionState()).currentPlan;

  /// Notifies listeners after in-place mutation on the plans list (e.g. when
  /// meals or logs on a plan are mutated via object references). Equivalent to
  /// the old `notifyListeners()`.
  void _notifyAfterInPlaceMutation() {
    state = AsyncData(NutritionState(plans: List.of(_plans)));
  }

  /// Replaces the in-memory plan list. Used to apply optimistic updates that
  /// are eventually overwritten by the next stream emission.
  void _setPlans(List<NutritionalPlan> plans) {
    state = AsyncData(NutritionState(plans: List.of(plans)));
  }

  // --- Plans ---

  Future<NutritionalPlan> fetchAndSetPlanSparse(int planId) async {
    final repo = ref.read(nutritionRepositoryProvider);
    final data = await repo.fetchPlanSparse(planId);
    final plan = NutritionalPlan.fromJson(data);
    final plans = List<NutritionalPlan>.of(_plans)..add(plan);
    // Match Django's `Meta.ordering = ['-start']`.
    plans.sort((a, b) => b.startDate.compareTo(a.startDate));
    _setPlans(plans);
    return plan;
  }

  /// Fetches a plan with meals, meal items, and log entries.
  Future<NutritionalPlan> fetchAndSetPlanFull(int planId) async {
    _logger.fine('Fetching full nutritional plan $planId');

    final repo = ref.read(nutritionRepositoryProvider);

    NutritionalPlan plan;
    try {
      plan = findById(planId);
    } on NoSuchEntryException {
      plan = await fetchAndSetPlanSparse(planId);
    }

    final fullPlanData = await repo.fetchPlanFull(planId);
    final ingredientRepo = ref.read(ingredientRepositoryProvider);

    // Meals
    final List<Meal> meals = [];
    for (final mealData in (fullPlanData['meals'] as List?) ?? const []) {
      final meal = Meal.fromJson(mealData);
      final List<dynamic> mealItemsData = (mealData['meal_items'] as List?) ?? const [];

      // Resolve all ingredients for this meal in parallel
      final resolved = await Future.wait(
        mealItemsData.map((data) async {
          final mealItem = MealItem.fromJson(data);
          final ingredient = await ingredientRepo
              .watchById(mealItem.ingredientId)
              .firstWhere((i) => i != null, orElse: () => null)
              .timeout(const Duration(seconds: 5), onTimeout: () => null);
          if (ingredient == null) {
            _logger.warning(
              'Ingredient ${mealItem.ingredientId} not in local DB after 5s '
              'wait, skipping meal item ${mealItem.id}',
            );
            return null;
          }
          mealItem.ingredient = ingredient;
          return mealItem;
        }),
      );
      meal.mealItems = resolved.whereType<MealItem>().toList();
      meals.add(meal);
    }
    plan.meals = meals;

    // Diary entries are streamed in by build() from PowerSync. Distribute
    // the logs we already have onto the freshly-loaded meals so the UI sees
    // them immediately, before the next stream tick.
    for (final meal in meals) {
      meal.diaryEntries = plan.diaryEntries.where((e) => e.mealId == meal.id).toList();
    }

    _notifyAfterInPlaceMutation();
    return plan;
  }

  /// Creation still goes through REST. PowerSync will eventually replicate the
  /// new row via the stream, but to avoid a perceptible UI lag we also inject
  /// the freshly-created plan into state right away. When the stream later
  /// re-emits the same row, build()'s sub-data preservation logic keeps things
  /// stable.
  Future<NutritionalPlan> addPlan(NutritionalPlan planData) async {
    final repo = ref.read(nutritionRepositoryProvider);
    final data = await repo.createPlan(planData.toJson());
    final plan = NutritionalPlan.fromJson(data);
    final plans = List<NutritionalPlan>.of(_plans)..add(plan);
    // Match Django's `Meta.ordering = ['-start']`.
    plans.sort((a, b) => b.startDate.compareTo(a.startDate));
    _setPlans(plans);
    return plan;
  }

  /// Goes through PowerSync (Drift update → CRUD queue → backend).
  /// Local state picks up the change on the next stream emission.
  Future<void> editPlan(NutritionalPlan plan) async {
    final repo = ref.read(nutritionRepositoryProvider);
    await repo.editLocalDrift(plan);
  }

  /// Goes through PowerSync (Drift delete → CRUD queue → backend), where
  /// Django's FK CASCADE removes any dependent meals/items/diary entries.
  /// Local state picks up the removal on the next stream emission.
  Future<void> deletePlan(int id) async {
    final repo = ref.read(nutritionRepositoryProvider);
    await repo.deleteLocalDrift(id);
  }

  // --- Meals ---

  Future<Meal> addMeal(Meal meal, int planId) async {
    final repo = ref.read(nutritionRepositoryProvider);
    final plan = findById(planId);
    meal.planId = planId;
    final data = await repo.createMeal(meal.toJson());
    final saved = Meal.fromJson(data);
    plan.meals.add(saved);
    _notifyAfterInPlaceMutation();
    return saved;
  }

  Future<Meal> editMeal(Meal meal) async {
    final repo = ref.read(nutritionRepositoryProvider);
    final data = await repo.updateMeal(meal.id!, meal.toJson());
    final updated = Meal.fromJson(data);
    _notifyAfterInPlaceMutation();
    return updated;
  }

  Future<void> deleteMeal(Meal meal) async {
    final repo = ref.read(nutritionRepositoryProvider);
    final plan = findById(meal.planId);
    final mealIndex = plan.meals.indexWhere((e) => e.id == meal.id);
    final existing = plan.meals[mealIndex];
    plan.meals.removeAt(mealIndex);
    _notifyAfterInPlaceMutation();

    final response = await repo.deleteMeal(meal.id!);
    if (response.statusCode >= 400) {
      plan.meals.insert(mealIndex, existing);
      _notifyAfterInPlaceMutation();
      throw WgerHttpException(response);
    }
  }

  // --- Meal items ---

  Future<MealItem> addMealItem(MealItem mealItem, Meal meal) async {
    final repo = ref.read(nutritionRepositoryProvider);
    final data = await repo.createMealItem(mealItem.toJson());
    final saved = MealItem.fromJson(data);
    saved.ingredient = mealItem.ingredient;
    meal.mealItems.add(saved);
    _notifyAfterInPlaceMutation();
    return saved;
  }

  Future<void> deleteMealItem(MealItem mealItem) async {
    final repo = ref.read(nutritionRepositoryProvider);
    final meal = findMealById(mealItem.mealId)!;
    final mealItemIndex = meal.mealItems.indexWhere((e) => e.id == mealItem.id);
    final existing = meal.mealItems[mealItemIndex];
    meal.mealItems.removeAt(mealItemIndex);
    _notifyAfterInPlaceMutation();

    final response = await repo.deleteMealItem(mealItem.id!);
    if (response.statusCode >= 400) {
      meal.mealItems.insert(mealItemIndex, existing);
      _notifyAfterInPlaceMutation();
      throw WgerHttpException(response);
    }
  }

  // --- Ingredients ---

  Future<List<Ingredient>> searchIngredient(
    String name, {
    String languageCode = 'en',
    IngredientSearchLanguage searchLanguage = IngredientSearchLanguage.current,
    bool isVegan = false,
    bool isVegetarian = false,
  }) {
    final repo = ref.read(nutritionRepositoryProvider);
    return repo.searchIngredient(
      name,
      languageCode: languageCode,
      searchLanguage: searchLanguage,
      isVegan: isVegan,
      isVegetarian: isVegetarian,
    );
  }

  Future<Ingredient?> searchIngredientWithBarcode(String barcode) {
    final repo = ref.read(nutritionRepositoryProvider);
    return repo.searchIngredientWithBarcode(barcode);
  }

  // --- Logs (nutrition diary) ---

  Future<void> logMealToDiary(Meal meal, DateTime mealDateTime) async {
    final repo = ref.read(nutritionRepositoryProvider);
    final plan = findById(meal.planId);
    for (final item in meal.mealItems) {
      final log = LogItem.fromMealItem(item, plan.id!, meal.id, mealDateTime);
      await repo.addLogLocalDrift(log);
    }
  }

  Future<void> logIngredientToDiary(
    MealItem mealItem,
    int planId, [
    DateTime? dateTime,
  ]) async {
    final repo = ref.read(nutritionRepositoryProvider);
    final plan = findById(planId);
    final log = LogItem.fromMealItem(mealItem, plan.id!, null, dateTime);
    await repo.addLogLocalDrift(log);
  }

  Future<void> deleteLog(String logId) async {
    final repo = ref.read(nutritionRepositoryProvider);
    await repo.deleteLogLocalDrift(logId);
  }
}
