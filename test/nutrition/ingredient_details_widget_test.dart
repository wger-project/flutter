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
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/models/nutrition/ingredient_image.dart';
import 'package:wger/widgets/nutrition/ingredient_dialogs.dart';

void main() {
  Ingredient makeIngredient({
    String name = 'Apple',
    String? sourceName = 'Open Food Facts',
    IngredientImage? image,
  }) {
    return Ingredient(
      id: 1,
      remoteId: '1',
      sourceName: sourceName,
      sourceUrl: 'http://test.com',
      code: null,
      name: name,
      created: DateTime.utc(2026),
      energy: 100,
      carbohydrates: 10,
      protein: 5,
      fat: 2,
      image: image,
    );
  }

  Widget host(Widget child) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );
  }

  testWidgets('renders the macronutrients header, dietary section and source', (tester) async {
    await tester.pumpWidget(host(IngredientDetails(makeIngredient())));

    // "Macronutrients" appears as the section header and as a column
    // header inside MacronutrientsTable, both occurrences are fine.
    expect(find.text('Macronutrients'), findsAtLeast(1));
    // DietaryInfoSection is rendered (its widget identity is stable).
    expect(find.byType(DietaryInfoSection), findsOneWidget);
    // Source line picks up the ingredient's sourceName.
    expect(find.textContaining('Open Food Facts'), findsOneWidget);
  });

  testWidgets('omits the image header when the ingredient has no image', (tester) async {
    await tester.pumpWidget(host(IngredientDetails(makeIngredient())));

    expect(find.byType(IngredientImageHeader), findsNothing);
  });

  testWidgets('falls back to "unknown" when sourceName is null', (tester) async {
    await tester.pumpWidget(host(IngredientDetails(makeIngredient(sourceName: null))));

    expect(find.textContaining('unknown'), findsOneWidget);
  });
}
