/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 wger Team
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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mockito/annotations.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/providers/measurement_repository.dart';
import 'package:wger/features/measurements/widgets/calculation_mark.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

import '../../../helpers/measurement_repository_stubs.dart';
import 'calculation_mark_test.mocks.dart';

@GenerateMocks([MeasurementRepository])
void main() {
  final waist = MeasurementCategory(id: 'waist', name: 'Waist', unit: 'cm');

  Future<void> pump(
    WidgetTester tester,
    MeasurementCategory category, {
    bool dense = false,
  }) async {
    final repo = MockMeasurementRepository();
    stubMeasurementReads(repo, [waist, category]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [measurementRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: CalculationMark(category, dense: dense)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a hand-kept category is not marked at all', (tester) async {
    await pump(tester, MeasurementCategory(id: 'biceps', name: 'Biceps', unit: 'cm'));

    expect(find.text('Calculated'), findsNothing);
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('a calculated category gets the badge and what it is computed from', (tester) async {
    await pump(tester, MeasurementCategory(id: 'bmi', name: 'BMI', unit: '', dynamicType: 'BMI'));

    expect(find.text('Calculated'), findsOneWidget);
    expect(find.text('From your body weight and the height in your profile'), findsOneWidget);
  });

  testWidgets('the ratio names the category it reads', (tester) async {
    await pump(
      tester,
      MeasurementCategory(
        id: 'whtr',
        name: 'Waist to height',
        unit: '',
        dynamicType: 'WHTR',
        dynamicParams: const {'category_id': 'waist'},
      ),
    );

    expect(find.text('From Waist and the height in your profile'), findsOneWidget);
  });

  testWidgets('a one-rep max is badged but not explained', (tester) async {
    // The sentence would only repeat the category name, which already carries
    // the exercise
    await pump(
      tester,
      MeasurementCategory(id: '1rm', name: '1RM bench', unit: 'kg', dynamicType: 'ONE_REP_MAX'),
    );

    expect(find.text('Calculated'), findsOneWidget);
    expect(find.byType(Text), findsOneWidget);
  });

  testWidgets('a calculation from a newer server is badged but not explained', (tester) async {
    // The provenance sentence is per type, and this release has none for it
    await pump(
      tester,
      MeasurementCategory(id: 'ffmi', name: 'FFMI', unit: '', dynamicType: 'FFMI'),
    );

    expect(find.text('Calculated'), findsOneWidget);
    expect(find.byType(Text), findsOneWidget);
  });

  testWidgets('dense puts badge and provenance on one line', (tester) async {
    await pump(
      tester,
      MeasurementCategory(id: 'bmi', name: 'BMI', unit: '', dynamicType: 'BMI'),
      dense: true,
    );

    expect(find.byType(Row), findsWidgets);
    expect(find.text('From your body weight and the height in your profile'), findsOneWidget);
  });
}
