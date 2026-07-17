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
import 'package:mockito/mockito.dart';
import 'package:wger/features/measurements/providers/measurement_repository.dart';
import 'package:wger/features/measurements/widgets/categories.dart';
import 'package:wger/features/measurements/widgets/categories_card.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

import '../../../../test_data/measurements.dart';
import 'categories_test.mocks.dart';

Widget _wrap(MockMeasurementRepository mockRepo) {
  return ProviderScope(
    overrides: [
      measurementRepositoryProvider.overrideWithValue(mockRepo),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: CategoriesList()),
    ),
  );
}

@GenerateMocks([MeasurementRepository])
void main() {
  late MockMeasurementRepository mockRepo;

  setUp(() {
    mockRepo = MockMeasurementRepository();
  });

  group('CategoriesList', () {
    testWidgets('two top-level categories render two CategoriesCard widgets', (tester) async {
      when(mockRepo.watchAll()).thenAnswer((_) => Stream.value(getMeasurementCategories()));

      await tester.pumpWidget(_wrap(mockRepo));
      await tester.pumpAndSettle();

      expect(find.byType(CategoriesCard), findsNWidgets(2));
    });

    testWidgets('children of multi-value groups are not rendered as own list items', (
      tester,
    ) async {
      // Only 'bp' should produce a CategoriesCard; children stay inside it.
      when(mockRepo.watchAll()).thenAnswer((_) => Stream.value(getBloodPressureGroup()));

      await tester.pumpWidget(_wrap(mockRepo));
      await tester.pumpAndSettle();

      expect(find.byType(CategoriesCard), findsOneWidget);
      expect(find.text('Systolic'), findsOneWidget);
      expect(find.text('Diastolic'), findsOneWidget);
    });

    testWidgets('empty list renders no CategoriesCard', (tester) async {
      when(mockRepo.watchAll()).thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(_wrap(mockRepo));
      await tester.pumpAndSettle();

      expect(find.byType(CategoriesCard), findsNothing);
    });
  });
}
