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
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wger/models/measurements/measurement_category.dart';
import 'package:wger/models/measurements/measurement_entry.dart';
import 'package:wger/providers/measurement.dart';
import 'package:wger/screens/measurement_entries_screen.dart';

import 'measurement_categories_screen_test.mocks.dart';

void main() {
  late MockMeasurementProvider mockMeasurementProvider;

  setUp(() {
    mockMeasurementProvider = MockMeasurementProvider();
    when(mockMeasurementProvider.findCategoryById(any)).thenReturn(
      MeasurementCategory(id: 1, name: 'body fat', unit: '%', entries: [
        MeasurementEntry(id: 1, category: 1, date: DateTime(2021, 8, 1), value: 10.2, notes: ''),
        MeasurementEntry(id: 1, category: 1, date: DateTime(2021, 8, 10), value: 18.1, notes: 'a'),
      ]),
    );
  });

  Widget createHomeScreen({locale = 'en'}) {
    final key = GlobalKey<NavigatorState>();

    return ChangeNotifierProvider<MeasurementProvider>(
      create: (context) => mockMeasurementProvider,
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        navigatorKey: key,
        home: TextButton(
          onPressed: () => key.currentState!.push(
            MaterialPageRoute<void>(
              settings: const RouteSettings(arguments: 1),
              builder: (_) => const MeasurementEntriesScreen(),
            ),
          ),
          child: Container(),
        ),
      ),
    );
  }

  testWidgets('Test the widgets on the measurement entries screen', (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen());
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    // Nav bar
    expect(find.text('body fat'), findsOneWidget);

    // Entries
    expect(find.text('10.2 %'), findsNWidgets(2));
    expect(find.text('18.1 %'), findsNWidgets(2));
  });

  testWidgets('Tests the localization of dates - EN', (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen());
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    // From the entries list and from the chart
    expect(find.text('8/1/2021'), findsWidgets);
    expect(find.text('8/10/2021'), findsWidgets);
  });

  testWidgets('Tests the localization of dates - DE', (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen(locale: 'de'));
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    expect(find.text('1.8.2021'), findsWidgets);
    expect(find.text('10.8.2021'), findsWidgets);
  });
}
