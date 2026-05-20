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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/widgets/core/form_submit_button.dart';
import 'package:wger/widgets/core/progress_indicator.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('renders the label and runs onPressed', (WidgetTester tester) async {
    var pressed = false;
    await tester.pumpWidget(
      wrap(FormSubmitButton(label: 'Save', onPressed: () async => pressed = true)),
    );

    expect(find.text('Save'), findsOneWidget);

    await tester.tap(find.byType(FormSubmitButton));
    await tester.pumpAndSettle();

    expect(pressed, isTrue);
  });

  testWidgets('shows a spinner while the action runs', (WidgetTester tester) async {
    final completer = Completer<void>();
    await tester.pumpWidget(
      wrap(FormSubmitButton(label: 'Save', onPressed: () => completer.future)),
    );

    await tester.tap(find.byType(FormSubmitButton));
    await tester.pump();

    expect(find.byType(FormProgressIndicator), findsOneWidget);
    expect(find.text('Save'), findsNothing);

    completer.complete();
    await tester.pumpAndSettle();

    expect(find.byType(FormProgressIndicator), findsNothing);
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('does not run the action a second time while it is in flight', (
    WidgetTester tester,
  ) async {
    var count = 0;
    final completer = Completer<void>();
    await tester.pumpWidget(
      wrap(
        FormSubmitButton(
          label: 'Save',
          onPressed: () {
            count++;
            return completer.future;
          },
        ),
      ),
    );

    await tester.tap(find.byType(FormSubmitButton));
    await tester.pump();
    await tester.tap(find.byType(FormSubmitButton), warnIfMissed: false);
    await tester.pump();

    expect(count, 1);

    completer.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('is disabled when enabled is false', (WidgetTester tester) async {
    var pressed = false;
    await tester.pumpWidget(
      wrap(
        FormSubmitButton(
          label: 'Save',
          enabled: false,
          onPressed: () async => pressed = true,
        ),
      ),
    );

    await tester.tap(find.byType(FormSubmitButton), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(pressed, isFalse);
  });
}
