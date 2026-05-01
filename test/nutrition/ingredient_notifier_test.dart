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

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/providers/ingredient_notifier.dart';
import 'package:wger/providers/ingredient_repository.dart';
import 'package:wger/providers/network_provider.dart';

import 'ingredient_notifier_test.mocks.dart';

@GenerateMocks([IngredientRepository])
void main() {
  late MockIngredientRepository mockRepo;

  setUp(() {
    mockRepo = MockIngredientRepository();
  });

  ProviderContainer makeContainer({bool isOnline = true}) {
    return ProviderContainer.test(
      overrides: [
        ingredientRepositoryProvider.overrideWithValue(mockRepo),
        networkStatusProvider.overrideWithValue(isOnline),
      ],
    );
  }

  Ingredient makeIngredient(int id, String name) {
    return Ingredient(
      id: id,
      languageId: 2,
      name: name,
      created: DateTime.utc(2024),
      energy: 100,
      carbohydrates: 10,
      protein: 5,
      fat: 5,
      remoteId: null,
      sourceName: null,
      sourceUrl: null,
      code: null,
    );
  }

  group('fetch', () {
    test('reads from the repository on the first call', () async {
      final apple = makeIngredient(1, 'Apple');
      when(mockRepo.getById(1)).thenAnswer((_) async => apple);
      final container = makeContainer();
      // build() must complete before we can call methods on the notifier.
      await container.read(ingredientProvider.future);

      final result = await container.read(ingredientProvider.notifier).fetch(1);

      expect(result?.id, 1);
      verify(mockRepo.getById(1)).called(1);
    });

    test('returns null and caches when the repo returns null', () async {
      when(mockRepo.getById(99)).thenAnswer((_) async => null);
      final container = makeContainer();
      await container.read(ingredientProvider.future);
      final notifier = container.read(ingredientProvider.notifier);

      expect(await notifier.fetch(99), isNull);
      // Second call hits the cache (still null) and does NOT re-call the repo.
      expect(await notifier.fetch(99), isNull);
      verify(mockRepo.getById(99)).called(1);
    });

    test('serves cached value without hitting the repo on the second call', () async {
      final apple = makeIngredient(1, 'Apple');
      when(mockRepo.getById(1)).thenAnswer((_) async => apple);
      final container = makeContainer();
      await container.read(ingredientProvider.future);
      final notifier = container.read(ingredientProvider.notifier);

      await notifier.fetch(1);
      await notifier.fetch(1);

      verify(mockRepo.getById(1)).called(1);
    });

    test('deduplicates concurrent calls for the same id', () async {
      final apple = makeIngredient(1, 'Apple');
      // Use a deferred future so both calls land while the first is in-flight.
      final completer = Completer<Ingredient?>();
      when(mockRepo.getById(1)).thenAnswer((_) => completer.future);
      final container = makeContainer();
      await container.read(ingredientProvider.future);
      final notifier = container.read(ingredientProvider.notifier);

      final f1 = notifier.fetch(1);
      final f2 = notifier.fetch(1);
      completer.complete(apple);
      final results = await Future.wait([f1, f2]);

      expect(results[0]?.id, 1);
      expect(results[1]?.id, 1);
      verify(mockRepo.getById(1)).called(1);
    });
  });

  group('searchIngredient', () {
    test('routes to the server when online', () async {
      when(
        mockRepo.searchIngredientServer(
          any,
          languageCode: anyNamed('languageCode'),
          searchLanguage: anyNamed('searchLanguage'),
          isVegan: anyNamed('isVegan'),
          isVegetarian: anyNamed('isVegetarian'),
          nutriscoreMax: anyNamed('nutriscoreMax'),
        ),
      ).thenAnswer((_) async => [makeIngredient(1, 'Apple')]);
      final container = makeContainer(isOnline: true);
      await container.read(ingredientProvider.future);

      final result = await container
          .read(ingredientProvider.notifier)
          .searchIngredient(
            'apple',
            languageCode: 'de',
            searchLanguage: IngredientSearchLanguage.currentAndEnglish,
            isVegan: true,
            isVegetarian: true,
            nutriscoreMax: NutriScore.b,
          );

      expect(result, hasLength(1));
      verify(
        mockRepo.searchIngredientServer(
          'apple',
          languageCode: 'de',
          searchLanguage: IngredientSearchLanguage.currentAndEnglish,
          isVegan: true,
          isVegetarian: true,
          nutriscoreMax: NutriScore.b,
        ),
      ).called(1);
      verifyNever(
        mockRepo.searchIngredientLocal(
          any,
          isVegan: anyNamed('isVegan'),
          isVegetarian: anyNamed('isVegetarian'),
          nutriscoreMax: anyNamed('nutriscoreMax'),
        ),
      );
    });

    test('routes to the local search when offline', () async {
      when(
        mockRepo.searchIngredientLocal(
          any,
          isVegan: anyNamed('isVegan'),
          isVegetarian: anyNamed('isVegetarian'),
          nutriscoreMax: anyNamed('nutriscoreMax'),
        ),
      ).thenAnswer((_) async => [makeIngredient(2, 'Tofu')]);
      final container = makeContainer(isOnline: false);
      await container.read(ingredientProvider.future);

      final result = await container
          .read(ingredientProvider.notifier)
          .searchIngredient(
            'tofu',
            isVegan: true,
            nutriscoreMax: NutriScore.a,
          );

      expect(result, hasLength(1));
      verify(
        mockRepo.searchIngredientLocal(
          'tofu',
          isVegan: true,
          isVegetarian: false,
          nutriscoreMax: NutriScore.a,
        ),
      ).called(1);
      verifyNever(
        mockRepo.searchIngredientServer(
          any,
          languageCode: anyNamed('languageCode'),
          searchLanguage: anyNamed('searchLanguage'),
          isVegan: anyNamed('isVegan'),
          isVegetarian: anyNamed('isVegetarian'),
          nutriscoreMax: anyNamed('nutriscoreMax'),
        ),
      );
    });
  });
}
