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

import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/database/powersync/database.dart';
import 'package:wger/models/core/search_options.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/providers/base_provider.dart';
import 'package:wger/providers/ingredient_repository.dart';

import '../fixtures/fixture_reader.dart';
import '../helpers/in_memory_drift.dart';
import 'ingredient_repository_test.mocks.dart';

@GenerateMocks([WgerBaseProvider])
void main() {
  late DriftPowersyncDatabase db;
  late MockWgerBaseProvider mockBase;
  late IngredientRepository repo;

  setUp(() async {
    db = await openTestDatabase();
    mockBase = MockWgerBaseProvider();
    repo = IngredientRepository(mockBase, db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedIngredient({
    required int id,
    required String name,
    bool? isVegan,
    bool? isVegetarian,
    NutriScore? nutriscore,
    int languageId = 2,
  }) async {
    await db
        .into(db.ingredientTable)
        .insert(
          IngredientTableCompanion.insert(
            id: id,
            languageId: languageId,
            name: name,
            created: DateTime.utc(2024),
            energy: 100,
            carbohydrates: 10,
            protein: 5,
            fat: 5,
            isVegan: Value(isVegan),
            isVegetarian: Value(isVegetarian),
            nutriscore: Value(nutriscore),
          ),
        );
  }

  Future<void> seedImage({required int id, required int ingredientId}) async {
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
            author: const Value('someone'),
            authorUrl: '',
            title: '',
            objectUrl: '',
            derivativeSourceUrl: '',
          ),
        );
  }

  Future<void> seedWeightUnit({
    required int id,
    required int ingredientId,
    String name = 'gram',
    int grams = 100,
  }) async {
    await db
        .into(db.ingredientWeightUnitTable)
        .insert(
          IngredientWeightUnitTableCompanion.insert(
            id: id,
            uuid: 'wu-$id',
            ingredientId: ingredientId,
            name: name,
            grams: grams,
          ),
        );
  }

  group('watchById', () {
    test('emits null when no ingredient with that id exists', () async {
      final emitted = await repo.watchById(999).first;
      expect(emitted, isNull);
    });

    test('emits the ingredient with image and weight units hydrated', () async {
      await seedIngredient(id: 1, name: 'Apple');
      await seedImage(id: 10, ingredientId: 1);
      await seedWeightUnit(id: 100, ingredientId: 1);
      await seedWeightUnit(id: 101, ingredientId: 1, name: 'kg', grams: 1000);

      final emitted = await repo.watchById(1).first;

      expect(emitted, isNotNull);
      expect(emitted!.id, 1);
      expect(emitted.image?.id, 10);
      expect(emitted.weightUnits, hasLength(2));
      expect(emitted.weightUnits.map((w) => w.id).toSet(), {100, 101});
    });
  });

  group('getById', () {
    test('returns the ingredient once if it exists', () async {
      await seedIngredient(id: 1, name: 'Apple');

      final result = await repo.getById(1);

      expect(result?.id, 1);
    });

    test('returns null when nothing matches', () async {
      expect(await repo.getById(999), isNull);
    });
  });

  group('searchIngredientLocal', () {
    test('matches a substring of the name, case-insensitive', () async {
      await seedIngredient(id: 1, name: 'Greek Yoghurt');
      await seedIngredient(id: 2, name: 'Apple');

      final results = await repo.searchIngredientLocal('YOGH');

      expect(results.map((i) => i.id), [1]);
    });

    test('isVegan filter excludes non-vegan rows', () async {
      await seedIngredient(id: 1, name: 'Tofu', isVegan: true);
      await seedIngredient(id: 2, name: 'Tofu Cheese', isVegan: false);

      final results = await repo.searchIngredientLocal('Tofu', isVegan: true);

      expect(results.map((i) => i.id), [1]);
    });

    test('isVegetarian filter excludes non-vegetarian rows', () async {
      await seedIngredient(id: 1, name: 'Quark', isVegetarian: true);
      await seedIngredient(id: 2, name: 'Quark Stew', isVegetarian: false);

      final results = await repo.searchIngredientLocal('Quark', isVegetarian: true);

      expect(results.map((i) => i.id), [1]);
    });

    test('nutriscoreMax keeps only rows whose Nutri-Score is at or below the cap', () async {
      await seedIngredient(id: 1, name: 'A-tier', nutriscore: NutriScore.a);
      await seedIngredient(id: 2, name: 'B-tier', nutriscore: NutriScore.b);
      await seedIngredient(id: 3, name: 'D-tier', nutriscore: NutriScore.d);

      final results = await repo.searchIngredientLocal('tier', nutriscoreMax: NutriScore.b);

      expect(results.map((i) => i.id).toSet(), {1, 2});
    });

    test('limit caps the number of returned rows', () async {
      for (var i = 1; i <= 5; i++) {
        await seedIngredient(id: i, name: 'apple-$i');
      }

      final results = await repo.searchIngredientLocal('apple', limit: 3);

      expect(results, hasLength(3));
    });

    test('returns ingredients sorted by name', () async {
      await seedIngredient(id: 1, name: 'Cherry');
      await seedIngredient(id: 2, name: 'Apple');
      await seedIngredient(id: 3, name: 'Banana');

      final results = await repo.searchIngredientLocal('');

      expect(results.map((i) => i.name).toList(), ['Apple', 'Banana', 'Cherry']);
    });

    test('hydrates image and weight units on each row', () async {
      await seedIngredient(id: 1, name: 'Apple');
      await seedImage(id: 10, ingredientId: 1);
      await seedWeightUnit(id: 100, ingredientId: 1);

      final results = await repo.searchIngredientLocal('Apple');

      expect(results.single.image?.id, 10);
      expect(results.single.weightUnits.single.id, 100);
    });
  });

  group('searchIngredientServer', () {
    final uri = Uri.https('localhost', 'api/v2/ingredientinfo/');

    test('returns empty for terms <= 1 char', () async {
      expect(await repo.searchIngredientServer(''), isEmpty);
      expect(await repo.searchIngredientServer('a'), isEmpty);
      verifyNever(mockBase.fetch(any));
    });

    test('current language: passes the languageCode in the query', () async {
      when(mockBase.makeUrl('ingredientinfo', query: anyNamed('query'))).thenReturn(uri);
      when(
        mockBase.fetch(uri, timeout: anyNamed('timeout')),
      ).thenAnswer((_) async => {'results': []});

      await repo.searchIngredientServer('apple', languageCode: 'de');

      final captured =
          verify(
                mockBase.makeUrl('ingredientinfo', query: captureAnyNamed('query')),
              ).captured.single
              as Map<String, dynamic>;
      expect(captured['language__code'], 'de');
      expect(captured['name__search'], 'apple');
    });

    test('currentAndEnglish: appends "en" when languageCode is not "en"', () async {
      when(mockBase.makeUrl('ingredientinfo', query: anyNamed('query'))).thenReturn(uri);
      when(
        mockBase.fetch(uri, timeout: anyNamed('timeout')),
      ).thenAnswer((_) async => {'results': []});

      await repo.searchIngredientServer(
        'apple',
        languageCode: 'de',
        searchLanguage: SearchLanguage.currentAndEnglish,
      );

      final captured =
          verify(
                mockBase.makeUrl('ingredientinfo', query: captureAnyNamed('query')),
              ).captured.single
              as Map<String, dynamic>;
      expect(captured['language__code'], 'de,en');
    });

    test('currentAndEnglish: does not duplicate when languageCode is already "en"', () async {
      when(mockBase.makeUrl('ingredientinfo', query: anyNamed('query'))).thenReturn(uri);
      when(
        mockBase.fetch(uri, timeout: anyNamed('timeout')),
      ).thenAnswer((_) async => {'results': []});

      await repo.searchIngredientServer(
        'apple',
        languageCode: 'en',
        searchLanguage: SearchLanguage.currentAndEnglish,
      );

      final captured =
          verify(
                mockBase.makeUrl('ingredientinfo', query: captureAnyNamed('query')),
              ).captured.single
              as Map<String, dynamic>;
      expect(captured['language__code'], 'en');
    });

    test('all: omits language_code from the query', () async {
      when(mockBase.makeUrl('ingredientinfo', query: anyNamed('query'))).thenReturn(uri);
      when(
        mockBase.fetch(uri, timeout: anyNamed('timeout')),
      ).thenAnswer((_) async => {'results': []});

      await repo.searchIngredientServer(
        'apple',
        searchLanguage: SearchLanguage.all,
      );

      final captured =
          verify(
                mockBase.makeUrl('ingredientinfo', query: captureAnyNamed('query')),
              ).captured.single
              as Map<String, dynamic>;
      expect(captured.containsKey('language__code'), isFalse);
    });

    test('isVegan, isVegetarian, nutriscoreMax flags get added when set', () async {
      when(mockBase.makeUrl('ingredientinfo', query: anyNamed('query'))).thenReturn(uri);
      when(
        mockBase.fetch(uri, timeout: anyNamed('timeout')),
      ).thenAnswer((_) async => {'results': []});

      await repo.searchIngredientServer(
        'apple',
        isVegan: true,
        isVegetarian: true,
        nutriscoreMax: NutriScore.c,
      );

      final captured =
          verify(
                mockBase.makeUrl('ingredientinfo', query: captureAnyNamed('query')),
              ).captured.single
              as Map<String, dynamic>;
      expect(captured['is_vegan'], 'true');
      expect(captured['is_vegetarian'], 'true');
      expect(captured['nutriscore__lte'], 'c');
    });

    test('parses results into Ingredient list', () async {
      final ingredientJson = jsonDecode(fixture('nutrition/ingredientinfo_10065.json'));
      when(mockBase.makeUrl('ingredientinfo', query: anyNamed('query'))).thenReturn(uri);
      when(mockBase.fetch(uri, timeout: anyNamed('timeout'))).thenAnswer(
        (_) async => {
          'results': [ingredientJson],
        },
      );

      final result = await repo.searchIngredientServer('apple');

      expect(result, hasLength(1));
      expect(result.single.id, 10065);
    });
  });

  group('searchIngredientByBarcode', () {
    final uri = Uri.https('localhost', 'api/v2/ingredientinfo/');

    test('returns null when barcode is empty', () async {
      expect(await repo.searchIngredientByBarcode(''), isNull);
      verifyNever(mockBase.fetch(any));
    });

    test('returns null when the API returns count=0', () async {
      when(mockBase.makeUrl('ingredientinfo', query: anyNamed('query'))).thenReturn(uri);
      when(mockBase.fetch(uri)).thenAnswer((_) async => {'count': 0, 'results': []});

      expect(await repo.searchIngredientByBarcode('123'), isNull);
    });

    test('returns the first result when count > 0', () async {
      final ingredientJson = jsonDecode(fixture('nutrition/ingredientinfo_10065.json'));
      when(mockBase.makeUrl('ingredientinfo', query: anyNamed('query'))).thenReturn(uri);
      when(mockBase.fetch(uri)).thenAnswer(
        (_) async => {
          'count': 1,
          'results': [ingredientJson],
        },
      );

      final result = await repo.searchIngredientByBarcode('0043647440020');

      expect(result?.id, 10065);
    });
  });
}
