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
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:wger/models/nutrition/log.dart';
import 'package:wger/models/nutrition/meal.dart';
import 'package:wger/models/nutrition/meal_item.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
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

  /// Returns the plan with the given [id], or `null` if it isn't (yet) in the
  /// streamed snapshot
  NutritionalPlan? findByIdOrNull(String? id) => plans.firstWhereOrNull((plan) => plan.id == id);
}

@Riverpod(keepAlive: true)
class NutritionNotifier extends _$NutritionNotifier {
  @override
  Stream<NutritionState> build() {
    ref.keepAlive();

    // We chain three streams via [combineLatest]: the first emission is held
    // back until every source has produced a value, so the resulting plans
    // always carry coherent meal/diary data.
    final repo = ref.read(nutritionRepositoryProvider);
    return repo
        .watchAllDrift()
        .combineLatest(
          repo.watchAllMealsHydrated(),
          (plans, meals) => (plans, meals),
        )
        .combineLatest(repo.watchAllLogsHydrated(), (acc, logs) {
          final plans = acc.$1;
          final meals = acc.$2;
          return _assemble(plans, meals, logs);
        });
  }

  NutritionState _assemble(
    List<NutritionalPlan> plans,
    List<Meal> meals,
    List<LogItem> logs,
  ) {
    final mealsByPlan = <String, List<Meal>>{};
    for (final meal in meals) {
      mealsByPlan.putIfAbsent(meal.planId, () => []).add(meal);
    }
    final logsByPlan = <String, List<LogItem>>{};
    final logsByMeal = <String, List<LogItem>>{};
    for (final log in logs) {
      logsByPlan.putIfAbsent(log.planId, () => []).add(log);
      if (log.mealId != null) {
        logsByMeal.putIfAbsent(log.mealId!, () => []).add(log);
      }
    }
    for (final plan in plans) {
      plan.meals = mealsByPlan[plan.id] ?? const [];
      plan.diaryEntries = logsByPlan[plan.id] ?? const [];
      for (final meal in plan.meals) {
        meal.diaryEntries = logsByMeal[meal.id] ?? const [];
      }
    }
    return NutritionState(plans: plans);
  }

  // --- Plans ---

  /// Persists a new nutritional plan via Drift; the repository writes it
  /// back to [plan] with the UUID Drift assigned, so callers can reference
  /// it immediately (e.g. to add meals in the same flow)
  Future<NutritionalPlan> addPlan(NutritionalPlan plan) async {
    final repo = ref.read(nutritionRepositoryProvider);
    await repo.addPlanLocalDrift(plan);
    return plan;
  }

  Future<void> editPlan(NutritionalPlan plan) async {
    final repo = ref.read(nutritionRepositoryProvider);
    await repo.editLocalDrift(plan);
  }

  /// Django's FK CASCADE removes any dependent meals/items/diary entries.
  /// Local state picks up the removal on the next stream emission.
  Future<void> deletePlan(String id) async {
    final repo = ref.read(nutritionRepositoryProvider);
    await repo.deleteLocalDrift(id);
  }

  // --- Meals ---

  /// Persists a new meal via Drift; the repository writes the assigned
  /// UUID back to [meal] so callers can reference it immediately (e.g. to
  /// add meal items in the same flow). The repository also computes the
  /// next `order` value from existing rows.
  Future<Meal> addMeal(Meal meal, String planId) async {
    final repo = ref.read(nutritionRepositoryProvider);
    meal.planId = planId;
    await repo.addMealLocalDrift(meal);
    return meal;
  }

  Future<void> editMeal(Meal meal) async {
    final repo = ref.read(nutritionRepositoryProvider);
    await repo.editMealLocalDrift(meal);
  }

  /// Django's FK CASCADE removes any dependent meal items.
  Future<void> deleteMeal(Meal meal) async {
    final repo = ref.read(nutritionRepositoryProvider);
    await repo.deleteMealLocalDrift(meal.id!);
  }

  // --- Meal items ---

  /// Persists a new meal item; the repository writes the assigned UUID
  /// back to [mealItem].
  Future<MealItem> addMealItem(MealItem mealItem, Meal meal) async {
    final repo = ref.read(nutritionRepositoryProvider);
    mealItem.mealId = meal.id!;
    await repo.addMealItemLocalDrift(mealItem);
    return mealItem;
  }

  /// Goes through PowerSync (Drift update → CRUD queue → backend).
  Future<void> editMealItem(MealItem mealItem) async {
    final repo = ref.read(nutritionRepositoryProvider);
    await repo.editMealItemLocalDrift(mealItem);
  }

  /// Goes through PowerSync (Drift delete → CRUD queue → backend).
  Future<void> deleteMealItem(MealItem mealItem) async {
    final repo = ref.read(nutritionRepositoryProvider);
    await repo.deleteMealItemLocalDrift(mealItem.id!);
  }

  // --- Logs (nutrition diary) ---

  Future<void> logMealToDiary(Meal meal, DateTime mealDateTime) async {
    final repo = ref.read(nutritionRepositoryProvider);
    for (final item in meal.mealItems) {
      final log = LogItem.fromMealItem(item, meal.planId, meal.id, mealDateTime);
      await repo.addLogLocalDrift(log);
    }
  }

  Future<void> logIngredientToDiary(
    MealItem mealItem,
    String planId, [
    DateTime? dateTime,
  ]) async {
    final repo = ref.read(nutritionRepositoryProvider);
    final log = LogItem.fromMealItem(mealItem, planId, null, dateTime);
    await repo.addLogLocalDrift(log);
  }

  Future<void> deleteLog(String logId) async {
    final repo = ref.read(nutritionRepositoryProvider);
    await repo.deleteLogLocalDrift(logId);
  }
}
