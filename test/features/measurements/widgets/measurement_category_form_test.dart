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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/providers/measurement_repository.dart';
import 'package:wger/features/measurements/widgets/forms.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

import '../../../../test_data/measurements.dart';
import '../providers/measurement_notifier_test.mocks.dart';

Widget _wrap(Widget child, MockMeasurementRepository mockRepo) {
  return ProviderScope(
    overrides: [
      measurementRepositoryProvider.overrideWithValue(mockRepo),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(child: child),
      ),
    ),
  );
}

void main() {
  late MockMeasurementRepository mockRepo;

  setUp(() {
    mockRepo = MockMeasurementRepository();
    when(mockRepo.watchAll()).thenAnswer((_) => Stream.value([]));
  });

  group('MeasurementCategoryForm validation', () {
    testWidgets('empty name fails validation', (tester) async {
      await tester.pumpWidget(_wrap(const MeasurementCategoryForm(), mockRepo));
      await tester.pumpAndSettle();

      // Tap save without entering any text
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Check for validation errors.
      final error = find.byWidgetPredicate((widget) {
        if (widget is TextField) {
          return widget.decoration?.errorText != null;
        }
        return false;
      });
      expect(error, findsAtLeastNWidgets(1));
    });

    testWidgets('empty unit field fails validation', (tester) async {
      await tester.pumpWidget(_wrap(const MeasurementCategoryForm(), mockRepo));
      await tester.pumpAndSettle();

      // Fill name but leave unit empty
      await tester.enterText(find.byType(TextFormField).first, 'Body fat');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // still on same screen
      expect(find.byType(MeasurementCategoryForm), findsOneWidget);
    });

    testWidgets('metricType dropdown renders all MetricType values', (tester) async {
      await tester.pumpWidget(_wrap(const MeasurementCategoryForm(), mockRepo));
      await tester.pumpAndSettle();

      // Open the dropdown
      await tester.tap(find.byType(DropdownButtonFormField<MetricType>));
      await tester.pumpAndSettle();

      // We expect N + 1 items here because when the dropdown is opened:
      // 1. The initialValue is still displayed on the form background as a DropdownMenuItem.
      // 2. The opened menu overlay displays all 6 total MetricType options.
      // Total = 1 (background label) + 6 (popup menu options) = 7 widgets.
      expect(
        find.byType(DropdownMenuItem<MetricType>),
        findsNWidgets(MetricType.values.length + 1),
      );
    });

    testWidgets('editing existing category pre-fills name and unit', (tester) async {
      final existing = getMeasurementCategories()[1];

      await tester.pumpWidget(_wrap(MeasurementCategoryForm(existing), mockRepo));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextFormField, 'Biceps'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'cm'), findsOneWidget);
    });
  });
}
