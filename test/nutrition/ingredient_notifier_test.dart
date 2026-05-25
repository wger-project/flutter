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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/providers/ingredient_notifier.dart';
import 'package:wger/providers/ingredient_repository.dart';

import 'ingredient_notifier_test.mocks.dart';

@GenerateMocks([IngredientRepository])
void main() {
  late MockIngredientRepository mockRepo;

  setUp(() {
    mockRepo = MockIngredientRepository();
  });

  ProviderContainer makeContainer() {
    return ProviderContainer.test(
      overrides: [
        ingredientRepositoryProvider.overrideWithValue(mockRepo),
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

  group('allLocalIngredientsProvider', () {
    test('emits the repository stream', () async {
      final apple = makeIngredient(1, 'Apple');
      when(mockRepo.watchAllDrift()).thenAnswer((_) => Stream.value([apple]));

      final container = makeContainer();
      // Explicit listen() keeps the autoDispose provider alive long enough
      // for the stream's first event to land.
      container.listen(allLocalIngredientsProvider, (_, _) {});
      await pumpEventQueue();
      final result = container.read(allLocalIngredientsProvider).requireValue;

      expect(result.single.id, 1);
      verify(mockRepo.watchAllDrift()).called(1);
    });
  });

  group('ingredientByIdProvider', () {
    test('reads from the repository by id', () async {
      final apple = makeIngredient(1, 'Apple');
      when(mockRepo.getById(1)).thenAnswer((_) async => apple);

      final container = makeContainer();
      final result = await container.read(ingredientByIdProvider(1).future);

      expect(result?.id, 1);
      verify(mockRepo.getById(1)).called(1);
    });

    test('returns null when the repo returns null', () async {
      when(mockRepo.getById(99)).thenAnswer((_) async => null);

      final container = makeContainer();
      final result = await container.read(ingredientByIdProvider(99).future);

      expect(result, isNull);
    });

    test('concurrent reads of the same id share a single repo call', () async {
      final apple = makeIngredient(1, 'Apple');
      when(mockRepo.getById(1)).thenAnswer((_) async => apple);

      final container = makeContainer();
      final results = await Future.wait([
        container.read(ingredientByIdProvider(1).future),
        container.read(ingredientByIdProvider(1).future),
      ]);

      expect(results.map((i) => i?.id), [1, 1]);
      // Riverpod's per-family caching dedupes the repo call.
      verify(mockRepo.getById(1)).called(1);
    });
  });
}
