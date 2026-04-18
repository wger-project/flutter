/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
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
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/measurements/measurement_entry.dart';
import 'package:wger/providers/measurement.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/screens/measurement_entries_screen.dart';
import 'package:wger/widgets/measurements/forms.dart';

import '../../test_data/measurements.dart';
import '../nutrition/nutritional_plan_form_test.mocks.dart';
import 'measurement_categories_screen_test.mocks.dart';

void main() {
  late MockMeasurementProvider mockMeasurementProvider;
  late MockNutritionPlansProvider mockNutritionPlansProvider;

  setUp(() {
    mockMeasurementProvider = MockMeasurementProvider();
    when(mockMeasurementProvider.findCategoryById(any)).thenReturn(
      getMeasurementCategories().first,
    );

    mockNutritionPlansProvider = MockNutritionPlansProvider();
    when(mockNutritionPlansProvider.currentPlan).thenReturn(null);
    when(mockNutritionPlansProvider.items).thenReturn([]);
  });

  Widget createHomeScreen({locale = 'en'}) {
    final key = GlobalKey<NavigatorState>();

    return ChangeNotifierProvider<NutritionPlansProvider>(
      create: (context) => mockNutritionPlansProvider,
      child: ChangeNotifierProvider<MeasurementProvider>(
        create: (context) => mockMeasurementProvider,
        child: MaterialApp(
          locale: Locale(locale),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          navigatorKey: key,
          home: TextButton(
            onPressed: () => key.currentState!.push(
              MaterialPageRoute<void>(
                settings: const RouteSettings(arguments: 1),
                builder: (_) => const MeasurementEntriesScreen(),
              ),
            ),
            child: Container(),
          ),
        ),
      ),
    );
  }

  testWidgets('Test the widgets on the measurement entries screen', (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen());
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    // Nav bar
    expect(find.text('Body fat'), findsOneWidget);

    // Entries
    expect(find.text('30 %'), findsOneWidget);
  });

  testWidgets('Tests the localization of dates - EN', (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen());
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    // From the entries list
    expect(find.text('9/10/2022 08:00'), findsWidgets);
    expect(find.text('10/5/2022 07:30'), findsWidgets);
  });

  testWidgets('Tests the localization of dates - DE', (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen(locale: 'de'));
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();
    expect(find.text('10.9.2022 08:00'), findsWidgets);
    expect(find.text('5.10.2022 07:30'), findsWidgets);
  });

  group('MeasurementEntryForm time format consistency', () {
    Widget createFormScreen({
      String locale = 'en',
      MeasurementEntry? entry,
    }) {
      when(mockMeasurementProvider.categories).thenReturn(getMeasurementCategories());
      return ChangeNotifierProvider<MeasurementProvider>(
        create: (context) => mockMeasurementProvider,
        child: MaterialApp(
          locale: Locale(locale),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: MeasurementEntryForm(1, entry),
            ),
          ),
        ),
      );
    }

    testWidgets('Time field uses 24h format (HH:mm) for new entries - EN', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createFormScreen(locale: 'en'));
      await tester.pumpAndSettle();

      // The time field should contain a time in HH:mm format (24h),
      // not AM/PM format, to stay consistent with DateFormat.Hm parsing
      final timeField = find.byWidgetPredicate(
        (widget) => widget is TextFormField && widget.controller?.text != null,
      );
      expect(timeField, findsWidgets);

      // Find the time controller text - it should match HH:mm pattern
      final timeFields = tester.widgetList<TextFormField>(timeField);
      final timeWidget = timeFields.where((w) {
        final text = w.controller?.text ?? '';
        // Time field contains a colon but no slash (date has slashes)
        return text.contains(':') && !text.contains('/') && !text.contains('.');
      });
      expect(timeWidget, isNotEmpty, reason: 'Should find a time field with HH:mm format');

      final timeText = timeWidget.first.controller!.text;
      // Verify it does NOT contain AM/PM
      expect(
        timeText.contains('AM'),
        isFalse,
        reason: 'Time should be 24h format, not 12h with AM',
      );
      expect(
        timeText.contains('PM'),
        isFalse,
        reason: 'Time should be 24h format, not 12h with PM',
      );
      // Verify it matches HH:mm pattern
      expect(
        RegExp(r'^\d{1,2}:\d{2}$').hasMatch(timeText),
        isTrue,
        reason: 'Time "$timeText" should match HH:mm pattern',
      );
    });

    testWidgets('Time field uses 24h format for existing entries with PM time', (
      WidgetTester tester,
    ) async {
      // Use an entry with a PM time (18:30) to verify it's not shown as "6:30 PM"
      final pmEntry = MeasurementEntry(
        id: 10,
        category: 1,
        date: DateTime(2023, 6, 15, 18, 30),
        value: 25,
        notes: '',
      );
      await tester.pumpWidget(createFormScreen(locale: 'en', entry: pmEntry));
      await tester.pumpAndSettle();

      // Should find "18:30" not "6:30 PM"
      final allTextFields = tester.widgetList<TextFormField>(find.byType(TextFormField));
      final timeTexts = allTextFields
          .map((w) => w.controller?.text ?? '')
          .where((t) => t.contains(':') && !t.contains('/') && !t.contains('.'));

      expect(timeTexts, isNotEmpty);
      final timeText = timeTexts.first;
      expect(
        timeText,
        equals('18:30'),
        reason: 'PM time should be displayed as 18:30, not 6:30 PM',
      );
    });

    testWidgets('Time field uses 24h format - DE locale', (WidgetTester tester) async {
      final entry = MeasurementEntry(
        id: 10,
        category: 1,
        date: DateTime(2023, 6, 15, 14, 45),
        value: 25,
        notes: '',
      );
      await tester.pumpWidget(createFormScreen(locale: 'de', entry: entry));
      await tester.pumpAndSettle();

      final allTextFields = tester.widgetList<TextFormField>(find.byType(TextFormField));
      final timeTexts = allTextFields
          .map((w) => w.controller?.text ?? '')
          .where((t) => t.contains(':') && !t.contains('/') && !t.contains('.'));

      expect(timeTexts, isNotEmpty);
      final timeText = timeTexts.first;
      expect(timeText, equals('14:45'));
    });
  });
}
