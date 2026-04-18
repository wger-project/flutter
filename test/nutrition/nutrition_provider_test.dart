import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
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
  // NutritionNotifier watches networkStatusProvider, which calls through to
  // connectivity_plus. Swap in a fake platform so the plugin's channel call
  // doesn't throw under the test runner.
  installFakeConnectivity();

  final now = DateTime.now();
  late MockNutritionRepository mockRepo;
  late MockIngredientRepository mockIngredientRepo;

  late Map<String, dynamic> nutritionalPlanInfoResponse;
  late Map<String, dynamic> nutritionalPlanDetailResponse;
  late List<dynamic> nutritionDiaryResponse;
  late Map<String, dynamic> ingredient10065Response;

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        nutritionRepositoryProvider.overrideWithValue(mockRepo),
        ingredientRepositoryProvider.overrideWithValue(mockIngredientRepo),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  /// Creates a container whose [nutritionProvider] is seeded with [plans].
  Future<ProviderContainer> containerWithPlans(List<NutritionalPlan> plans) async {
    when(mockRepo.fetchAllPlans()).thenAnswer(
      (_) async => plans.map((p) => p.toJson()).toList(),
    );
    final container = makeContainer();
    // Ensure the async build() has run so state is AsyncData(...)
    await container.read(nutritionProvider.future);
    await container.read(nutritionProvider.notifier).fetchAndSetAllPlansSparse();
    return container;
  }

  setUp(() {
    mockRepo = MockNutritionRepository();
    mockIngredientRepo = MockIngredientRepository();

    nutritionalPlanInfoResponse = jsonDecode(
      fixture('nutrition/nutritional_plan_info_detail_response.json'),
    );
    nutritionalPlanDetailResponse = jsonDecode(
      fixture('nutrition/nutritional_plan_detail_response.json'),
    );
    nutritionDiaryResponse = jsonDecode(
      fixture('nutrition/nutrition_diary_response.json'),
    )['results'];
    ingredient10065Response = jsonDecode(
      fixture('nutrition/ingredientinfo_10065.json'),
    );

    // By default the local ingredient repo has no data - fall back to HTTP.
    when(mockIngredientRepo.getById(any)).thenAnswer((_) async => null);

    // NutritionNotifier.build() auto-fetches all plans on first read.
    // Default to an empty list so tests that don't care about the plan list
    // don't have to stub it; tests that need real plans override via
    // [containerWithPlans].
    when(mockRepo.fetchAllPlans()).thenAnswer((_) async => []);
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
      when(mockRepo.fetchLogsForPlan(any)).thenAnswer(
        (_) async => nutritionDiaryResponse,
      );
      when(mockRepo.fetchIngredient(any)).thenAnswer(
        (_) async => Ingredient.fromJson(ingredient10065Response),
      );

      final container = makeContainer();
      await container.read(nutritionProvider.future);

      // act
      await container.read(nutritionProvider.notifier).fetchAndSetPlanFull(1);

      // assert
      final plans = container.read(nutritionProvider).value ?? const [];
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

  group('deletePlan', () {
    test('removes the plan locally on success', () async {
      final plan = NutritionalPlan(
        id: 1,
        description: 'to delete',
        startDate: now,
        creationDate: now,
      );
      final container = await containerWithPlans([plan]);

      when(mockRepo.deletePlan(1)).thenAnswer(
        (_) async => http.Response('', 204),
      );

      await container.read(nutritionProvider.notifier).deletePlan(1);

      final plans = container.read(nutritionProvider).value ?? const [];
      expect(plans, isEmpty);
    });
  });
}
