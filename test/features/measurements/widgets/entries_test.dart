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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/features/measurements/charts/range.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';
import 'package:wger/features/measurements/providers/measurement_notifier.dart';
import 'package:wger/features/measurements/providers/measurement_repository.dart';
import 'package:wger/features/measurements/widgets/charts/distribution_chart.dart';
import 'package:wger/features/measurements/widgets/charts/stacked_bar_chart.dart';
import 'package:wger/features/measurements/widgets/entries.dart';
import 'package:wger/features/nutrition/providers/ingredient_repository.dart';
import 'package:wger/features/nutrition/providers/nutrition_repository.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

import '../../../../test_data/measurements.dart';
import '../../../helpers/measurement_chart_buckets.dart';
import '../../../helpers/measurement_repository_stubs.dart';
import 'entries_test.mocks.dart';

@GenerateMocks([MeasurementRepository, NutritionRepository, IngredientRepository])
void main() {
  final userEntry = MeasurementEntry(
    id: 'e-user',
    categoryId: 'c1',
    date: DateTime(2026, 1, 2),
    value: 20,
    notes: '',
  );
  final importedEntry = MeasurementEntry(
    id: 'e-import',
    categoryId: 'c1',
    date: DateTime(2026, 1, 1),
    value: 21,
    notes: '',
    source: 'apple',
    externalId: 'bf-1',
  );

  Widget createEntriesList(
    MeasurementCategory category,
    Map<String, List<MeasurementEntry>> entries, {
    MockMeasurementRepository? repo,
  }) {
    final mockRepo = repo ?? MockMeasurementRepository();
    stubMeasurementReads(mockRepo, [category], entries);

    return ProviderScope(
      overrides: [
        measurementRepositoryProvider.overrideWithValue(mockRepo),
        nutritionRepositoryProvider.overrideWithValue(MockNutritionRepository()),
        ingredientRepositoryProvider.overrideWithValue(MockIngredientRepository()),
        // The chart reads its points from the aggregated query
        measurementChartBucketsProvider.overrideWith(chartBucketsFrom(entries)),
        measurementGroupBucketsProvider.overrideWith(groupBucketsFrom([category], entries)),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: EntriesList(
              category,
              range: ChartRange.last3Months,
              onRangeChanged: (_) {},
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('Imported entries show a badge instead of the edit menu', (
    WidgetTester tester,
  ) async {
    final category = MeasurementCategory(
      id: 'c1',
      name: 'Body fat',
      unit: '%',
    );

    await tester.pumpWidget(
      createEntriesList(category, {
        'c1': [userEntry, importedEntry],
      }),
    );
    await tester.pumpAndSettle();

    // Only the manual entry has the menu, the imported one carries the badge
    expect(find.byTooltip('Show menu'), findsOneWidget);
    expect(find.byIcon(Icons.monitor_heart_outlined), findsOneWidget);
  });

  testWidgets('A calculated category is marked and its entries are read-only', (
    WidgetTester tester,
  ) async {
    final category = MeasurementCategory(
      id: 'c1',
      name: 'BMI',
      unit: 'kg/m²',
      dynamicType: 'BMI',
    );
    final calculated = MeasurementEntry(
      id: 'e-calc',
      categoryId: 'c1',
      date: DateTime(2026, 1, 2),
      value: 22,
      notes: '',
      source: 'calculated',
    );

    await tester.pumpWidget(
      createEntriesList(category, {
        'c1': [calculated],
      }),
    );
    await tester.pumpAndSettle();

    // The mark sits on the category, the rows carry no menu at all
    expect(find.text('Calculated'), findsOneWidget);
    expect(find.text('From your body weight and the height in your profile'), findsOneWidget);
    expect(find.byTooltip('Show menu'), findsNothing);
    // A calculated value is read-only for a different reason than an import,
    // and says so
    expect(find.byIcon(Icons.calculate_outlined), findsOneWidget);
    expect(
      find.byTooltip('This value is calculated by wger and cannot be edited'),
      findsOneWidget,
    );
  });

  testWidgets('A group charts its components and lists the readings', (
    WidgetTester tester,
  ) async {
    // The list defaults to the last three months, so a fixed date would fall
    // out of the range as time passes
    final night = DateTime.now().subtract(const Duration(days: 1));
    MeasurementCategory child(String id, String name, MetricType type, int order) =>
        MeasurementCategory(
          id: id,
          name: name,
          unit: 'min',
          metricType: type,
          parentId: 'sleep',
          order: order,
        );
    final group = MeasurementCategory(
      id: 'sleep',
      name: 'Sleep',
      unit: 'min',
      metricType: MetricType.sleep,
      children: [
        child('total', 'Total sleep', MetricType.sleepTotal, 0),
        child('deep', 'Deep sleep', MetricType.sleepDeep, 1),
      ],
    );
    final entries = {
      for (final (id, value) in [('total', 480), ('deep', 90)])
        id: [MeasurementEntry(id: 'e-$id', categoryId: id, date: night, value: value, notes: '')],
    };

    await tester.pumpWidget(createEntriesList(group, entries));
    await tester.pumpAndSettle();

    // The group holds no entries itself, so its own list would be empty: it
    // shows the components' readings instead, the roll-up leading
    expect(find.byType(MeasurementStackedBarChartWidgetFl), findsOneWidget);
    // A duration is read in hours and minutes, not in the minutes it is stored as
    expect(find.text('8:00 h'), findsOneWidget);
    expect(find.textContaining('Deep sleep 1:30'), findsOneWidget);
    // Each component is a way into its own screen
    expect(find.byIcon(Icons.chevron_right), findsNWidgets(2));
  });

  testWidgets('scrolling a group list asks for the next page', (WidgetTester tester) async {
    // A page is entries, a row is a reading, and a blood pressure page of
    // fifty entries lists twenty-five: reading "more to come" off the rows
    // left the list stuck on its first page
    final readings = [
      for (var day = 0; day < 40; day++) DateTime.now().subtract(Duration(days: day)),
    ];
    final group = testMeasurementCategoryBloodPressure;
    final entries = {
      for (final (id, value) in [('sys', 120), ('dia', 80)])
        id: [
          for (final (index, date) in readings.indexed)
            MeasurementEntry(id: '$id-$index', categoryId: id, date: date, value: value, notes: ''),
        ],
    };
    final mockRepo = MockMeasurementRepository();
    // Tall enough that the list below the chart is on screen and can be
    // dragged rather than the page around it
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(createEntriesList(group, entries, repo: mockRepo));
    await tester.pumpAndSettle();
    verify(mockRepo.watchGroupEntries('bp', limit: 50)).called(greaterThanOrEqualTo(1));

    // Past the end, so the assertion does not hang on a row height
    await tester.drag(find.byType(ListView).last, const Offset(0, -3000));
    await tester.pumpAndSettle();

    verify(mockRepo.watchGroupEntries('bp', limit: 100)).called(greaterThanOrEqualTo(1));
  });

  testWidgets('A distribution category draws its histogram in the chart box', (
    WidgetTester tester,
  ) async {
    // The histogram fills the height it is given, and the list around it is a
    // scrollable: an unbounded box reaching it is a layout error
    final category = MeasurementCategory(
      id: 'c1',
      name: 'Bizeps',
      unit: 'cm',
      chartType: ChartType.distribution,
    );
    final entries = [
      for (var day = 0; day < 30; day++)
        MeasurementEntry(
          id: 'e-$day',
          categoryId: 'c1',
          date: DateTime.now().subtract(Duration(days: day)),
          value: 30 + day % 5,
          notes: '',
        ),
    ];

    await tester.pumpWidget(createEntriesList(category, {'c1': entries}));
    await tester.pumpAndSettle();

    expect(find.byType(MeasurementDistributionWidgetFl), findsOneWidget);
  });
}
