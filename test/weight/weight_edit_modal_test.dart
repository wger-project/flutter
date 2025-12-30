/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
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
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/body_weight/weight_entry.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/widgets/weight/edit_modal.dart';

import 'weight_edit_modal_test.mocks.dart';

@GenerateMocks([BodyWeightProvider])
void main() {
  late MockBodyWeightProvider mockProvider;

  setUp(() {
    mockProvider = MockBodyWeightProvider();
  });

  Widget createEditWeightModalTestWidget({
    WeightEntry? entry,
    String locale = 'en',
  }) {
    return ChangeNotifierProvider<BodyWeightProvider>.value(
      value: mockProvider,
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showEditWeightModal(context, entry),
              child: const Text('Open Modal'),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('Shows new entry modal with empty fields', (WidgetTester tester) async {
    await tester.pumpWidget(createEditWeightModalTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Modal'));
    await tester.pumpAndSettle();

    // Verify modal shows "New Entry" title
    expect(find.text('New entry'), findsOneWidget);

    // Verify save button is present
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('Shows edit modal with prefilled data', (WidgetTester tester) async {
    final testEntry = WeightEntry(
      id: 1,
      date: DateTime(2021, 1, 1, 15, 30),
      weight: 80.0,
    );

    await tester.pumpWidget(createEditWeightModalTestWidget(entry: testEntry));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Modal'));
    await tester.pumpAndSettle();

    // Verify modal shows "Edit" title
    expect(find.text('Edit'), findsOneWidget);

    // Verify weight is prefilled
    expect(find.text('80'), findsOneWidget);
  });

  testWidgets('Validates empty weight field', (WidgetTester tester) async {
    await tester.pumpWidget(createEditWeightModalTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Modal'));
    await tester.pumpAndSettle();

    // Try to save without entering weight
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Verify validation error is shown
    expect(find.text('Please enter a value'), findsOneWidget);
  });

  testWidgets('Saves new entry successfully', (WidgetTester tester) async {
    when(mockProvider.addEntry(any)).thenAnswer(
      (_) async => WeightEntry(
        id: 1,
        date: DateTime.now(),
        weight: 2.0,
      ),
    );

    await tester.pumpWidget(createEditWeightModalTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Modal'));
    await tester.pumpAndSettle();

    // Enter weight value using the +1 button multiple times
    await tester.tap(find.text('+1'));
    await tester.pump();
    await tester.tap(find.text('+1'));
    await tester.pump();
    await tester.pumpAndSettle();

    // Save
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Verify provider method was called
    verify(mockProvider.addEntry(any)).called(1);
  });

  testWidgets('Updates existing entry successfully', (WidgetTester tester) async {
    when(mockProvider.editEntry(any)).thenAnswer((_) async {});

    final testEntry = WeightEntry(
      id: 1,
      date: DateTime(2021, 1, 1, 15, 30),
      weight: 80.0,
    );

    await tester.pumpWidget(createEditWeightModalTestWidget(entry: testEntry));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Modal'));
    await tester.pumpAndSettle();

    // Modify weight using +1 button
    await tester.tap(find.text('+1'));
    await tester.pumpAndSettle();

    // Save
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Verify provider method was called
    verify(mockProvider.editEntry(any)).called(1);
  });

  testWidgets('Shows error snackbar when save fails', (WidgetTester tester) async {
    when(mockProvider.addEntry(any)).thenThrow(Exception('Network error'));

    await tester.pumpWidget(createEditWeightModalTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Modal'));
    await tester.pumpAndSettle();

    // Enter weight
    await tester.tap(find.text('+1'));
    await tester.pumpAndSettle();

    // Save
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Verify error snackbar appears
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('Weight quick-change buttons work correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createEditWeightModalTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Modal'));
    await tester.pumpAndSettle();

    // Test +1 button
    await tester.tap(find.text('+1'));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);

    // Test +.1 button
    await tester.tap(find.text('+.1'));
    await tester.pump();
    expect(find.text('1.1'), findsOneWidget);

    // Test -1 button (should go to 0.1)
    await tester.tap(find.text('-1'));
    await tester.pump();
    expect(find.text('0.1'), findsOneWidget);

    // Test -.1 button (should go to 0)
    await tester.tap(find.text('-.1'));
    await tester.pump();
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('Shows loading indicator while saving', (WidgetTester tester) async {
    when(mockProvider.addEntry(any)).thenAnswer(
      (_) => Future.delayed(
        const Duration(seconds: 2),
        () => WeightEntry(id: 1, date: DateTime.now(), weight: 1.0),
      ),
    );

    await tester.pumpWidget(createEditWeightModalTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Modal'));
    await tester.pumpAndSettle();

    // Enter weight
    await tester.tap(find.text('+1'));
    await tester.pumpAndSettle();

    // Save
    await tester.tap(find.text('Save'));
    await tester.pump();

    // Verify loading indicator appears
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for save to complete
    await tester.pumpAndSettle();
  });
}
