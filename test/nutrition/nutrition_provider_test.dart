/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2026 wger Team
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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/models/nutrition/meal.dart';
import 'package:wger/models/nutrition/meal_item.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/providers/ingredient_repository.dart';
import 'package:wger/providers/nutrition_notifier.dart';
import 'package:wger/providers/nutrition_repository.dart';

import '../fake_connectivity.dart';
import 'nutrition_provider_test.mocks.dart';

@GenerateMocks([NutritionRepository, IngredientRepository])
void main() {
  // The notifier transitively touches the network status provider; keep the
  // connectivity-plus channel happy.
  installFakeConnectivity();

  final now = DateTime.now();
  late MockNutritionRepository mockRepo;
  late MockIngredientRepository mockIngredientRepo;

  ProviderContainer makeContainer() {
    return ProviderContainer.test(
      overrides: [
        nutritionRepositoryProvider.overrideWithValue(mockRepo),
        ingredientRepositoryProvider.overrideWithValue(mockIngredientRepo),
      ],
    );
  }

  /// Stubs the Drift stream with a single emission of [plans] and waits for
  /// the value to land in state
  Future<ProviderContainer> containerWithPlans(List<NutritionalPlan> plans) async {
    when(mockRepo.watchAllDrift()).thenAnswer((_) => Stream.value(plans));
    final container = makeContainer();
    // Explicit listener keeps the provider element alive while we wait for
    // the Drift-stream emission to propagate — in unit tests there is no
    // widget pump that would do this for us.
    container.listen(nutritionProvider, (_, _) {});
    await pumpEventQueue();
    return container;
  }

  setUp(() {
    mockRepo = MockNutritionRepository();
    mockIngredientRepo = MockIngredientRepository();

    // Default stub: empty stream that never emits. Tests opt-in to seeded
    // plans via [containerWithPlans]; tests that exercise notifier methods
    // (addPlan / editPlan / deletePlan) keep this default so that a
    // concurrent stream emission can't overwrite their optimistic state.
    when(mockRepo.watchAllDrift()).thenAnswer((_) => const Stream.empty());

    when(mockRepo.watchAllLogsHydrated()).thenAnswer((_) => Stream.value(const []));

    // Edit + delete now go through Drift instead of REST.
    when(mockRepo.addPlanLocalDrift(any)).thenAnswer((_) async => Future.value());
    when(mockRepo.editLocalDrift(any)).thenAnswer((_) async => Future.value());
    when(mockRepo.deleteLocalDrift(any)).thenAnswer((_) async => Future.value());
    when(mockRepo.watchAllMealsHydrated()).thenAnswer((_) => Stream.value(const []));
    when(mockRepo.addMealLocalDrift(any)).thenAnswer((_) async => Future.value());
    when(mockRepo.editMealLocalDrift(any)).thenAnswer((_) async => Future.value());
    when(mockRepo.deleteMealLocalDrift(any)).thenAnswer((_) async => Future.value());
    when(mockRepo.addMealItemLocalDrift(any)).thenAnswer((_) async => Future.value());
    when(mockRepo.editMealItemLocalDrift(any)).thenAnswer((_) async => Future.value());
    when(mockRepo.deleteMealItemLocalDrift(any)).thenAnswer((_) async => Future.value());

    when(mockIngredientRepo.getById(any)).thenAnswer((_) async => null);
  });

  const planUuid1 = 'cc000000-0000-4000-8000-000000000001';
  const planUuid2 = 'cc000000-0000-4000-8000-000000000002';
  const planUuidA = 'cc000000-0000-4000-8000-00000000000a';
  const planUuidB = 'cc000000-0000-4000-8000-00000000000b';

  group('currentPlan', () {
    test('gibt den aktiven Plan zurück, wenn nur einer aktiv ist', () async {
      final plan = NutritionalPlan(
        id: planUuid1,
        description: 'Aktiver Plan',
        startDate: now.subtract(const Duration(days: 1)),
        endDate: now.add(const Duration(days: 1)),
        creationDate: now.subtract(const Duration(days: 2)),
      );
      final container = await containerWithPlans([plan]);
      expect(
        container.read(nutritionProvider.notifier).currentPlan?.id,
        equals(plan.id),
      );
    });

    test('gibt den neuesten aktiven Plan zurück, wenn mehrere aktiv sind', () async {
      final olderPlan = NutritionalPlan(
        id: planUuid1,
        description: 'Älterer aktiver Plan',
        startDate: now.subtract(const Duration(days: 10)),
        endDate: now.add(const Duration(days: 10)),
        creationDate: now.subtract(const Duration(days: 10)),
      );
      final newerPlan = NutritionalPlan(
        id: planUuid2,
        description: 'Neuerer aktiver Plan',
        startDate: now.subtract(const Duration(days: 5)),
        endDate: now.add(const Duration(days: 5)),
        creationDate: now.subtract(const Duration(days: 2)),
      );
      final container = await containerWithPlans([olderPlan, newerPlan]);
      expect(
        container.read(nutritionProvider.notifier).currentPlan?.id,
        equals(newerPlan.id),
      );
    });
  });

  group('currentPlan correctly returns the active plan', () {
    test('no plans available -> null', () async {
      final container = await containerWithPlans([]);
      expect(container.read(nutritionProvider.notifier).currentPlan, isNull);
    });

    test('no active plan -> null', () async {
      final plans = [
        NutritionalPlan(
          id: planUuid1,
          description: 'plan 1',
          startDate: now.subtract(const Duration(days: 30)),
          endDate: now.subtract(const Duration(days: 5)),
        ),
        NutritionalPlan(
          id: planUuid2,
          description: 'plan 2',
          startDate: now.add(const Duration(days: 100)),
          endDate: now.add(const Duration(days: 50)),
        ),
      ];
      final container = await containerWithPlans(plans);
      expect(container.read(nutritionProvider.notifier).currentPlan, isNull);
    });

    test('active plan exists -> return it', () async {
      final plan = NutritionalPlan(
        id: planUuidA,
        description: 'Active plan',
        startDate: now.subtract(const Duration(days: 10)),
        endDate: now.add(const Duration(days: 10)),
      );
      final container = await containerWithPlans([plan]);
      expect(
        container.read(nutritionProvider.notifier).currentPlan?.id,
        equals(plan.id),
      );
    });

    test('inactive plans are ignored', () async {
      final inactivePlan = NutritionalPlan(
        id: planUuidA,
        description: 'Inactive plan',
        startDate: now.subtract(const Duration(days: 10)),
        endDate: now.subtract(const Duration(days: 5)),
      );
      final plan = NutritionalPlan(
        id: planUuidB,
        description: 'Active plan',
        startDate: now.subtract(const Duration(days: 10)),
        endDate: now.add(const Duration(days: 10)),
      );
      final container = await containerWithPlans([plan, inactivePlan]);
      expect(
        container.read(nutritionProvider.notifier).currentPlan?.id,
        equals(plan.id),
      );
    });

    test('several active plans exists -> return newest', () async {
      final olderPlan = NutritionalPlan(
        id: planUuidA,
        description: 'Old active plan',
        startDate: now.subtract(const Duration(days: 10)),
        endDate: now.add(const Duration(days: 10)),
        creationDate: now.subtract(const Duration(days: 10)),
      );
      final newerPlan = NutritionalPlan(
        id: planUuidB,
        description: 'Newer active plan',
        startDate: now.subtract(const Duration(days: 5)),
        endDate: now.add(const Duration(days: 5)),
        creationDate: now.subtract(const Duration(days: 1)),
      );
      final container = await containerWithPlans([olderPlan, newerPlan]);
      expect(
        container.read(nutritionProvider.notifier).currentPlan?.id,
        equals(newerPlan.id),
      );
    });
  });

  group('plan write operations', () {
    test('addPlan generates a UUID and delegates to addPlanLocalDrift', () async {
      final toAdd = NutritionalPlan(
        id: null,
        description: 'New plan',
        startDate: now,
        creationDate: now,
      );

      final container = makeContainer();
      final result = await container.read(nutritionProvider.notifier).addPlan(toAdd);

      expect(result.id, isNotNull);
      verify(mockRepo.addPlanLocalDrift(toAdd)).called(1);
    });

    test('editPlan delegates to editLocalDrift', () async {
      final plan = NutritionalPlan(
        id: planUuid1,
        description: 'edit me',
        startDate: now,
        creationDate: now,
      );
      final container = makeContainer();

      await container.read(nutritionProvider.notifier).editPlan(plan);

      verify(mockRepo.editLocalDrift(plan)).called(1);
    });

    test('deletePlan delegates to deleteLocalDrift', () async {
      final container = makeContainer();

      await container.read(nutritionProvider.notifier).deletePlan(planUuid1);

      verify(mockRepo.deleteLocalDrift(planUuid1)).called(1);
    });
  });

  group('meal write operations', () {
    const mealUuid = 'aa000000-0000-4000-8000-000000000001';

    test('addMeal generates a UUID and delegates to addMealLocalDrift', () async {
      final meal = Meal(plan: planUuid1, name: 'breakfast');
      final container = makeContainer();

      final saved = await container.read(nutritionProvider.notifier).addMeal(meal, planUuid1);

      expect(saved.id, isNotNull);
      expect(saved.planId, planUuid1);
      verify(mockRepo.addMealLocalDrift(meal)).called(1);
    });

    test('editMeal delegates to editMealLocalDrift (PowerSync), not REST', () async {
      final meal = Meal(id: mealUuid, plan: planUuid1, name: 'breakfast');
      final container = makeContainer();

      await container.read(nutritionProvider.notifier).editMeal(meal);

      verify(mockRepo.editMealLocalDrift(meal)).called(1);
    });

    test('deleteMeal delegates to deleteMealLocalDrift', () async {
      final meal = Meal(id: mealUuid, plan: planUuid1, name: 'breakfast');
      final container = makeContainer();

      await container.read(nutritionProvider.notifier).deleteMeal(meal);

      verify(mockRepo.deleteMealLocalDrift(mealUuid)).called(1);
    });
  });

  group('meal item write operations', () {
    const mealUuid = 'aa000000-0000-4000-8000-000000000001';
    const itemUuid = 'bb000000-0000-4000-8000-000000000001';

    test('addMealItem generates a UUID and delegates to addMealItemLocalDrift', () async {
      final meal = Meal(id: mealUuid, plan: planUuid1, name: 'breakfast');
      final item = MealItem(ingredientId: 1, amount: 100);
      final container = makeContainer();

      final saved = await container.read(nutritionProvider.notifier).addMealItem(item, meal);

      expect(saved.id, isNotNull);
      expect(saved.mealId, mealUuid);
      verify(mockRepo.addMealItemLocalDrift(item)).called(1);
    });

    test('editMealItem delegates to editMealItemLocalDrift (PowerSync)', () async {
      final item = MealItem(id: itemUuid, mealId: mealUuid, ingredientId: 1, amount: 100);
      final container = makeContainer();

      await container.read(nutritionProvider.notifier).editMealItem(item);

      verify(mockRepo.editMealItemLocalDrift(item)).called(1);
    });

    test('deleteMealItem delegates to deleteMealItemLocalDrift', () async {
      final item = MealItem(id: itemUuid, mealId: mealUuid, ingredientId: 1, amount: 100);
      final container = makeContainer();

      await container.read(nutritionProvider.notifier).deleteMealItem(item);

      verify(mockRepo.deleteMealItemLocalDrift(itemUuid)).called(1);
    });
  });
}
