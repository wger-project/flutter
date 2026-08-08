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
import 'package:mockito/annotations.dart';
import 'package:wger/core/form_screen.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';
import 'package:wger/features/measurements/providers/measurement_repository.dart';
import 'package:wger/features/measurements/widgets/measurement_fab.dart';
import 'package:wger/features/measurements/widgets/metric_picker.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

import '../../../helpers/measurement_repository_stubs.dart';
import 'measurement_fab_test.mocks.dart';

MeasurementEntry _entry(String categoryId, {required String source}) => MeasurementEntry(
  id: '$categoryId-1',
  categoryId: categoryId,
  date: DateTime(2026, 8, 1),
  value: 1,
  notes: '',
  source: source,
);

Widget _wrap(
  List<MeasurementCategory> categories,
  Map<String, List<MeasurementEntry>> entries,
) {
  final mockRepo = MockMeasurementRepository();
  stubMeasurementReads(mockRepo, categories, entries);

  return ProviderScope(
    overrides: [measurementRepositoryProvider.overrideWithValue(mockRepo)],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routes: {FormScreen.routeName: (_) => const Text('form-screen')},
      home: const Scaffold(floatingActionButton: MeasurementsFab()),
    ),
  );
}

@GenerateMocks([MeasurementRepository])
void main() {
  final biceps = MeasurementCategory(id: 'biceps', name: 'Biceps', unit: 'cm');
  final restingHeartRate = MeasurementCategory(
    id: 'rhr',
    name: 'Resting heart rate',
    unit: 'bpm',
    metricType: MetricType.restingHeartRate,
  );

  final categories = [biceps, restingHeartRate];
  final entries = {
    'biceps': [_entry('biceps', source: 'user')],
    'rhr': [_entry('rhr', source: 'google')],
  };

  group('MeasurementsFab', () {
    testWidgets('opens into the hand-kept categories and the picker action', (tester) async {
      await tester.pumpWidget(_wrap(categories, entries));
      await tester.pumpAndSettle();

      // Closed: the menu is not tappable
      expect(find.text('Biceps').hitTestable(), findsNothing);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Biceps').hitTestable(), findsOneWidget);
      expect(find.text('Track something new').hitTestable(), findsOneWidget);
      // Machine-fed by its newest reading, so logging by hand is not offered
      expect(find.text('Resting heart rate').hitTestable(), findsNothing);
    });

    testWidgets('a category action opens its entry form', (tester) async {
      await tester.pumpWidget(_wrap(categories, entries));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Biceps'));
      await tester.pumpAndSettle();

      expect(find.text('form-screen'), findsOneWidget);
    });

    testWidgets('the picker action opens the metric picker sheet', (tester) async {
      await tester.pumpWidget(_wrap(categories, entries));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Track something new'));
      await tester.pumpAndSettle();

      expect(find.byType(MetricPickerSheet), findsOneWidget);
    });

    testWidgets('a category without entries counts as hand-kept', (tester) async {
      await tester.pumpWidget(_wrap([restingHeartRate], const {}));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Resting heart rate').hitTestable(), findsOneWidget);
    });
  });
}
