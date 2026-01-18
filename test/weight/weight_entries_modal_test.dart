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
import 'package:wger/models/user/profile.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/providers/user.dart';
import 'package:wger/widgets/weight/entries_modal.dart';

import 'weight_entries_modal_test.mocks.dart';

@GenerateMocks([BodyWeightProvider, UserProvider])
void main() {
  late MockBodyWeightProvider mockWeightProvider;
  late MockUserProvider mockUserProvider;
  late List<WeightEntry> testEntries;

  setUp(() {
    mockWeightProvider = MockBodyWeightProvider();
    mockUserProvider = MockUserProvider();

    testEntries = [
      WeightEntry(
        id: 1,
        date: DateTime(2021, 9, 1, 10, 30),
        weight: 80.5,
      ),
      WeightEntry(
        id: 2,
        date: DateTime(2021, 9, 5, 14, 0),
        weight: 80.0,
      ),
      WeightEntry(
        id: 3,
        date: DateTime(2021, 9, 10, 8, 15),
        weight: 79.5,
      ),
    ];

    when(mockWeightProvider.items).thenReturn(testEntries);
    when(mockUserProvider.profile).thenReturn(
      Profile(
        username: 'test',
        email: 'test@example.com',
        emailVerified: true,
        isTrustworthy: false,
        weightUnitStr: 'kg',
      ),
    );
  });

  Widget createEntriesModalTestWidget({String locale = 'en'}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<BodyWeightProvider>.value(value: mockWeightProvider),
        ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
      ],
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showWeightEntriesModal(context),
              child: const Text('Open Modal'),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('Shows entries modal with weight entries', (WidgetTester tester) async {
    await tester.pumpWidget(createEntriesModalTestWidget());
    await tester.pumpAndSettle();

    // Tap button to open modal
    await tester.tap(find.text('Open Modal'));
    await tester.pumpAndSettle();

    // Verify modal shows weight title
    expect(find.text('Weight'), findsOneWidget);

    // Verify entry count is displayed
    expect(find.text('3 entries'), findsOneWidget);
  });

  testWidgets('Shows weight values with unit', (WidgetTester tester) async {
    await tester.pumpWidget(createEntriesModalTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Modal'));
    await tester.pumpAndSettle();

    // Verify weight values are displayed (formatted numbers may vary by locale)
    expect(find.text('80.5'), findsOneWidget);
    expect(find.text('80'), findsOneWidget);
    expect(find.text('79.5'), findsOneWidget);

    // Verify unit is displayed for each entry (kg for metric)
    expect(find.text('kg'), findsNWidgets(3));
  });

  testWidgets('Shows edit and delete buttons for each entry', (WidgetTester tester) async {
    await tester.pumpWidget(createEntriesModalTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Modal'));
    await tester.pumpAndSettle();

    // Each entry should have edit and delete icons
    expect(find.byIcon(Icons.edit_outlined), findsNWidgets(3));
    expect(find.byIcon(Icons.delete_outline), findsNWidgets(3));
  });

  testWidgets('Shows empty state when no entries', (WidgetTester tester) async {
    when(mockWeightProvider.items).thenReturn([]);

    await tester.pumpWidget(createEntriesModalTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Modal'));
    await tester.pumpAndSettle();

    // Should show "0 entries"
    expect(find.text('0 entries'), findsOneWidget);

    // Should show empty state message
    expect(find.text('You have no weight entries'), findsOneWidget);

    // Should show empty state icon
    expect(find.byIcon(Icons.monitor_weight_outlined), findsOneWidget);
  });

  testWidgets('Delete entry shows confirmation dialog', (WidgetTester tester) async {
    await tester.pumpWidget(createEntriesModalTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Modal'));
    await tester.pumpAndSettle();

    // Tap the first delete button
    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();

    // Verify confirmation dialog appears
    expect(find.text('Delete'), findsNWidgets(2)); // Dialog title and button
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('Delete entry calls provider method on confirmation', (WidgetTester tester) async {
    when(mockWeightProvider.deleteEntry(any)).thenAnswer((_) async {});

    await tester.pumpWidget(createEntriesModalTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Modal'));
    await tester.pumpAndSettle();

    // Tap delete on first entry
    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();

    // Confirm deletion
    final confirmDeleteButton = find.widgetWithText(TextButton, 'Delete');
    await tester.tap(confirmDeleteButton.last);
    await tester.pumpAndSettle();

    // Verify provider method was called
    verify(mockWeightProvider.deleteEntry(1)).called(1);
  });

  testWidgets('Shows error snackbar when delete fails', (WidgetTester tester) async {
    when(mockWeightProvider.deleteEntry(any)).thenThrow(Exception('Network error'));

    await tester.pumpWidget(createEntriesModalTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Modal'));
    await tester.pumpAndSettle();

    // Tap delete on first entry
    await tester.tap(find.byIcon(Icons.delete_outline).first);
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
    expect(find.text('Weight'), findsOneWidget);

    // Drag down to dismiss
    await tester.drag(find.text('Weight'), const Offset(0, 500));
    await tester.pumpAndSettle();

    // Modal should be closed
    expect(find.text('3 entries'), findsNothing);
  });
}
