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
import 'package:wger/providers/measurement.dart';
import 'package:wger/screens/measurement_categories_screen.dart';

import 'measurement_categories_screen_test.mocks.dart';

@GenerateMocks([MeasurementProvider])
void main() {
  late MeasurementProvider mockMeasurementProvider;

  setUp(() {
    mockMeasurementProvider = MockMeasurementProvider();
    when(mockMeasurementProvider.categories).thenReturn([
      MeasurementCategory(id: 1, name: 'body fat', unit: '%'),
      MeasurementCategory(id: 2, name: 'biceps', unit: 'cm'),
    ]);
  });

  Widget createHomeScreen({locale = 'en'}) {
    return ChangeNotifierProvider<MeasurementProvider>(
      create: (context) => mockMeasurementProvider,
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MeasurementCategoriesScreen(),
      ),
    );
  }

  testWidgets('Test the widgets on the measurement category screen', (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen());

    expect(find.text('Measurement categories'), findsOneWidget);
    expect(find.text('body fat'), findsOneWidget);
    expect(find.text('%'), findsOneWidget);

    expect(find.text('biceps'), findsOneWidget);
    expect(find.text('cm'), findsOneWidget);
  });
}
