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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wger/models/measurements/measurement_category.dart';
import 'package:wger/models/measurements/measurement_entry.dart';
import 'package:wger/providers/measurement.dart';
import 'package:wger/screens/measurement_categories_screen.dart';
import 'package:wger/widgets/measurements/charts.dart';

import 'measurement_categories_screen_test.mocks.dart';

@GenerateMocks([MeasurementProvider])
void main() {
  late MeasurementProvider mockMeasurementProvider;

  setUp(() {
    mockMeasurementProvider = MockMeasurementProvider();
    when(mockMeasurementProvider.categories).thenReturn([
      MeasurementCategory(id: 1, name: 'body fat', unit: '%', entries: [
        MeasurementEntry(id: 1, category: 1, date: DateTime(2021, 9, 1), value: 10, notes: ''),
        MeasurementEntry(id: 2, category: 1, date: DateTime(2021, 9, 5), value: 11, notes: ''),
      ]),
      MeasurementCategory(id: 2, name: 'biceps', unit: 'cm', entries: [
        MeasurementEntry(id: 3, category: 2, date: DateTime(2021, 9, 1), value: 30, notes: ''),
        MeasurementEntry(id: 4, category: 2, date: DateTime(2021, 9, 5), value: 40, notes: ''),
      ]),
    ]);
  });

  Widget createHomeScreen({locale = 'en'}) {
    return ChangeNotifierProvider<MeasurementProvider>(
      create: (context) => mockMeasurementProvider,
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const MeasurementCategoriesScreen(),
      ),
    );
  }

  testWidgets('Test the widgets on the measurement category screen', (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen());
    await tester.pumpAndSettle();

    expect(find.text('Measurements'), findsOneWidget);
    expect(find.text('body fat'), findsOneWidget);
    expect(find.text('biceps'), findsOneWidget);
    expect(find.byType(Card), findsNWidgets(2));
    expect(find.byType(MeasurementChartWidgetFl), findsNWidgets(2));
  });
}
