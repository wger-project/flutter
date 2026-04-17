/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/body_weight_repository.dart';
import 'package:wger/providers/ingredient_repository.dart';
import 'package:wger/providers/nutrition_repository.dart';
import 'package:wger/providers/user_profile_repository.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/screens/weight_screen.dart';
import 'package:wger/widgets/measurements/charts.dart';
import 'package:wger/widgets/weight/forms.dart';

import '../../test_data/body_weight.dart';
import '../../test_data/profile.dart';
import 'weight_screen_test.mocks.dart';

@GenerateMocks([
  NutritionRepository,
  IngredientRepository,
  BodyWeightRepository,
  UserProfileRepository,
])
void main() {
  late MockNutritionRepository mockNutritionRepo;
  late MockIngredientRepository mockIngredientRepo;
  late MockUserProfileRepository mockUserProfileRepository;
  MockBodyWeightRepository mockBodyWeightRepository = MockBodyWeightRepository();

  setUp(() {
    mockNutritionRepo = MockNutritionRepository();
    mockIngredientRepo = MockIngredientRepository();
    when(mockIngredientRepo.getById(any)).thenAnswer((_) async => null);

    mockUserProfileRepository = MockUserProfileRepository();
    when(mockUserProfileRepository.fetchProfile()).thenAnswer((_) async => tProfile1);

    mockBodyWeightRepository = MockBodyWeightRepository();
    when(
      mockBodyWeightRepository.watchAllDrift(),
    ).thenAnswer((_) => Stream.value(getWeightEntries()));
    when(
      mockBodyWeightRepository.deleteLocalDrift(any),
    ).thenAnswer((_) async => Future.value());
  });

  Widget createWeightScreen({locale = 'en'}) {
    return ProviderScope(
      overrides: [
        bodyWeightRepositoryProvider.overrideWithValue(mockBodyWeightRepository),
        userProfileRepositoryProvider.overrideWithValue(mockUserProfileRepository),
        nutritionRepositoryProvider.overrideWithValue(mockNutritionRepo),
        ingredientRepositoryProvider.overrideWithValue(mockIngredientRepo),
      ],
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const WeightScreen(),
        routes: {FormScreen.routeName: (_) => const FormScreen()},
      ),
    );
  }

  testWidgets('Test the widgets on the body weight screen', (WidgetTester tester) async {
    await tester.pumpWidget(createWeightScreen());
    await tester.pumpAndSettle();

    expect(find.text('Weight'), findsOneWidget);
    expect(find.byType(MeasurementChartWidgetFl), findsOneWidget);
    expect(find.byType(Card), findsNWidgets(2));
    expect(find.byType(ListTile), findsNWidgets(2));
  });

  testWidgets('Test deleting an item using the Delete button', (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(createWeightScreen());
    await tester.pumpAndSettle();

    // Act
    expect(find.byType(ListTile), findsNWidgets(2));
    await tester.tap(find.byTooltip('Show menu').first);
    await tester.pumpAndSettle();

    // Assert
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    // We would delete the entry from the DB
    verify(mockBodyWeightRepository.deleteLocalDrift('1')).called(1);
  });

  testWidgets('Test the form on the body weight screen', (WidgetTester tester) async {
    await tester.pumpWidget(createWeightScreen());
    await tester.pumpAndSettle();

    expect(find.byType(WeightForm), findsNothing);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.byType(WeightForm), findsOneWidget);
  });

  testWidgets('Tests the localization of dates - EN', (WidgetTester tester) async {
    await tester.pumpWidget(createWeightScreen());
    await tester.pumpAndSettle();
    // these don't work because we only have 2 points, and to prevent overlaps we don't display their titles
    // expect(find.text('1/1'), findsOneWidget);
    //  expect(find.text('1/10'), findsOneWidget);
  });

  testWidgets('Tests the localization of dates - DE', (WidgetTester tester) async {
    await tester.pumpWidget(createWeightScreen(locale: 'de'));
    await tester.pumpAndSettle();
    // these don't work because we only have 2 points, and to prevent overlaps we don't display their titles
    // expect(find.text('1.1.'), findsOneWidget);
    // expect(find.text('10.1.'), findsOneWidget);
  });
}
