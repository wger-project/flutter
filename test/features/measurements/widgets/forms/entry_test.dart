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

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/core/widgets/decimal_input.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';
import 'package:wger/features/measurements/providers/measurement_repository.dart';
import 'package:wger/features/measurements/widgets/forms/entry.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

import '../../../../../test_data/measurements.dart';
import '../../../../helpers/measurement_repository_stubs.dart';
import 'entry_test.mocks.dart';

@GenerateMocks([MeasurementRepository])
void main() {
  late MockMeasurementRepository mockRepo;

  setUp(() {
    mockRepo = MockMeasurementRepository();
    stubMeasurementReads(mockRepo, []);
    when(mockRepo.addLocalDriftGroupEntries(any)).thenAnswer((_) async {});
  });

  Widget wrap(Widget child) {
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

  group('MeasurementEntryForm', () {
    testWidgets('editing keeps source and externalId of imported entries', (tester) async {
      final category = getMeasurementCategories()[0];
      stubMeasurementReads(mockRepo, [category]);
      when(mockRepo.updateLocalDrift(any)).thenAnswer((_) async {});

      final imported = MeasurementEntry(
        id: 'e-import',
        categoryId: category.id!,
        date: DateTime(2026, 1, 1),
        value: 30,
        notes: '',
        source: 'apple',
        externalId: 'platform-uuid',
        extraData: const {'unit': 'kg'},
      );

      await tester.pumpWidget(wrap(MeasurementEntryForm(category.id!, imported)));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      final saved =
          verify(mockRepo.updateLocalDrift(captureAny)).captured.single as MeasurementEntry;
      expect(saved.source, 'apple');
      expect(saved.externalId, 'platform-uuid');
      expect(saved.extraData, {'unit': 'kg'});
      expect(saved.value, 30);
    });

    testWidgets('a value outside the limits of the metric type is refused', (tester) async {
      final category = MeasurementCategory(
        id: 'hr',
        name: 'Heart rate',
        unit: 'bpm',
        metricType: MetricType.heartRate,
      );
      stubMeasurementReads(mockRepo, [category]);
      when(mockRepo.addLocalDrift(any)).thenAnswer((_) async {});

      await tester.pumpWidget(wrap(MeasurementEntryForm(category.id!)));
      await tester.pumpAndSettle();

      // 500 bpm are over the bound the server enforces as well
      await tester.enterText(
        find.descendant(
          of: find.byType(DecimalInputWidget),
          matching: find.byType(TextFormField),
        ),
        '500',
      );
      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      verifyNever(mockRepo.addLocalDrift(any));
      expect(find.text('Please enter a value between 30 and 250'), findsOneWidget);
    });

    testWidgets('editing pre-fills the notes and saves them changed', (tester) async {
      final category = getMeasurementCategories()[0];
      stubMeasurementReads(mockRepo, [category]);
      when(mockRepo.updateLocalDrift(any)).thenAnswer((_) async {});

      final entry = MeasurementEntry(
        id: 'e-1',
        categoryId: category.id!,
        date: DateTime(2026, 1, 1),
        value: 30,
        notes: 'Old notes',
      );

      await tester.pumpWidget(wrap(MeasurementEntryForm(category.id!, entry)));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextFormField, 'Old notes'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextFormField, 'Old notes'), 'New notes');
      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      final saved =
          verify(mockRepo.updateLocalDrift(captureAny)).captured.single as MeasurementEntry;
      expect(saved.notes, 'New notes');
    });
  });
}
