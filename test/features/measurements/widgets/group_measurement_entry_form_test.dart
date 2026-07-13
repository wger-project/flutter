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
import 'package:wger/core/widgets/decimal_input.dart';
import 'package:wger/features/measurements/providers/measurement_repository.dart';
import 'package:wger/features/measurements/widgets/forms.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

import '../../../../test_data/measurements.dart';
import '../providers/measurement_notifier_test.mocks.dart';

Widget _wrap(MockMeasurementRepository mockRepo) {
  return ProviderScope(
    overrides: [
      measurementRepositoryProvider.overrideWithValue(mockRepo),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          child: GroupMeasurementEntryForm(testMeasurementCategoryBloodPressure),
        ),
      ),
    ),
  );
}

void main() {
  late MockMeasurementRepository mockRepo;

  setUp(() {
    mockRepo = MockMeasurementRepository();
    when(mockRepo.watchAll()).thenAnswer((_) => Stream.value([]));
    when(mockRepo.addLocalDriftGroupEntries(any)).thenAnswer((_) async {});
  });

  group('GroupMeasurementEntryForm', () {
    testWidgets('renders one DecimalInputWidget per child component', (tester) async {
      await tester.pumpWidget(_wrap(mockRepo));
      await tester.pumpAndSettle();

      expect(find.byType(DecimalInputWidget), findsNWidgets(2));
    });

    testWidgets('empty value fields fail validation', (tester) async {
      await tester.pumpWidget(_wrap(mockRepo));
      await tester.pumpAndSettle();

      // Tap save without entering values
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Form doesnot pop
      expect(find.byType(GroupMeasurementEntryForm), findsOneWidget);
    });

    testWidgets('valid submission calls addGroupEntries with correct count', (tester) async {
      await tester.pumpWidget(_wrap(mockRepo));
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      // Fields : Date, Time, Systolic value, Diastolic value
      await tester.enterText(fields.at(2), '120');
      await tester.enterText(fields.at(3), '80');

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      verify(
        mockRepo.addLocalDriftGroupEntries(
          argThat(hasLength(2)),
        ),
      ).called(1);
    });
  });
}
