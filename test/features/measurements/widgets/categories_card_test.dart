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

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';
import 'package:wger/features/measurements/widgets/categories_card.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

import '../../../../test_data/measurements.dart';

Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

MeasurementCategory _bpGroup({bool withEntries = false}) {
  final sysEntries = withEntries ? [testNeasurementEntry9] : <MeasurementEntry>[];
  final diaEntries = withEntries ? [testNeasurementEntry10] : <MeasurementEntry>[];
  final sys = testMeasurementCategorySystolic.copyWith(entries: sysEntries);
  final dia = testMeasurementCategoryDiastolic.copyWith(entries: diaEntries);

  return testMeasurementCategoryBloodPressure.copyWith(children: [sys, dia]);
}

void main() {
  group('CategoriesCard group card', () {
    testWidgets('shows one ListTile per child with latest reading', (tester) async {
      await tester.pumpWidget(_wrap(CategoriesCard(_bpGroup(withEntries: true))));
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsNWidgets(2));
      expect(find.textContaining('120'), findsOneWidget);
      expect(find.textContaining('80'), findsOneWidget);
    });

    testWidgets('shows dash when child has no entries', (tester) async {
      await tester.pumpWidget(_wrap(CategoriesCard(_bpGroup(withEntries: false))));
      await tester.pumpAndSettle();

      // Text('—') should appear for both children
      expect(find.text('—'), findsNWidgets(2));
    });

    testWidgets('add icon button is present on group card', (tester) async {
      await tester.pumpWidget(_wrap(CategoriesCard(_bpGroup())));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });
}
