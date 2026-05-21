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
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/nutrition/meal.dart';
import 'package:wger/providers/network_provider.dart';
import 'package:wger/widgets/nutrition/meal.dart';

void main() {
  Meal buildMeal() => Meal(
    id: 'aa000000-0000-4000-8000-000000000001',
    plan: 'bb000000-0000-4000-8000-000000000001',
    name: 'Breakfast',
    time: const TimeOfDay(hour: 8, minute: 0),
  );

  Widget renderMeal({bool isOnline = true}) {
    return ProviderScope(
      // The meal widget does not gate its actions on connectivity. Pinning the
      // network status to offline makes a re-introduced connectivity gate fail
      // this test.
      overrides: [networkStatusProvider.overrideWithValue(isOnline)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: MealWidget(buildMeal(), const [], false, false),
          ),
        ),
      ),
    );
  }

  testWidgets('Add-ingredient button stays enabled when offline', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(renderMeal(isOnline: false));
    await tester.pumpAndSettle();

    // Reveal the meal action buttons by entering editing mode.
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    final addButton = tester.widget<TextButton>(
      find.ancestor(
        of: find.byIcon(Icons.add),
        matching: find.byType(TextButton),
      ),
    );
    expect(addButton.onPressed, isNotNull);
  });
}
