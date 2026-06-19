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
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/measurements/measurement_category.dart';
import 'package:wger/providers/measurement_repository.dart';
import 'package:wger/screens/measurement_categories_screen.dart';
import 'package:wger/widgets/measurements/charts.dart';

import '../../test_data/measurements.dart';
import 'measurement_provider_test.mocks.dart';

@GenerateMocks([MeasurementRepository])
void main() {
  Widget createMeasurementScreen({locale = 'en'}) {
    final mockRepo = MockMeasurementRepository();
    when(
      mockRepo.watchAll(),
    ).thenAnswer((_) => Stream<List<MeasurementCategory>>.value(getMeasurementCategories()));

    return ProviderScope(
      overrides: [
        measurementRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const MeasurementCategoriesScreen(),
      ),
    );
  }

  testWidgets('Test the widgets on the measurement category screen', (WidgetTester tester) async {
    await tester.pumpWidget(createMeasurementScreen());
    await tester.pumpAndSettle();

    expect(find.text('Measurements'), findsOneWidget);
    expect(find.text('Body fat'), findsOneWidget);
    expect(find.text('Biceps'), findsOneWidget);
    expect(find.byType(Card), findsNWidgets(2));
    expect(find.byType(MeasurementChartWidgetFl), findsNWidgets(2));
  });
}
