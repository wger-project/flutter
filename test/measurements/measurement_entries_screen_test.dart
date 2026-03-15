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
import 'package:provider/provider.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/measurements/measurement_category.dart';
import 'package:wger/providers/measurement_repository.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/screens/measurement_entries_screen.dart';

import '../../test_data/measurements.dart';
import 'measurement_entries_screen_test.mocks.dart';

@GenerateMocks([MeasurementRepository, NutritionPlansProvider])
void main() {
  late MockMeasurementRepository mockMeasurementRepo;
  late MockNutritionPlansProvider mockNutritionPlansProvider;

  setUp(() {
    mockMeasurementRepo = MockMeasurementRepository();
    when(
      mockMeasurementRepo.watchLocalDriftCategoryById(any),
    ).thenAnswer((_) => Stream<MeasurementCategory>.value(getMeasurementCategories()[0]));

    mockNutritionPlansProvider = MockNutritionPlansProvider();
    when(mockNutritionPlansProvider.currentPlan).thenReturn(null);
    when(mockNutritionPlansProvider.items).thenReturn([]);
  });

  Widget createEntriesScreen({locale = 'en'}) {
    final key = GlobalKey<NavigatorState>();

    return ProviderScope(
      overrides: [
        measurementRepositoryProvider.overrideWithValue(mockMeasurementRepo),
      ],
      child: ChangeNotifierProvider<NutritionPlansProvider>(
        create: (context) => mockNutritionPlansProvider,
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
