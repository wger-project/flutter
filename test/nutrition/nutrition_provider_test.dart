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

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/providers/ingredient_repository.dart';
import 'package:wger/providers/nutrition_notifier.dart';
import 'package:wger/providers/nutrition_repository.dart';

import '../fake_connectivity.dart';
import '../fixtures/fixture_reader.dart';
import 'nutrition_provider_test.mocks.dart';

@GenerateMocks([NutritionRepository, IngredientRepository])
void main() {
  // The notifier transitively touches the network status provider; keep the
  // connectivity-plus channel happy.
  installFakeConnectivity();

  final now = DateTime.now();
  late MockNutritionRepository mockRepo;
  late MockIngredientRepository mockIngredientRepo;

  late Map<String, dynamic> nutritionalPlanInfoResponse;
  late Map<String, dynamic> nutritionalPlanDetailResponse;
  late Map<String, dynamic> ingredient10065Response;

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
    when(mockRepo.editLocalDrift(any)).thenAnswer((_) async => Future.value());
    when(mockRepo.deleteLocalDrift(any)).thenAnswer((_) async => Future.value());

    nutritionalPlanInfoResponse = jsonDecode(
      fixture('nutrition/nutritional_plan_info_detail_response.json'),
    );
    nutritionalPlanDetailResponse = jsonDecode(
      fixture('nutrition/nutritional_plan_detail_response.json'),
    );
    ingredient10065Response = jsonDecode(
      fixture('nutrition/ingredientinfo_10065.json'),
    );

    when(mockIngredientRepo.getById(any)).thenAnswer((_) async => null);
  });

  group('fetchAndSetPlanFull', () {
    test('should correctly load a full nutritional plan', () async {
      // arrange
      when(mockRepo.fetchPlanSparse(1)).thenAnswer(
        (_) async => nutritionalPlanDetailResponse,
      );
      when(mockRepo.fetchPlanFull(1)).thenAnswer(
        (_) async => nutritionalPlanInfoResponse,
      );
      when(mockRepo.watchAllLogsHydrated()).thenAnswer((_) => Stream.value(const []));
      // Ingredient lookups now go through PowerSync — stub the local repo.
      final ingredient = Ingredient.fromJson(ingredient10065Response);
      when(mockIngredientRepo.getById(any)).thenAnswer((_) async => ingredient);
      when(mockIngredientRepo.watchById(any)).thenAnswer((_) => Stream.value(ingredient));

      final container = makeContainer();

      // act
      await container.read(nutritionProvider.notifier).fetchAndSetPlanFull(1);

      // assert
      final plans = container.read(nutritionProvider).value?.plans ?? const [];
      expect(plans.isEmpty, false);
    });
  });

  group('currentPlan', () {
    test('gibt den aktiven Plan zurück, wenn nur einer aktiv ist', () async {
      final plan = NutritionalPlan(
        id: 1,
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
        id: 1,
        description: 'Älterer aktiver Plan',
        startDate: now.subtract(const Duration(days: 10)),
        endDate: now.add(const Duration(days: 10)),
        creationDate: now.subtract(const Duration(days: 10)),
      );
      final newerPlan = NutritionalPlan(
        id: 2,
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
          id: 1,
          description: 'plan 1',
          startDate: now.subtract(const Duration(days: 30)),
          endDate: now.subtract(const Duration(days: 5)),
        ),
        NutritionalPlan(
          id: 2,
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
        id: 42,
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
        id: 10,
        description: 'Inactive plan',
        startDate: now.subtract(const Duration(days: 10)),
        endDate: now.subtract(const Duration(days: 5)),
      );
      final plan = NutritionalPlan(
        id: 11,
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
        id: 100,
        description: 'Old active plan',
        startDate: now.subtract(const Duration(days: 10)),
        endDate: now.add(const Duration(days: 10)),
        creationDate: now.subtract(const Duration(days: 10)),
      );
      final newerPlan = NutritionalPlan(
        id: 101,
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
    test('addPlan calls repository (creation still goes via REST)', () async {
      final toAdd = NutritionalPlan(
        id: null,
        description: 'New plan',
        startDate: now,
        creationDate: now,
      );
      final created = NutritionalPlan(
        id: 99,
        description: 'New plan',
        startDate: now,
        creationDate: now,
      );
      when(mockRepo.createPlan(any)).thenAnswer((_) async => created.toJson());

      // Default `Stream.empty()` from setUp leaves state in AsyncLoading,
      // which addPlan promotes to AsyncData via its optimistic update.
      final container = makeContainer();
      final result = await container.read(nutritionProvider.notifier).addPlan(toAdd);

      verify(mockRepo.createPlan(any)).called(1);
      expect(result.id, created.id);
      // Optimistic state injection: the new plan is visible right away.
      final plans = container.read(nutritionProvider).value?.plans ?? const [];
      expect(plans.map((p) => p.id), contains(99));
    });

    test('editPlan delegates to editLocalDrift (PowerSync), not REST', () async {
      final plan = NutritionalPlan(
        id: 1,
        description: 'edit me',
        startDate: now,
        creationDate: now,
      );
      final container = makeContainer();

      await container.read(nutritionProvider.notifier).editPlan(plan);

      verify(mockRepo.editLocalDrift(plan)).called(1);
      verifyNever(mockRepo.updatePlan(any, any));
    });

    test('deletePlan delegates to deleteLocalDrift (PowerSync), not REST', () async {
      final container = makeContainer();

      await container.read(nutritionProvider.notifier).deletePlan(1);

      verify(mockRepo.deleteLocalDrift(1)).called(1);
      verifyNever(mockRepo.deletePlan(any));
    });
  });
}
