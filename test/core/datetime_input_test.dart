/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 - 2026 wger Team
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
import 'package:wger/widgets/core/datetime_input.dart';

void main() {
  Widget wrap(Widget child, {String locale = 'en'}) {
    return MaterialApp(
      locale: Locale(locale),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );
  }

  group('TimeInputWidget', () {
    testWidgets('renders the value in a 12-hour locale', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(
          TimeInputWidget(
            value: const TimeOfDay(hour: 15, minute: 30),
            labelText: 'Time',
            onChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('3:30 PM'), findsOneWidget);
    });

    testWidgets('renders the value in a 24-hour locale', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(
          TimeInputWidget(
            value: const TimeOfDay(hour: 15, minute: 30),
            labelText: 'Time',
            onChanged: (_) {},
          ),
          locale: 'de',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('15:30'), findsOneWidget);
    });

    testWidgets('shows nothing when the value is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(TimeInputWidget(value: null, labelText: 'Time', onChanged: (_) {})),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.clear), findsNothing);
    });

    testWidgets('clear button invokes onCleared and clears the display', (
      WidgetTester tester,
    ) async {
      var cleared = false;
      await tester.pumpWidget(
        wrap(
          TimeInputWidget(
            value: const TimeOfDay(hour: 15, minute: 30),
            labelText: 'Time',
            onChanged: (_) {},
            onCleared: () => cleared = true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('3:30 PM'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      expect(cleared, isTrue);
      expect(find.text('3:30 PM'), findsNothing);
    });
  });

  group('DateInputWidget', () {
    testWidgets('renders the value localized', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(
          DateInputWidget(
            value: DateTime(2021, 1, 5),
            labelText: 'Date',
            onChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1/5/2021'), findsOneWidget);
    });

    testWidgets('renders the value localized for a comma-decimal locale', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          DateInputWidget(
            value: DateTime(2021, 1, 5),
            labelText: 'Date',
            onChanged: (_) {},
          ),
          locale: 'de',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('5.1.2021'), findsOneWidget);
    });
  });
}
