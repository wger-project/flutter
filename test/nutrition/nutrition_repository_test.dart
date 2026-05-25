/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 - 2026 wger Team
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
import 'package:wger/database/powersync/database.dart';
import 'package:wger/models/nutrition/log.dart';
import 'package:wger/models/nutrition/meal.dart';
import 'package:wger/models/nutrition/meal_item.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/providers/nutrition_repository.dart';

import '../helpers/in_memory_drift.dart';

void main() {
  late DriftPowersyncDatabase db;
  late NutritionRepository repo;

  setUp(() async {
    db = await openTestDatabase();
    repo = NutritionRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  // ---- seed helpers ---------------------------------------------------------

  Future<void> seedPlan({
    required String id,
    String description = '',
    DateTime? startDate,
  }) async {
    await db
        .into(db.nutritionalPlanTable)
        .insert(
          NutritionalPlanTableCompanion.insert(
            id: drift.Value(id),
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
            width: 100,
            height: 100,
            created: DateTime.utc(2024),
            lastUpdate: DateTime.utc(2024),
            licenseId: 1,
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

  Future<void> seedMeal({
    required String id,
    required String planId,
    int order = 1,
    String name = '',
  }) async {
    await db
        .into(db.mealTable)
        .insert(
          MealTableCompanion.insert(
            id: drift.Value(id),
            planId: planId,
            order: drift.Value(order),
            name: drift.Value(name),
          ),
        );
  }

  Future<void> seedMealItem({
    required String id,
    required String mealId,
    required int ingredientId,
    int order = 1,
    double amount = 100,
  }) async {
    await db
        .into(db.mealItemTable)
        .insert(
          MealItemTableCompanion.insert(
            id: drift.Value(id),
            mealId: mealId,
            ingredientId: ingredientId,
            order: drift.Value(order),
            amount: amount,
          ),
        );
  }

  // ---------------------------------------------------------------------------

  const planUuid1 = 'cc000000-0000-4000-8000-000000000001';
  const planUuid2 = 'cc000000-0000-4000-8000-000000000002';
  const planUuid3 = 'cc000000-0000-4000-8000-000000000003';

  group('Plans, Drift', () {
    test('watchAllDrift emits an empty list when no plans exist', () async {
      expect(await repo.watchAllDrift().first, isEmpty);
    });

    test('watchAllDrift emits plans sorted by start desc', () async {
      await seedPlan(id: planUuid1, startDate: DateTime.utc(2024, 1, 1));
      await seedPlan(id: planUuid2, startDate: DateTime.utc(2024, 6, 1));
      await seedPlan(id: planUuid3, startDate: DateTime.utc(2024, 3, 1));

      final emitted = await repo.watchAllDrift().first;

      expect(emitted.map((p) => p.id).toList(), [planUuid2, planUuid3, planUuid1]);
    });

    test('addPlanLocalDrift inserts the plan', () async {
      final fresh = NutritionalPlan(
        id: planUuid1,
        description: 'fresh',
        creationDate: DateTime.utc(2024),
        startDate: DateTime.utc(2024, 1, 1),
        onlyLogging: false,
      );

      await repo.addPlanLocalDrift(fresh);

      final emitted = await repo.watchAllDrift().first;
      expect(emitted.single.id, planUuid1);
      expect(emitted.single.description, 'fresh');
    });

    test('addPlanLocalDrift mints a UUID and writes it back when id is null', () async {
      final plan = NutritionalPlan(
        description: 'no id',
        creationDate: DateTime.utc(2024),
        startDate: DateTime.utc(2024),
        onlyLogging: false,
      );

      await repo.addPlanLocalDrift(plan);

      expect(plan.id, isNotNull);
      final emitted = await repo.watchAllDrift().first;
      expect(emitted.single.id, plan.id);
      expect(emitted.single.description, 'no id');
    });

    test('editLocalDrift overwrites the plan with matching id', () async {
      await seedPlan(id: planUuid1, description: 'original');
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
      await seedPlan(id: planUuid1);
      await seedPlan(id: planUuid2);

      await repo.deleteLocalDrift(planUuid1);

      final emitted = await repo.watchAllDrift().first;
      expect(emitted.map((p) => p.id), [planUuid2]);
    });
  });

  group('Meals', () {
    const mealUuid1 = 'aa000000-0000-4000-8000-000000000001';
    const mealUuid2 = 'aa000000-0000-4000-8000-000000000002';

    test('addMealLocalDrift inserts the meal and computes order from existing rows', () async {
      await seedPlan(id: planUuid1);
      await seedMeal(id: mealUuid1, planId: planUuid1, order: 3);

      final fresh = Meal(id: mealUuid2, plan: planUuid1, name: 'lunch');
      await repo.addMealLocalDrift(fresh);

      final row = await (db.select(
        db.mealTable,
      )..where((t) => t.id.equals(mealUuid2))).getSingle();
      expect(row.name, 'lunch');
      expect(row.order, 4);
    });

    test('addMealLocalDrift mints a UUID and writes it back when id is null', () async {
      await seedPlan(id: planUuid1);
      final meal = Meal(plan: planUuid1, name: 'no id');

      await repo.addMealLocalDrift(meal);

      expect(meal.id, isNotNull);
      final row = await (db.select(
        db.mealTable,
      )..where((t) => t.id.equals(meal.id!))).getSingle();
      expect(row.name, 'no id');
    });

    test('editMealLocalDrift overwrites the meal with matching id', () async {
      await seedPlan(id: planUuid1);
      await seedMeal(id: mealUuid1, planId: planUuid1, name: 'breakfast');

      final updated = Meal(id: mealUuid1, plan: planUuid1, name: 'lunch');
      await repo.editMealLocalDrift(updated);

      final row = await (db.select(
        db.mealTable,
      )..where((t) => t.id.equals(mealUuid1))).getSingle();
      expect(row.name, 'lunch');
    });

    test('editMealLocalDrift throws StateError when id is null', () async {
      final meal = Meal(plan: planUuid1, name: 'no id');
      expect(() => repo.editMealLocalDrift(meal), throwsStateError);
    });

    test('deleteMealLocalDrift removes the meal with matching id', () async {
      await seedPlan(id: planUuid1);
      await seedMeal(id: mealUuid1, planId: planUuid1);
      await seedMeal(id: mealUuid2, planId: planUuid1);

      await repo.deleteMealLocalDrift(mealUuid1);

      final remaining = await db.select(db.mealTable).get();
      expect(remaining.map((m) => m.id), [mealUuid2]);
    });
  });

  group('Meal items', () {
    const mealUuid = 'aa000000-0000-4000-8000-000000000001';
    const itemUuid1 = 'bb000000-0000-4000-8000-000000000001';
    const itemUuid2 = 'bb000000-0000-4000-8000-000000000002';

    test('addMealItemLocalDrift inserts and computes order from existing items', () async {
      await seedPlan(id: planUuid1);
      await seedMeal(id: mealUuid, planId: planUuid1);
      await seedIngredient(id: 1, name: 'Apple');
      await seedMealItem(id: itemUuid1, mealId: mealUuid, ingredientId: 1, order: 5);

      final fresh = MealItem(id: itemUuid2, mealId: mealUuid, ingredientId: 1, amount: 200);
      await repo.addMealItemLocalDrift(fresh);

      final row = await (db.select(
        db.mealItemTable,
      )..where((t) => t.id.equals(itemUuid2))).getSingle();
      expect(row.amount, 200);
      expect(row.order, 6);
    });

    test('addMealItemLocalDrift mints a UUID and writes it back when id is null', () async {
      await seedPlan(id: planUuid1);
      await seedMeal(id: mealUuid, planId: planUuid1);
      await seedIngredient(id: 1, name: 'Apple');

      final item = MealItem(mealId: mealUuid, ingredientId: 1, amount: 50);
      await repo.addMealItemLocalDrift(item);

      expect(item.id, isNotNull);
      final row = await (db.select(
        db.mealItemTable,
      )..where((t) => t.id.equals(item.id!))).getSingle();
      expect(row.amount, 50);
    });

    test('editMealItemLocalDrift overwrites the item with matching id', () async {
      await seedPlan(id: planUuid1);
      await seedMeal(id: mealUuid, planId: planUuid1);
      await seedIngredient(id: 1, name: 'Apple');
      await seedMealItem(id: itemUuid1, mealId: mealUuid, ingredientId: 1, amount: 100);

      final updated = MealItem(id: itemUuid1, mealId: mealUuid, ingredientId: 1, amount: 250);
      await repo.editMealItemLocalDrift(updated);

      final row = await (db.select(
        db.mealItemTable,
      )..where((t) => t.id.equals(itemUuid1))).getSingle();
      expect(row.amount, 250);
    });

    test('editMealItemLocalDrift throws StateError when id is null', () async {
      final item = MealItem(mealId: mealUuid, ingredientId: 1, amount: 50);
      expect(() => repo.editMealItemLocalDrift(item), throwsStateError);
    });

    test('deleteMealItemLocalDrift removes the item with matching id', () async {
      await seedPlan(id: planUuid1);
      await seedMeal(id: mealUuid, planId: planUuid1);
      await seedIngredient(id: 1, name: 'Apple');
      await seedMealItem(id: itemUuid1, mealId: mealUuid, ingredientId: 1);
      await seedMealItem(id: itemUuid2, mealId: mealUuid, ingredientId: 1);

      await repo.deleteMealItemLocalDrift(itemUuid1);

      final remaining = await db.select(db.mealItemTable).get();
      expect(remaining.map((m) => m.id), [itemUuid2]);
    });
  });

  group('Meals, watchAllMealsHydrated', () {
    const mealUuid1 = 'aa000000-0000-4000-8000-000000000001';
    const mealUuid2 = 'aa000000-0000-4000-8000-000000000002';
    const itemUuid1 = 'bb000000-0000-4000-8000-000000000001';
    const itemUuid2 = 'bb000000-0000-4000-8000-000000000002';

    test('emits empty when no meals exist', () async {
      expect(await repo.watchAllMealsHydrated().first, isEmpty);
    });

    test('emits meals with their items hydrated and ingredients attached', () async {
      await seedPlan(id: planUuid1);
      await seedIngredient(id: 1, name: 'Apple');
      await seedMeal(id: mealUuid1, planId: planUuid1, name: 'breakfast');
      await seedMeal(id: mealUuid2, planId: planUuid1, name: 'lunch');
      await seedMealItem(id: itemUuid1, mealId: mealUuid1, ingredientId: 1, amount: 100);
      await seedMealItem(id: itemUuid2, mealId: mealUuid1, ingredientId: 1, amount: 50);

      final emitted = await repo.watchAllMealsHydrated().first;

      expect(emitted, hasLength(2));
      final breakfast = emitted.firstWhere((m) => m.id == mealUuid1);
      expect(breakfast.mealItems, hasLength(2));
      expect(breakfast.mealItems.first.ingredient?.name, 'Apple');
      final lunch = emitted.firstWhere((m) => m.id == mealUuid2);
      expect(lunch.mealItems, isEmpty);
    });

    test('meal item without a matching ingredient row hydrates with null', () async {
      // Models the window between addMealItemLocalDrift and PowerSync pulling
      // the referenced ingredient down: the meal item is visible but the
      // ingredient row is not yet local. The watcher must surface that as a
      // null ingredient rather than crash on a late field.
      await seedPlan(id: planUuid1);
      await seedMeal(id: mealUuid1, planId: planUuid1, name: 'breakfast');
      await seedMealItem(id: itemUuid1, mealId: mealUuid1, ingredientId: 42, amount: 100);

      final emitted = await repo.watchAllMealsHydrated().first;

      final item = emitted.single.mealItems.single;
      expect(item.ingredient, isNull);
      // nutritionalValues stays addressable (zeroed) so totals don't blow up.
      expect(item.nutritionalValues.energy, 0);
    });
  });

  group('Diary logs', () {
    test('watchAllLogsHydrated emits empty when no logs exist', () async {
      expect(await repo.watchAllLogsHydrated().first, isEmpty);
    });

    test('addLogLocalDrift inserts a log visible in watchAllLogsHydrated', () async {
      await seedPlan(id: planUuid1);
      await seedIngredient(id: 1, name: 'Apple');

      final log = LogItem(
        planId: planUuid1,
        ingredientId: 1,
        amount: 100,
        datetime: DateTime.utc(2026, 4, 15),
      );
      await repo.addLogLocalDrift(log);

      final emitted = await repo.watchAllLogsHydrated().first;
      expect(emitted, hasLength(1));
      expect(emitted.single.amount, 100);
      expect(emitted.single.ingredient?.name, 'Apple');
    });

    test('watchAllLogsHydrated attaches image and weight units to each ingredient', () async {
      await seedPlan(id: planUuid1);
      await seedIngredient(id: 1, name: 'Apple');
      await seedIngredientImage(id: 10, ingredientId: 1);
      await seedIngredientWeightUnit(id: 100, ingredientId: 1);
      await repo.addLogLocalDrift(
        LogItem(
          planId: planUuid1,
          ingredientId: 1,
          amount: 100,
          datetime: DateTime.utc(2026, 4, 15),
        ),
      );

      final emitted = await repo.watchAllLogsHydrated().first;

      expect(emitted.single.ingredient?.image?.id, 10);
      expect(emitted.single.ingredient?.weightUnits.single.id, 100);
    });

    test('watchAllLogsHydrated resolves weightUnitObj on the log when set', () async {
      await seedPlan(id: planUuid1);
      await seedIngredient(id: 1, name: 'Apple');
      await seedIngredientWeightUnit(id: 100, ingredientId: 1);
      await repo.addLogLocalDrift(
        LogItem(
          planId: planUuid1,
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
      await seedPlan(id: planUuid1);
      await seedIngredient(id: 1, name: 'Apple');
      await repo.addLogLocalDrift(
        LogItem(
          planId: planUuid1,
          ingredientId: 1,
          amount: 100,
          datetime: DateTime.utc(2026, 4, 15),
        ),
      );

      final emitted = await repo.watchAllLogsHydrated().first;

      expect(emitted.single.weightUnitObj, isNull);
    });

    test('deleteLogLocalDrift removes the log with matching id', () async {
      await seedPlan(id: planUuid1);
      await seedIngredient(id: 1, name: 'Apple');
      final log = LogItem(
        planId: planUuid1,
        ingredientId: 1,
        amount: 100,
        datetime: DateTime.utc(2026, 4, 15),
      );
      await db.into(db.logItemTable).insert(log.toCompanion());
      // id was null in the model, so Drift's clientDefault minted one.
      // Fetch the inserted id from the DB to use it below.
      final all = await db.select(db.logItemTable).get();
      final insertedId = all.single.id!;

      await repo.deleteLogLocalDrift(insertedId);

      expect(await db.select(db.logItemTable).get(), isEmpty);
    });
  });
}
