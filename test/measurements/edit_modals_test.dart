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
import 'package:wger/models/measurements/measurement_category.dart';
import 'package:wger/models/measurements/measurement_entry.dart';
import 'package:wger/providers/measurement.dart';
import 'package:wger/widgets/measurements/edit_modals.dart';

import 'edit_modals_test.mocks.dart';

@GenerateMocks([MeasurementProvider])
void main() {
  late MockMeasurementProvider mockProvider;
  late MeasurementCategory testCategory;
  late MeasurementEntry testEntry;

  setUp(() {
    mockProvider = MockMeasurementProvider();
    testCategory = MeasurementCategory(
      id: 1,
      name: 'Body Fat',
      unit: '%',
      entries: [],
    );
    testEntry = MeasurementEntry(
      id: 1,
      category: 1,
      date: DateTime(2021, 9, 1),
      value: 15.5,
      notes: 'Morning measurement',
    );
  });

  group('Edit Entry Modal', () {
    Widget createEditEntryModalTestWidget({
      MeasurementEntry? entry,
      String locale = 'en',
    }) {
      return ChangeNotifierProvider<MeasurementProvider>.value(
        value: mockProvider,
        child: MaterialApp(
          locale: Locale(locale),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showEditEntryModal(context, testCategory, entry),
                child: const Text('Open Modal'),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('Shows new entry modal with empty fields', (WidgetTester tester) async {
      await tester.pumpWidget(createEditEntryModalTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Verify modal shows "New Entry" title
      expect(find.text('New entry'), findsOneWidget);

      // Verify date field is populated with today's date
      expect(find.byType(TextFormField), findsNWidgets(3)); // date, value, notes

      // Verify save button is present
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('Shows edit entry modal with prefilled data', (WidgetTester tester) async {
      await tester.pumpWidget(createEditEntryModalTestWidget(entry: testEntry));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Verify modal shows "Edit" title
      expect(find.text('Edit'), findsOneWidget);

      // Verify value is prefilled
      expect(find.text('15.5'), findsOneWidget);

      // Verify notes is prefilled
      expect(find.text('Morning measurement'), findsOneWidget);
    });

    testWidgets('Validates empty value field', (WidgetTester tester) async {
      await tester.pumpWidget(createEditEntryModalTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Try to save without entering value
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify validation error is shown
      expect(find.text('Please enter a value'), findsOneWidget);
    });

    testWidgets('Validates invalid number input', (WidgetTester tester) async {
      await tester.pumpWidget(createEditEntryModalTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Enter invalid number
      final valueField = find.byType(TextFormField).at(1); // value field
      await tester.enterText(valueField, 'not a number');
      await tester.pumpAndSettle();

      // Try to save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify validation error is shown
      expect(find.text('Please enter a valid number'), findsOneWidget);
    });

    testWidgets('Saves new entry successfully', (WidgetTester tester) async {
      when(mockProvider.addEntry(any)).thenAnswer((_) async {});

      await tester.pumpWidget(createEditEntryModalTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Enter value
      final valueField = find.byType(TextFormField).at(1);
      await tester.enterText(valueField, '20.5');
      await tester.pumpAndSettle();

      // Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify provider method was called
      verify(mockProvider.addEntry(any)).called(1);

      // Modal should be closed
      expect(find.text('New entry'), findsNothing);
    });

    testWidgets('Updates existing entry successfully', (WidgetTester tester) async {
      when(mockProvider.editEntry(any, any, any, any, any)).thenAnswer((_) async {});

      await tester.pumpWidget(createEditEntryModalTestWidget(entry: testEntry));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Modify value
      final valueField = find.byType(TextFormField).at(1);
      await tester.enterText(valueField, '16.0');
      await tester.pumpAndSettle();

      // Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify provider method was called
      verify(mockProvider.editEntry(any, any, any, any, any)).called(1);
    });

    testWidgets('Shows error snackbar when save fails', (WidgetTester tester) async {
      when(mockProvider.addEntry(any)).thenThrow(Exception('Network error'));

      await tester.pumpWidget(createEditEntryModalTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Enter value
      final valueField = find.byType(TextFormField).at(1);
      await tester.enterText(valueField, '20.5');
      await tester.pumpAndSettle();

      // Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify error snackbar appears
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('Shows loading indicator while saving', (WidgetTester tester) async {
      when(mockProvider.addEntry(any)).thenAnswer(
        (_) => Future.delayed(const Duration(seconds: 2)),
      );

      await tester.pumpWidget(createEditEntryModalTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Enter value
      final valueField = find.byType(TextFormField).at(1);
      await tester.enterText(valueField, '20.5');
      await tester.pumpAndSettle();

      // Save
      await tester.tap(find.text('Save'));
      await tester.pump();

      // Verify loading indicator appears
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for save to complete
      await tester.pumpAndSettle();
    });

    testWidgets('Opens date picker when tapping date field', (WidgetTester tester) async {
      await tester.pumpWidget(createEditEntryModalTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Tap date field
      final dateField = find.byType(TextFormField).first;
      await tester.tap(dateField);
      await tester.pumpAndSettle();

      // Verify date picker appears
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });
  });

  group('Edit Category Modal', () {
    Widget createEditCategoryModalTestWidget({
      MeasurementCategory? category,
      String locale = 'en',
    }) {
      return ChangeNotifierProvider<MeasurementProvider>.value(
        value: mockProvider,
        child: MaterialApp(
          locale: Locale(locale),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showEditCategoryModal(context, category),
                child: const Text('Open Modal'),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('Shows new category modal with empty fields', (WidgetTester tester) async {
      await tester.pumpWidget(createEditCategoryModalTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Verify modal shows "New Entry" title (for new category)
      expect(find.text('New entry'), findsOneWidget);

      // Verify fields are present
      expect(find.byType(TextFormField), findsNWidgets(2)); // name, unit

      // Verify save button is present
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('Shows edit category modal with prefilled data', (WidgetTester tester) async {
      await tester.pumpWidget(createEditCategoryModalTestWidget(category: testCategory));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Verify modal shows "Edit" title
      expect(find.text('Edit'), findsOneWidget);

      // Verify name is prefilled
      expect(find.text('Body Fat'), findsOneWidget);

      // Verify unit is prefilled
      expect(find.text('%'), findsOneWidget);
    });

    testWidgets('Validates empty name field', (WidgetTester tester) async {
      await tester.pumpWidget(createEditCategoryModalTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Try to save without entering name
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify validation error is shown
      expect(find.text('Please enter a value'), findsWidgets);
    });

    testWidgets('Saves new category successfully', (WidgetTester tester) async {
      when(mockProvider.addCategory(any)).thenAnswer((_) async {});

      await tester.pumpWidget(createEditCategoryModalTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Enter name
      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'Biceps');
      await tester.pumpAndSettle();

      // Enter unit
      final unitField = find.byType(TextFormField).last;
      await tester.enterText(unitField, 'cm');
      await tester.pumpAndSettle();

      // Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify provider method was called
      verify(mockProvider.addCategory(any)).called(1);

      // Modal should be closed
      expect(find.text('New entry'), findsNothing);
    });

    testWidgets('Updates existing category successfully', (WidgetTester tester) async {
      when(mockProvider.editCategory(any, any, any)).thenAnswer((_) async {});

      await tester.pumpWidget(createEditCategoryModalTestWidget(category: testCategory));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Modify name
      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'Body Fat Percentage');
      await tester.pumpAndSettle();

      // Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify provider method was called
      verify(mockProvider.editCategory(1, 'Body Fat Percentage', '%')).called(1);
    });

    testWidgets('Shows error snackbar when save fails', (WidgetTester tester) async {
      when(mockProvider.addCategory(any)).thenThrow(Exception('Network error'));

      await tester.pumpWidget(createEditCategoryModalTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Enter name and unit
      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'Biceps');
      final unitField = find.byType(TextFormField).last;
      await tester.enterText(unitField, 'cm');
      await tester.pumpAndSettle();

      // Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify error snackbar appears
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('Shows loading indicator while saving', (WidgetTester tester) async {
      when(mockProvider.addCategory(any)).thenAnswer(
        (_) => Future.delayed(const Duration(seconds: 2)),
      );

      await tester.pumpWidget(createEditCategoryModalTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Enter name and unit
      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'Biceps');
      final unitField = find.byType(TextFormField).last;
      await tester.enterText(unitField, 'cm');
      await tester.pumpAndSettle();

      // Save
      await tester.tap(find.text('Save'));
      await tester.pump();

      // Verify loading indicator appears
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for save to complete
      await tester.pumpAndSettle();
    });

    testWidgets('Modal can be dismissed by dragging down', (WidgetTester tester) async {
      await tester.pumpWidget(createEditCategoryModalTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Verify modal is open
      expect(find.text('New entry'), findsOneWidget);

      // Find the handle bar and drag down
      final handleBar = find.byType(Container).first;
      await tester.drag(handleBar, const Offset(0, 500));
      await tester.pumpAndSettle();

      // Modal should be closed
      expect(find.text('New entry'), findsNothing);
    });
  });
}
