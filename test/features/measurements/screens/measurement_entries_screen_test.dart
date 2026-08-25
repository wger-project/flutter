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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:wger/core/app_settings_notifier.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';
import 'package:wger/features/measurements/providers/measurement_notifier.dart';
import 'package:wger/features/measurements/providers/measurement_repository.dart';
import 'package:wger/features/measurements/screens/measurement_entries_screen.dart';
import 'package:wger/features/measurements/widgets/charts/line_chart.dart';
import 'package:wger/features/nutrition/providers/ingredient_repository.dart';
import 'package:wger/features/nutrition/providers/nutrition_repository.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

import '../../../../test_data/measurements.dart';
import '../../../helpers/measurement_chart_buckets.dart';
import '../../../helpers/measurement_repository_stubs.dart';
import 'measurement_entries_screen_test.mocks.dart';

@GenerateMocks([MeasurementRepository, NutritionRepository, IngredientRepository])
void main() {
  late MockMeasurementRepository mockMeasurementRepo;
  late MockNutritionRepository mockNutritionRepo;
  late MockIngredientRepository mockIngredientRepo;

  /// The fixture's entries moved into the last few days, for the tests that
  /// need a chart in every range rather than only in the full history
  Map<String, List<MeasurementEntry>> recentEntries() => {
    '1': [
      for (final (index, entry) in getMeasurementEntries()['1']!.indexed)
        entry.copyWith(date: DateTime.now().subtract(Duration(days: index))),
    ],
  };

  setUp(() {
    // The shared chart range hydrates from SharedPreferences on first read
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
    mockMeasurementRepo = MockMeasurementRepository();
    stubMeasurementReads(
      mockMeasurementRepo,
      [getMeasurementCategories()[0]],
      getMeasurementEntries(),
    );

    mockNutritionRepo = MockNutritionRepository();
    mockIngredientRepo = MockIngredientRepository();
    when(mockIngredientRepo.getById(any)).thenAnswer((_) async => null);
  });

  Widget createEntriesScreen({locale = 'en', Map<String, List<MeasurementEntry>>? entries}) {
    final key = GlobalKey<NavigatorState>();
    final seeded = entries ?? getMeasurementEntries();
    if (entries != null) {
      stubMeasurementReads(mockMeasurementRepo, [getMeasurementCategories()[0]], entries);
    }

    return ProviderScope(
      overrides: [
        measurementRepositoryProvider.overrideWithValue(mockMeasurementRepo),
        // A fresh accessor per test: the app-wide singleton keeps the
        // in-memory store of the first test alive across the file
        appSettingsPrefsProvider.overrideWithValue(SharedPreferencesAsync()),
        // The chart reads its points from the aggregated query
        measurementChartBucketsProvider.overrideWith(chartBucketsFrom(seeded)),
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

    // Nav bar, with the name a free-form category was given
    expect(find.text('Body fat'), findsOneWidget);

    // Entries, newest first
    expect(find.text('23 %'), findsNWidgets(1));
  });

  testWidgets('A typed category is titled by its metric type, not by the stored name', (
    tester,
  ) async {
    // The server and the importer create typed categories with an English
    // name; the metric type is what carries the translation
    stubMeasurementReads(
      mockMeasurementRepo,
      [
        MeasurementCategory(
          id: '1',
          name: 'Blutdruck',
          unit: 'mmHg',
          metricType: MetricType.bloodPressureSystolic,
        ),
      ],
      getMeasurementEntries(),
    );

    await tester.pumpWidget(createEntriesScreen());
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    expect(find.text('Systolic'), findsOneWidget);
    expect(find.text('Blutdruck'), findsNothing);
  });

  testWidgets('a calculated category offers no way to add an entry', (tester) async {
    stubMeasurementReads(
      mockMeasurementRepo,
      [MeasurementCategory(id: '1', name: 'BMI', unit: '', dynamicType: 'BMI')],
      getMeasurementEntries(),
    );

    await tester.pumpWidget(createEntriesScreen());
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('switching the range keeps the screen it already drew', (tester) async {
    // Entries in every range, so the switch is between two ranges that both
    // have something to draw
    await tester.pumpWidget(createEntriesScreen(entries: recentEntries()));
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

    // From the entries list, which shows the newest first
    expect(find.text('11/15/2022'), findsWidgets);
    expect(find.text('11/10/2022'), findsWidgets);
  });

  testWidgets('Tests the localization of dates - DE', (WidgetTester tester) async {
    await tester.pumpWidget(createEntriesScreen(locale: 'de'));
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    // From the entries list, which shows the newest first
    expect(find.text('15.11.2022'), findsWidgets);
    expect(find.text('10.11.2022'), findsWidgets);
  });
}
