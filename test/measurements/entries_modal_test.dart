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
import 'package:wger/widgets/measurements/entries_modal.dart';

import 'entries_modal_test.mocks.dart';

@GenerateMocks([MeasurementProvider])
void main() {
  late MockMeasurementProvider mockProvider;
  late MeasurementCategory testCategory;

  setUp(() {
    mockProvider = MockMeasurementProvider();
    testCategory = MeasurementCategory(
      id: 1,
      name: 'Body Fat',
      unit: '%',
      entries: [
        MeasurementEntry(
          id: 1,
          category: 1,
          date: DateTime(2021, 9, 1),
          value: 15.5,
          notes: 'Morning measurement',
        ),
        MeasurementEntry(
          id: 2,
          category: 1,
          date: DateTime(2021, 9, 5),
          value: 15.2,
          notes: '',
        ),
        MeasurementEntry(
          id: 3,
          category: 1,
          date: DateTime(2021, 9, 10),
          value: 14.8,
          notes: 'After workout',
        ),
      ],
    );

    when(mockProvider.findCategoryById(1)).thenReturn(testCategory);
  });

  Widget createEntriesModalTestWidget({String locale = 'en'}) {
    return ChangeNotifierProvider<MeasurementProvider>.value(
      value: mockProvider,
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showEntriesModal(context, testCategory),
              child: const Text('Open Modal'),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('Shows entries modal with category name and entry count', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createEntriesModalTestWidget());
    await tester.pumpAndSettle();

    // Tap button to open modal
    await tester.tap(find.text('Open Modal'));
    await tester.pumpAndSettle();

    // Verify modal shows category name
    expect(find.text('Body Fat'), findsOneWidget);

    // Verify entry count is displayed
    expect(find.text('3 entries'), findsOneWidget);
  });

  testWidgets('Shows all entries with formatted values', (WidgetTester tester) async {
    await tester.pumpWidget(createEntriesModalTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Modal'));
    await tester.pumpAndSettle();

    // Verify values are displayed (formatted numbers may vary by locale)
    expect(find.text('15.5'), findsOneWidget);
    expect(find.text('15.2'), findsOneWidget);
    expect(find.text('14.8'), findsOneWidget);

    // Verify unit is displayed for each entry
    expect(find.text('%'), findsNWidgets(3));
  });

  testWidgets('Shows edit and delete buttons for each entry', (WidgetTester tester) async {
    await tester.pumpWidget(createEntriesModalTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Modal'));
    await tester.pumpAndSettle();

    // Each entry should have edit and delete icons
    expect(find.byIcon(Icons.edit_outlined), findsNWidgets(4)); // 3 entries + 1 category edit
    expect(find.byIcon(Icons.delete_outline), findsNWidgets(4)); // 3 entries + 1 category delete
  });

  testWidgets('Shows empty state when no entries', (WidgetTester tester) async {
    final emptyCategory = MeasurementCategory(
      id: 2,
      name: 'Empty Category',
      unit: 'cm',
      entries: [],
    );

    when(mockProvider.findCategoryById(2)).thenReturn(emptyCategory);

    final widget = ChangeNotifierProvider<MeasurementProvider>.value(
      value: mockProvider,
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showEntriesModal(context, emptyCategory),
              child: const Text('Open Modal'),
            ),
          ),
        ),
      ),
    );

    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Modal'));
    await tester.pumpAndSettle();

    // Should show "0 entries"
    expect(find.text('0 entries'), findsOneWidget);

    // Should show empty state icon
    expect(find.byIcon(Icons.straighten_outlined), findsOneWidget);
  });

  testWidgets('Delete entry shows confirmation dialog', (WidgetTester tester) async {
    await tester.pumpWidget(createEntriesModalTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Modal'));
    await tester.pumpAndSettle();

    // Tap the first delete button (skip the category delete button at index 0)
    final deleteButtons = find.byIcon(Icons.delete_outline);
    await tester.tap(deleteButtons.at(2)); // Entry delete button
    await tester.pumpAndSettle();

    // Verify confirmation dialog appears
    expect(find.text('Delete'), findsNWidgets(2)); // Dialog title and button
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('Delete entry calls provider method on confirmation', (WidgetTester tester) async {
    when(mockProvider.deleteEntry(any, any)).thenAnswer((_) async {});

    await tester.pumpWidget(createEntriesModalTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Modal'));
    await tester.pumpAndSettle();

    // Tap delete on an entry
    final deleteButtons = find.byIcon(Icons.delete_outline);
    await tester.tap(deleteButtons.at(2));
    await tester.pumpAndSettle();

    // Confirm deletion
    final confirmDeleteButton = find.widgetWithText(TextButton, 'Delete');
    await tester.tap(confirmDeleteButton.last);
    await tester.pumpAndSettle();

    // Verify provider method was called
    verify(mockProvider.deleteEntry(any, any)).called(1);
  });

  testWidgets('Delete category shows confirmation dialog', (WidgetTester tester) async {
    await tester.pumpWidget(createEntriesModalTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Modal'));
    await tester.pumpAndSettle();

    // Tap the category delete button (first delete button in header)
    final deleteButtons = find.byIcon(Icons.delete_outline);
    await tester.tap(deleteButtons.first);
    await tester.pumpAndSettle();

    // Verify confirmation dialog shows category name
    expect(find.textContaining('Body Fat'), findsWidgets);
  });

  testWidgets('Delete category calls provider method on confirmation', (WidgetTester tester) async {
    when(mockProvider.deleteCategory(any)).thenAnswer((_) async {});

    await tester.pumpWidget(createEntriesModalTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Modal'));
    await tester.pumpAndSettle();

    // Tap category delete button
    final deleteButtons = find.byIcon(Icons.delete_outline);
    await tester.tap(deleteButtons.first);
    await tester.pumpAndSettle();

    // Confirm deletion
    final confirmDeleteButton = find.widgetWithText(TextButton, 'Delete');
    await tester.tap(confirmDeleteButton.last);
    await tester.pumpAndSettle();

    // Verify provider method was called
    verify(mockProvider.deleteCategory(1)).called(1);
  });

  testWidgets('Shows error snackbar when delete entry fails', (WidgetTester tester) async {
    when(mockProvider.deleteEntry(any, any)).thenThrow(Exception('Network error'));

    await tester.pumpWidget(createEntriesModalTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Modal'));
    await tester.pumpAndSettle();

    // Tap delete on an entry
    final deleteButtons = find.byIcon(Icons.delete_outline);
    await tester.tap(deleteButtons.at(2));
    await tester.pumpAndSettle();

    // Confirm deletion
    final confirmDeleteButton = find.widgetWithText(TextButton, 'Delete');
    await tester.tap(confirmDeleteButton.last);
    await tester.pumpAndSettle();

    // Verify error snackbar appears
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('Shows error snackbar when delete category fails', (WidgetTester tester) async {
    when(mockProvider.deleteCategory(any)).thenThrow(Exception('Network error'));

    await tester.pumpWidget(createEntriesModalTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Modal'));
    await tester.pumpAndSettle();

    // Tap category delete button
    final deleteButtons = find.byIcon(Icons.delete_outline);
    await tester.tap(deleteButtons.first);
    await tester.pumpAndSettle();

    // Confirm deletion
    final confirmDeleteButton = find.widgetWithText(TextButton, 'Delete');
    await tester.tap(confirmDeleteButton.last);
    await tester.pumpAndSettle();

    // Verify error snackbar appears
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('Modal can be dismissed by dragging down', (WidgetTester tester) async {
    await tester.pumpWidget(createEntriesModalTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Modal'));
    await tester.pumpAndSettle();

    // Verify modal is open
    expect(find.text('Body Fat'), findsOneWidget);

    // Drag down to dismiss
    await tester.drag(find.text('Body Fat'), const Offset(0, 500));
    await tester.pumpAndSettle();

    // Modal should be closed
    expect(find.text('Body Fat'), findsNothing);
  });
}
