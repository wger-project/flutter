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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/providers/measurement_notifier.dart';
import 'package:wger/features/measurements/providers/measurement_repository.dart';
import 'package:wger/features/measurements/screens/measurement_entries_screen.dart';
import 'package:wger/features/measurements/widgets/charts.dart';
import 'package:wger/features/nutrition/providers/ingredient_repository.dart';
import 'package:wger/features/nutrition/providers/nutrition_repository.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

import '../../../../test_data/measurements.dart';
import '../../../helpers/measurement_chart_buckets.dart';
import 'measurement_entries_screen_test.mocks.dart';

@GenerateMocks([MeasurementRepository, NutritionRepository, IngredientRepository])
void main() {
  late MockMeasurementRepository mockMeasurementRepo;
  late MockNutritionRepository mockNutritionRepo;
  late MockIngredientRepository mockIngredientRepo;

  /// The fixture with its entries moved into the last few days, for the tests
  /// that need a chart in every range rather than only in the full history
  MeasurementCategory recentCategory() {
    final category = getMeasurementCategories()[0];
    return category.copyWith(
      entries: [
        for (final (index, entry) in category.entries.indexed)
          entry.copyWith(date: DateTime.now().subtract(Duration(days: index))),
      ],
    );
  }

  setUp(() {
    mockMeasurementRepo = MockMeasurementRepository();
    when(
      mockMeasurementRepo.watchLocalDriftCategoryById(any, entriesSince: anyNamed('entriesSince')),
    ).thenAnswer((_) => Stream<MeasurementCategory>.value(getMeasurementCategories()[0]));

    mockNutritionRepo = MockNutritionRepository();
    mockIngredientRepo = MockIngredientRepository();
    when(mockIngredientRepo.getById(any)).thenAnswer((_) async => null);
  });

  Widget createEntriesScreen({locale = 'en', MeasurementCategory? category}) {
    final key = GlobalKey<NavigatorState>();
    if (category != null) {
      when(
        mockMeasurementRepo.watchLocalDriftCategoryById(
          any,
          entriesSince: anyNamed('entriesSince'),
        ),
      ).thenAnswer((_) => Stream<MeasurementCategory>.value(category));
    }

    return ProviderScope(
      overrides: [
        measurementRepositoryProvider.overrideWithValue(mockMeasurementRepo),
        // The chart reads its points from the aggregated query, not from the
        // entries the category carries
        measurementChartBucketsProvider.overrideWith(
          chartBucketsFrom([category ?? getMeasurementCategories()[0]]),
        ),
        nutritionRepositoryProvider.overrideWithValue(mockNutritionRepo),
        ingredientRepositoryProvider.overrideWithValue(mockIngredientRepo),
      ],
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        navigatorKey: key,
        home: TextButton(
          onPressed: () => key.currentState!.push(
            MaterialPageRoute<void>(
              settings: const RouteSettings(arguments: '1'),
              builder: (_) => const MeasurementEntriesScreen(),
            ),
          ),
          child: Container(),
        ),
      ),
    );
  }

  testWidgets('Test the widgets on the measurement entries screen', (WidgetTester tester) async {
    await tester.pumpWidget(createEntriesScreen());
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    // Nav bar
    expect(find.text('Body fat'), findsOneWidget);

    // Entries
    expect(find.text('30 %'), findsNWidgets(1));
  });

  testWidgets('switching the range keeps the screen it already drew', (tester) async {
    // Entries in every range, so the switch is between two ranges that both
    // have something to draw
    await tester.pumpWidget(createEntriesScreen(category: recentCategory()));
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();
    expect(find.byType(MeasurementChartWidgetFl), findsOneWidget);

    // The new range watches different providers, both starting out loading:
    // this is the frame in which the screen used to drop everything it had
    await tester.ensureVisible(find.text('1 year'));
    await tester.tap(find.text('1 year'));
    await tester.pump();

    expect(find.text('Body fat'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(MeasurementChartWidgetFl), findsOneWidget);
  });

  testWidgets('Tests the localization of dates - EN', (WidgetTester tester) async {
    await tester.pumpWidget(createEntriesScreen());
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    // From the entries list and from the chart
    expect(find.text('9/10/2022'), findsWidgets);
    expect(find.text('10/5/2022'), findsWidgets);
  });

  testWidgets('Tests the localization of dates - DE', (WidgetTester tester) async {
    await tester.pumpWidget(createEntriesScreen(locale: 'de'));
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    // From the entries list and from the chart
    expect(find.text('10.9.2022'), findsWidgets);
    expect(find.text('5.10.2022'), findsWidgets);
  });
}
