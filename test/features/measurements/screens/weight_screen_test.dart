/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020 - 2026 wger Team
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
import 'package:wger/core/form_screen.dart';
import 'package:wger/features/account/providers/user_profile_repository.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';
import 'package:wger/features/measurements/providers/measurement_repository.dart';
import 'package:wger/features/measurements/screens/weight_screen.dart';
import 'package:wger/features/measurements/widgets/chart_range_selector.dart';
import 'package:wger/features/measurements/widgets/charts.dart';
import 'package:wger/features/measurements/widgets/weight_form.dart';
import 'package:wger/features/nutrition/providers/ingredient_repository.dart';
import 'package:wger/features/nutrition/providers/nutrition_repository.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

import '../../../../test_data/body_weight.dart';
import '../../../../test_data/profile.dart';
import 'weight_screen_test.mocks.dart';

@GenerateMocks([
  NutritionRepository,
  IngredientRepository,
  MeasurementRepository,
  UserProfileRepository,
])
void main() {
  late MockNutritionRepository mockNutritionRepo;
  late MockIngredientRepository mockIngredientRepo;
  late MockUserProfileRepository mockUserProfileRepository;
  late MockMeasurementRepository mockMeasurementRepository;

  setUp(() {
    mockNutritionRepo = MockNutritionRepository();
    mockIngredientRepo = MockIngredientRepository();
    when(mockIngredientRepo.getById(any)).thenAnswer((_) async => null);

    mockUserProfileRepository = MockUserProfileRepository();
    when(
      mockUserProfileRepository.watchDrift(),
    ).thenAnswer((_) => Stream.value(tUserProfile1));

    mockMeasurementRepository = MockMeasurementRepository();
    when(
      mockMeasurementRepository.watchAll(entriesSince: anyNamed('entriesSince')),
    ).thenAnswer((_) => Stream.value([getBodyWeightCategory()]));
    when(
      mockMeasurementRepository.watchOfficialBodyWeightCategory(
        entriesSince: anyNamed('entriesSince'),
      ),
    ).thenAnswer((_) => Stream.value(getBodyWeightCategory()));
    when(
      mockMeasurementRepository.deleteLocalDrift(any),
    ).thenAnswer((_) async => Future.value());
  });

  Widget createWeightScreen({locale = 'en'}) {
    return ProviderScope(
      overrides: [
        measurementRepositoryProvider.overrideWithValue(mockMeasurementRepository),
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
    expect(find.byType(Card), findsNWidgets(2));
    expect(find.byType(ListTile), findsNWidgets(2));

    // The seeded entries are from 2021, so they only show in the full history
    await tester.ensureVisible(find.text('All'));
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
    expect(find.byType(MeasurementChartWidgetFl), findsOneWidget);
  });

  testWidgets('Weight chart range selector filters the data', (WidgetTester tester) async {
    await tester.pumpWidget(createWeightScreen());
    await tester.pumpAndSettle();

    // The range selector is shown with the three options
    expect(find.byType(ChartRangeSelector), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('1 year'), findsOneWidget);
    expect(find.text('3 months'), findsOneWidget);

    // The default range excludes the (old) seeded data
    expect(find.byType(MeasurementChartWidgetFl), findsNothing);
    expect(find.text('No data available'), findsOneWidget);

    // Switching to all time shows the chart
    await tester.ensureVisible(find.text('All'));
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
    expect(find.byType(MeasurementChartWidgetFl), findsOneWidget);

    // and back again
    await tester.ensureVisible(find.text('3 months'));
    await tester.tap(find.text('3 months'));
    await tester.pumpAndSettle();
    expect(find.byType(MeasurementChartWidgetFl), findsNothing);
  });

  testWidgets('The chart range bounds the query the entries are read with', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWeightScreen());
    await tester.pumpAndSettle();

    // The default range reads from its cutoff on
    verifyNever(mockMeasurementRepository.watchOfficialBodyWeightCategory(entriesSince: null));
    verify(
      mockMeasurementRepository.watchOfficialBodyWeightCategory(
        entriesSince: argThat(isNotNull, named: 'entriesSince'),
      ),
    ).called(greaterThanOrEqualTo(1));

    await tester.ensureVisible(find.text('All'));
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();

    // The full history has no lower bound
    verify(
      mockMeasurementRepository.watchOfficialBodyWeightCategory(entriesSince: null),
    ).called(1);
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

    // We would delete the entry from the DB (the newest entry is listed first)
    verify(mockMeasurementRepository.deleteLocalDrift('2')).called(1);
  });

  testWidgets('Test the form on the body weight screen', (WidgetTester tester) async {
    await tester.pumpWidget(createWeightScreen());
    await tester.pumpAndSettle();

    expect(find.byType(WeightForm), findsNothing);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.byType(WeightForm), findsOneWidget);
  });

  testWidgets('Converts mixed-unit entries to the profile unit', (WidgetTester tester) async {
    // 176.4 lb convert to 80.01 kg for the metric profile; the kg entry stays
    when(
      mockMeasurementRepository.watchOfficialBodyWeightCategory(
        entriesSince: anyNamed('entriesSince'),
      ),
    ).thenAnswer(
      (_) => Stream.value(getBodyWeightCategory([testWeightEntryLb, testWeightEntry1])),
    );

    await tester.pumpWidget(createWeightScreen());
    await tester.pumpAndSettle();

    // The converted value can also appear in the chart labels, so only the
    // absence of the raw lb value is asserted strictly
    expect(find.text('80.01 kg'), findsWidgets);
    expect(find.text('80 kg'), findsWidgets);
    expect(find.text('176.4 lb'), findsNothing);
    expect(find.textContaining('176.4'), findsNothing);
  });

  testWidgets('Imported entries show a badge instead of the edit menu', (
    WidgetTester tester,
  ) async {
    final imported = MeasurementEntry(
      id: 'imp',
      categoryId: testBodyWeightCategoryId,
      value: 80.5,
      date: DateTime.utc(2021, 02, 01, 9, 0),
      notes: '',
      source: 'apple',
      externalId: 'w-1',
    );
    when(
      mockMeasurementRepository.watchOfficialBodyWeightCategory(
        entriesSince: anyNamed('entriesSince'),
      ),
    ).thenAnswer(
      (_) => Stream.value(getBodyWeightCategory([imported, testWeightEntry1])),
    );

    await tester.pumpWidget(createWeightScreen());
    await tester.pumpAndSettle();

    // Only the manual entry has the menu, the imported one carries the badge
    expect(find.byTooltip('Show menu'), findsOneWidget);
    expect(find.byIcon(Icons.monitor_heart_outlined), findsOneWidget);
  });

  testWidgets('No FAB while the official category has not been synced', (
    WidgetTester tester,
  ) async {
    when(
      mockMeasurementRepository.watchOfficialBodyWeightCategory(
        entriesSince: anyNamed('entriesSince'),
      ),
    ).thenAnswer((_) => Stream.value(null));

    await tester.pumpWidget(createWeightScreen());
    // No pumpAndSettle: the overview shows an endless spinner in this state
    await tester.pump();
    await tester.pump();

    expect(find.byType(FloatingActionButton), findsNothing);
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
