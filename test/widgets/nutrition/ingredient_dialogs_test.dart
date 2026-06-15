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
import 'package:wger/widgets/nutrition/ingredient_dialogs.dart';

import '../../../test_data/nutritional_plans.dart';

Future<void> pumpIngredientDetailsDialog(
  WidgetTester tester, {
  required Ingredient ingredient,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => IngredientDetailsDialog(ingredient),
              );
            },
            child: const Text('Show Dialog'),
          ),
        ),
      ),
    ),
  );
}

Future<void> pumpIngredientScanDialog(
  WidgetTester tester, {
  required AsyncSnapshot<Ingredient?> snapshot,
  required String barcode,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => IngredientScanResultDialog(
                  snapshot,
                  barcode,
                  (Ingredient ingredient, num? amount) {}, // Mock callback
                ),
              );
            },
            child: const Text('Show Dialog'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('IngredientDetails tests', () {
    testWidgets('shows brand below name in title when ingredient has a brand', (
      WidgetTester tester,
    ) async {
      // ingredient3 (Broccoli cake, brand: 'Weightwatchers')
      await pumpIngredientDetailsDialog(tester, ingredient: ingredient3);
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Broccoli cake'), findsOneWidget);
      expect(find.text('Weightwatchers'), findsOneWidget);
    });

    testWidgets('does not show brand in title when ingredient has no brand', (
      WidgetTester tester,
    ) async {
      // ingredient1 (Water, brand: null)
      await pumpIngredientDetailsDialog(tester, ingredient: ingredient1);
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Water'), findsOneWidget);
      // brand: null must not render as the literal string "null"
      expect(find.text('null'), findsNothing);
    });
  });

  group('IngredientScanResultDialog tests', () {
    const testBarcode = '1234567890123';

    testWidgets(
      'shows Open Food Facts button when product not found',
      (WidgetTester tester) async {
        // Arrange
        const snapshot = AsyncSnapshot<Ingredient?>.withData(
          ConnectionState.done,
          null, // null = product not found
        );

        // Act
        await pumpIngredientScanDialog(
          tester,
          snapshot: snapshot,
          barcode: testBarcode,
        );

        // Open dialog
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(AlertDialog), findsOneWidget);

        // Verify the Open Food Facts button exists
        expect(
          find.byKey(const Key('ingredient-scan-result-dialog-open-food-facts-button')),
          findsOneWidget,
        );

        // Verify the close button exists
        expect(
          find.byKey(const Key('ingredient-scan-result-dialog-close-button')),
          findsOneWidget,
        );

        // Verify the continue button does not exist
        expect(
          find.byKey(const Key('ingredient-scan-result-dialog-confirm-button')),
          findsNothing,
        );
      },
    );

    testWidgets(
      'tapping Open Food Facts button closes the dialog',
      (WidgetTester tester) async {
        // Arrange
        const snapshot = AsyncSnapshot<Ingredient?>.withData(
          ConnectionState.done,
          null,
        );

        await pumpIngredientScanDialog(
          tester,
          snapshot: snapshot,
          barcode: testBarcode,
        );

        // Open dialog
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Verify dialog is open
        expect(find.byType(AlertDialog), findsOneWidget);

        // Act: Tap the Open Food Facts button
        await tester.tap(
          find.byKey(const Key('ingredient-scan-result-dialog-open-food-facts-button')),
        );
        await tester.pumpAndSettle();

        // Assert: Dialog should be closed
        expect(find.byType(AlertDialog), findsNothing);
      },
    );
  });
}
