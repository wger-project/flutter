import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/database/ingredients/ingredients_database.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/providers/nutrition.dart';

import '../fixtures/fixture_reader.dart';
import '../measurements/measurement_provider_test.mocks.dart';

void main() {
  late NutritionPlansProvider nutritionProvider;
  late MockWgerBaseProvider mockWgerBaseProvider;
  late IngredientDatabase database;
  late Map<String, dynamic> ingredient59887Response;

  setUp(() {
    database = IngredientDatabase.inMemory(NativeDatabase.memory());
    mockWgerBaseProvider = MockWgerBaseProvider();
    nutritionProvider = NutritionPlansProvider(
      mockWgerBaseProvider,
      [],
      database: database,
    );

    const String planInfoUrl = 'nutritionplaninfo';
    const String planUrl = 'nutritionplan';
    const String diaryUrl = 'nutritiondiary';
    const String ingredientInfoUrl = 'ingredientinfo';

    final Map<String, dynamic> nutritionalPlanInfoResponse = jsonDecode(
      fixture('nutrition/nutritional_plan_info_detail_response.json'),
    );
    final Map<String, dynamic> nutritionalPlanDetailResponse = jsonDecode(
      fixture('nutrition/nutritional_plan_detail_response.json'),
    );
    final List<dynamic> nutritionDiaryResponse = jsonDecode(
      fixture('nutrition/nutrition_diary_response.json'),
    )['results'];
    ingredient59887Response = jsonDecode(
      fixture('nutrition/ingredientinfo_59887.json'),
    );
    final Map<String, dynamic> ingredient10065Response = jsonDecode(
      fixture('nutrition/ingredientinfo_10065.json'),
    );
    final Map<String, dynamic> ingredient58300Response = jsonDecode(
      fixture('nutrition/ingredientinfo_58300.json'),
    );

    final ingredientList = [
      Ingredient.fromJson(ingredient59887Response),
      Ingredient.fromJson(ingredient10065Response),
      Ingredient.fromJson(ingredient58300Response),
    ];

    nutritionProvider.ingredients = ingredientList;

    final Uri planInfoUri = Uri(
      scheme: 'http',
      host: 'localhost',
      path: 'api/v2/$planInfoUrl/1',
    );
    final Uri planUri = Uri(
      scheme: 'http',
      host: 'localhost',
      path: 'api/v2/$planUrl',
    );
    final Uri diaryUri = Uri(
      scheme: 'http',
      host: 'localhost',
      path: 'api/v2/$diaryUrl',
    );
    final Uri ingredientUri = Uri(
      scheme: 'http',
      host: 'localhost',
      path: 'api/v2/$ingredientInfoUrl',
    );
    when(mockWgerBaseProvider.makeUrl(planInfoUrl, id: anyNamed('id'))).thenReturn(planInfoUri);
    when(mockWgerBaseProvider.makeUrl(planUrl, id: anyNamed('id'))).thenReturn(planUri);
    when(mockWgerBaseProvider.makeUrl(diaryUrl, query: anyNamed('query'))).thenReturn(diaryUri);
    when(mockWgerBaseProvider.makeUrl(ingredientInfoUrl, id: anyNamed('id')))
        .thenReturn(ingredientUri);
    when(mockWgerBaseProvider.fetch(planInfoUri)).thenAnswer(
      (realInvocation) => Future.value(nutritionalPlanInfoResponse),
    );
    when(mockWgerBaseProvider.fetch(planUri)).thenAnswer(
      (realInvocation) => Future.value(nutritionalPlanDetailResponse),
    );
    when(mockWgerBaseProvider.fetchPaginated(diaryUri)).thenAnswer(
      (realInvocation) => Future.value(nutritionDiaryResponse),
    );
    when(mockWgerBaseProvider.fetch(ingredientUri)).thenAnswer(
      (realInvocation) => Future.value(ingredient10065Response),
    );
  });

  tearDown(() async {
    await database.close();
  });

  group('fetchAndSetPlanFull', () {
    test('should correctly load a full nutritional plan', () async {
      // arrange
      await nutritionProvider.fetchAndSetPlanFull(1);

      // assert
      expect(nutritionProvider.items.isEmpty, false);
    });
  });

  group('Ingredient cache DB', () {
    test('that if there is already valid data in the DB, the API is not hit', () async {
      // Arrange
      nutritionProvider.ingredients = [];
      await database.into(database.ingredients).insert(
            IngredientsCompanion.insert(
              id: ingredient59887Response['id'],
              data: json.encode(ingredient59887Response),
              lastFetched: DateTime.now(),
            ),
          );

      // Act
      await nutritionProvider.fetchIngredient(59887, database: database);

      // Assert
      expect(nutritionProvider.ingredients.length, 1);
      expect(nutritionProvider.ingredients.first.id, 59887);
      expect(nutritionProvider.ingredients.first.name, 'Baked Beans');
      verifyNever(mockWgerBaseProvider.fetchPaginated(any));
    });

    test('fetching an ingredient not present in the DB, the API is hit', () async {
      // Arrange
      nutritionProvider.ingredients = [];
      await database.into(database.ingredients).insert(
            IngredientsCompanion.insert(
              id: ingredient59887Response['id'],
              data: json.encode(ingredient59887Response),
              lastFetched: DateTime.now(),
            ),
          );

      // Act
      await nutritionProvider.fetchIngredient(10065, database: database);

      // Assert
      expect(nutritionProvider.ingredients.length, 1);
      expect(nutritionProvider.ingredients.first.id, 10065);
      expect(nutritionProvider.ingredients.first.name, "'Old Times' Orange Fine Cut Marmalade");
      verify(mockWgerBaseProvider.fetch(any));
    });
  });
}
