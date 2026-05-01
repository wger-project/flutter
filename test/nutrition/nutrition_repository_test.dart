/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 wger Team
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

import 'package:drift/drift.dart' as drift;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/database/powersync/database.dart';
import 'package:wger/models/nutrition/log.dart';
import 'package:wger/models/nutrition/meal.dart';
import 'package:wger/models/nutrition/meal_item.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/providers/base_provider.dart';
import 'package:wger/providers/nutrition_repository.dart';

import '../helpers/in_memory_drift.dart';
import 'nutrition_repository_test.mocks.dart';

@GenerateMocks([WgerBaseProvider])
void main() {
  late DriftPowersyncDatabase db;
  late MockWgerBaseProvider mockBase;
  late NutritionRepository repo;

  setUp(() async {
    db = await openTestDatabase();
    mockBase = MockWgerBaseProvider();
    repo = NutritionRepository(mockBase, db);
  });

  tearDown(() async {
    await db.close();
  });

  // ---- seed helpers ---------------------------------------------------------

  Future<void> seedPlan({
    required int id,
    String description = '',
    DateTime? startDate,
  }) async {
    await db
        .into(db.nutritionalPlanTable)
        .insert(
          NutritionalPlanTableCompanion.insert(
            id: id,
            description: description,
            creationDate: DateTime.utc(2024),
            startDate: startDate ?? DateTime.utc(2024, 1, 1),
            onlyLogging: false,
            hasGoalCalories: false,
          ),
        );
  }

  Future<void> seedIngredient({required int id, required String name}) async {
    await db
        .into(db.ingredientTable)
        .insert(
          IngredientTableCompanion.insert(
            id: id,
            languageId: 2,
            name: name,
            created: DateTime.utc(2024),
            energy: 100,
            carbohydrates: 10,
            protein: 5,
            fat: 5,
          ),
        );
  }

  Future<void> seedIngredientImage({required int id, required int ingredientId}) async {
    await db
        .into(db.ingredientImageTable)
        .insert(
          IngredientImageTableCompanion.insert(
            id: id,
            uuid: 'img-$id',
            ingredientId: ingredientId,
            image: 'images/$id.jpg',
            size: 1024,
            licenseId: 1,
            author: '',
            authorUrl: '',
            title: '',
            objectUrl: '',
            derivativeSourceUrl: '',
          ),
        );
  }

  Future<void> seedIngredientWeightUnit({
    required int id,
    required int ingredientId,
    int grams = 100,
  }) async {
    await db
        .into(db.ingredientWeightUnitTable)
        .insert(
          IngredientWeightUnitTableCompanion.insert(
            id: id,
            uuid: 'wu-$id',
            ingredientId: ingredientId,
            name: 'gram',
            grams: grams,
          ),
        );
  }

  Future<void> seedMeal({required int id, required int planId, String name = ''}) async {
    await db
        .into(db.mealTable)
        .insert(
          MealTableCompanion.insert(
            id: id,
            planId: planId,
            order: 1,
            name: drift.Value(name),
          ),
        );
  }

  Future<void> seedMealItem({
    required int id,
    required int mealId,
    required int ingredientId,
    double amount = 100,
  }) async {
    await db
        .into(db.mealItemTable)
        .insert(
          MealItemTableCompanion.insert(
            id: id,
            mealId: mealId,
            ingredientId: ingredientId,
            order: 1,
            amount: amount,
          ),
        );
  }

  // ---------------------------------------------------------------------------

  group('Plans — REST', () {
    test('fetchPlanSparse hits /nutritionplan/<id>/ and returns the body as a map', () async {
      final uri = Uri.https('localhost', 'api/v2/nutritionplan/42/');
      when(mockBase.makeUrl('nutritionplan', id: 42)).thenReturn(uri);
      when(mockBase.fetch(uri)).thenAnswer((_) async => {'id': 42, 'description': 'plan'});

      final result = await repo.fetchPlanSparse(42);

      expect(result, {'id': 42, 'description': 'plan'});
    });

    test('fetchPlanFull hits /nutritionplaninfo/<id>/', () async {
      final uri = Uri.https('localhost', 'api/v2/nutritionplaninfo/42/');
      when(mockBase.makeUrl('nutritionplaninfo', id: 42)).thenReturn(uri);
      when(mockBase.fetch(uri)).thenAnswer((_) async => {'id': 42});

      final result = await repo.fetchPlanFull(42);

      expect(result['id'], 42);
    });

    test('createPlan POSTs the payload to /nutritionplan/', () async {
      final uri = Uri.https('localhost', 'api/v2/nutritionplan/');
      when(mockBase.makeUrl('nutritionplan')).thenReturn(uri);
      when(mockBase.post(any, uri)).thenAnswer((_) async => {'id': 1});

      await repo.createPlan({'description': 'new plan'});

      verify(mockBase.post({'description': 'new plan'}, uri)).called(1);
    });
  });

  group('Plans — Drift', () {
    test('watchAllDrift emits an empty list when no plans exist', () async {
      expect(await repo.watchAllDrift().first, isEmpty);
    });

    test('watchAllDrift emits plans sorted by start desc', () async {
      await seedPlan(id: 1, startDate: DateTime.utc(2024, 1, 1));
      await seedPlan(id: 2, startDate: DateTime.utc(2024, 6, 1));
      await seedPlan(id: 3, startDate: DateTime.utc(2024, 3, 1));

      final emitted = await repo.watchAllDrift().first;

      expect(emitted.map((p) => p.id).toList(), [2, 3, 1]);
    });

    test('editLocalDrift overwrites the plan with matching id', () async {
      await seedPlan(id: 1, description: 'original');
      final plan = (await repo.watchAllDrift().first).single;
      plan.description = 'updated';

      await repo.editLocalDrift(plan);

      final emitted = await repo.watchAllDrift().first;
      expect(emitted.single.description, 'updated');
    });

    test('editLocalDrift throws StateError when id is null', () async {
      final plan = NutritionalPlan(
        description: 'no id',
        creationDate: DateTime.utc(2024),
        startDate: DateTime.utc(2024),
        onlyLogging: false,
      );

      expect(() => repo.editLocalDrift(plan), throwsStateError);
    });

    test('deleteLocalDrift removes the plan with matching id', () async {
      await seedPlan(id: 1);
      await seedPlan(id: 2);

      await repo.deleteLocalDrift(1);

      final emitted = await repo.watchAllDrift().first;
      expect(emitted.map((p) => p.id), [2]);
    });
  });

  group('Meals', () {
    test('createMeal POSTs to /meal/', () async {
      final uri = Uri.https('localhost', 'api/v2/meal/');
      when(mockBase.makeUrl('meal')).thenReturn(uri);
      when(mockBase.post(any, uri)).thenAnswer((_) async => {'id': 1});

      await repo.createMeal({'name': 'breakfast'});

      verify(mockBase.post({'name': 'breakfast'}, uri)).called(1);
    });

    test('editMealLocalDrift overwrites the meal with matching id', () async {
      await seedPlan(id: 1);
      await seedMeal(id: 5, planId: 1, name: 'breakfast');

      final updated = Meal(id: 5, plan: 1, name: 'lunch');
      await repo.editMealLocalDrift(updated);

      final row = await (db.select(
        db.mealTable,
      )..where((t) => t.id.equals(5))).getSingle();
      expect(row.name, 'lunch');
    });

    test('editMealLocalDrift throws StateError when id is null', () async {
      final meal = Meal(plan: 1, name: 'no id');
      expect(() => repo.editMealLocalDrift(meal), throwsStateError);
    });

    test('deleteMealLocalDrift removes the meal with matching id', () async {
      await seedPlan(id: 1);
      await seedMeal(id: 5, planId: 1);
      await seedMeal(id: 6, planId: 1);

      await repo.deleteMealLocalDrift(5);

      final remaining = await db.select(db.mealTable).get();
      expect(remaining.map((m) => m.id), [6]);
    });
  });

  group('Meal items', () {
    test('createMealItem POSTs to /mealitem/', () async {
      final uri = Uri.https('localhost', 'api/v2/mealitem/');
      when(mockBase.makeUrl('mealitem')).thenReturn(uri);
      when(mockBase.post(any, uri)).thenAnswer((_) async => {'id': 1});

      await repo.createMealItem({'meal': 1, 'amount': 100});

      verify(mockBase.post({'meal': 1, 'amount': 100}, uri)).called(1);
    });

    test('editMealItemLocalDrift overwrites the item with matching id', () async {
      await seedPlan(id: 1);
      await seedMeal(id: 1, planId: 1);
      await seedIngredient(id: 1, name: 'Apple');
      await seedMealItem(id: 7, mealId: 1, ingredientId: 1, amount: 100);

      final updated = MealItem(id: 7, mealId: 1, ingredientId: 1, amount: 250);
      await repo.editMealItemLocalDrift(updated);

      final row = await (db.select(
        db.mealItemTable,
      )..where((t) => t.id.equals(7))).getSingle();
      expect(row.amount, 250);
    });

    test('editMealItemLocalDrift throws StateError when id is null', () async {
      final item = MealItem(mealId: 1, ingredientId: 1, amount: 50);
      expect(() => repo.editMealItemLocalDrift(item), throwsStateError);
    });

    test('deleteMealItemLocalDrift removes the item with matching id', () async {
      await seedPlan(id: 1);
      await seedMeal(id: 1, planId: 1);
      await seedIngredient(id: 1, name: 'Apple');
      await seedMealItem(id: 7, mealId: 1, ingredientId: 1);
      await seedMealItem(id: 8, mealId: 1, ingredientId: 1);

      await repo.deleteMealItemLocalDrift(7);

      final remaining = await db.select(db.mealItemTable).get();
      expect(remaining.map((m) => m.id), [8]);
    });
  });

  group('Diary logs', () {
    test('watchAllLogsHydrated emits empty when no logs exist', () async {
      expect(await repo.watchAllLogsHydrated().first, isEmpty);
    });

    test('addLogLocalDrift inserts a log visible in watchAllLogsHydrated', () async {
      await seedPlan(id: 1);
      await seedIngredient(id: 1, name: 'Apple');

      final log = LogItem(
        planId: 1,
        ingredientId: 1,
        amount: 100,
        datetime: DateTime.utc(2026, 4, 15),
      );
      await repo.addLogLocalDrift(log);

      final emitted = await repo.watchAllLogsHydrated().first;
      expect(emitted, hasLength(1));
      expect(emitted.single.amount, 100);
      expect(emitted.single.ingredient.name, 'Apple');
    });

    test('watchAllLogsHydrated attaches image and weight units to each ingredient', () async {
      await seedPlan(id: 1);
      await seedIngredient(id: 1, name: 'Apple');
      await seedIngredientImage(id: 10, ingredientId: 1);
      await seedIngredientWeightUnit(id: 100, ingredientId: 1);
      await repo.addLogLocalDrift(
        LogItem(
          planId: 1,
          ingredientId: 1,
          amount: 100,
          datetime: DateTime.utc(2026, 4, 15),
        ),
      );

      final emitted = await repo.watchAllLogsHydrated().first;

      expect(emitted.single.ingredient.image?.id, 10);
      expect(emitted.single.ingredient.weightUnits.single.id, 100);
    });

    test('watchAllLogsHydrated resolves weightUnitObj on the log when set', () async {
      await seedPlan(id: 1);
      await seedIngredient(id: 1, name: 'Apple');
      await seedIngredientWeightUnit(id: 100, ingredientId: 1);
      await repo.addLogLocalDrift(
        LogItem(
          planId: 1,
          ingredientId: 1,
          weightUnitId: 100,
          amount: 1,
          datetime: DateTime.utc(2026, 4, 15),
        ),
      );

      final emitted = await repo.watchAllLogsHydrated().first;

      expect(emitted.single.weightUnitObj?.id, 100);
    });

    test('watchAllLogsHydrated leaves weightUnitObj null when log has no weightUnitId', () async {
      await seedPlan(id: 1);
      await seedIngredient(id: 1, name: 'Apple');
      await repo.addLogLocalDrift(
        LogItem(
          planId: 1,
          ingredientId: 1,
          amount: 100,
          datetime: DateTime.utc(2026, 4, 15),
        ),
      );

      final emitted = await repo.watchAllLogsHydrated().first;

      expect(emitted.single.weightUnitObj, isNull);
    });

    test('deleteLogLocalDrift removes the log with matching id', () async {
      await seedPlan(id: 1);
      await seedIngredient(id: 1, name: 'Apple');
      final log = LogItem(
        planId: 1,
        ingredientId: 1,
        amount: 100,
        datetime: DateTime.utc(2026, 4, 15),
      );
      await db.into(db.logItemTable).insert(log.toCompanion(includeId: true));
      // Use insert with includeId: false (default) means a new id is generated.
      // For our test, fetch the inserted id from the DB.
      final all = await db.select(db.logItemTable).get();
      final insertedId = all.single.id!;

      await repo.deleteLogLocalDrift(insertedId);

      expect(await db.select(db.logItemTable).get(), isEmpty);
    });
  });
}
