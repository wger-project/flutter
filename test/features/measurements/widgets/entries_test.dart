/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 wger Team
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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';
import 'package:wger/features/measurements/providers/measurement_repository.dart';
import 'package:wger/features/measurements/widgets/entries.dart';
import 'package:wger/features/nutrition/providers/ingredient_repository.dart';
import 'package:wger/features/nutrition/providers/nutrition_repository.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

import 'entries_test.mocks.dart';

@GenerateMocks([MeasurementRepository, NutritionRepository, IngredientRepository])
void main() {
  final userEntry = MeasurementEntry(
    id: 'e-user',
    categoryId: 'c1',
    date: DateTime(2026, 1, 2),
    value: 20,
    notes: '',
  );
  final importedEntry = MeasurementEntry(
    id: 'e-import',
    categoryId: 'c1',
    date: DateTime(2026, 1, 1),
    value: 21,
    notes: '',
    source: 'apple',
    externalId: 'bf-1',
  );

  Widget createEntriesList(MeasurementCategory category) {
    final mockRepo = MockMeasurementRepository();
    when(mockRepo.watchAll()).thenAnswer((_) => Stream.value([category]));

    return ProviderScope(
      overrides: [
        measurementRepositoryProvider.overrideWithValue(mockRepo),
        nutritionRepositoryProvider.overrideWithValue(MockNutritionRepository()),
        ingredientRepositoryProvider.overrideWithValue(MockIngredientRepository()),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: EntriesList(
              MeasurementCategory(
                id: category.id,
                name: category.name,
                unit: category.unit,
                entries: category.entries,
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('Imported entries show a badge instead of the edit menu', (
    WidgetTester tester,
  ) async {
    final category = MeasurementCategory(
      id: 'c1',
      name: 'Body fat',
      unit: '%',
      entries: [userEntry, importedEntry],
    );

    await tester.pumpWidget(createEntriesList(category));
    await tester.pumpAndSettle();

    // Only the manual entry has the menu, the imported one carries the badge
    expect(find.byTooltip('Show menu'), findsOneWidget);
    expect(find.byIcon(Icons.monitor_heart_outlined), findsOneWidget);
  });
}
