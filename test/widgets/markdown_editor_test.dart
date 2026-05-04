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
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/widgets/add_exercise/add_exercise_text_area.dart';

void main() {
  Widget makeTestable({required Widget child}) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: Scaffold(body: child),
    );
  }

  testWidgets('inserts markers when no selection', (tester) async {
    await tester.pumpWidget(
      makeTestable(
        child: MarkdownEditor(initialValue: '', onChanged: (_) {}),
      ),
    );
    await tester.pumpAndSettle();

    final textFieldFinder = find.byType(TextFormField);
    expect(textFieldFinder, findsOneWidget);

    // Ensure initial is empty and then tap Bold button
    await tester.enterText(textFieldFinder, '');
    await tester.pump();

    final boldButton = find.widgetWithIcon(IconButton, Icons.format_bold);
    expect(boldButton, findsOneWidget);

    await tester.tap(boldButton);
    await tester.pump();

    final tf = tester.widget<TextFormField>(textFieldFinder);
    final controller = tf.controller!;

    expect(controller.text, '****');
    expect(controller.selection.isCollapsed, isTrue);
    expect(controller.selection.baseOffset, 2);
  });

  testWidgets('wraps selected text when selection exists', (tester) async {
    await tester.pumpWidget(
      makeTestable(
        child: MarkdownEditor(initialValue: '', onChanged: (_) {}),
      ),
    );
    await tester.pumpAndSettle();

    final textFieldFinder = find.byType(TextFormField);
    expect(textFieldFinder, findsOneWidget);

    // Enter text and set selection
    await tester.enterText(textFieldFinder, 'hello');
    await tester.pump();

    final tf = tester.widget<TextFormField>(textFieldFinder);
    final controller = tf.controller!;

    // select whole text
    controller.selection = const TextSelection(baseOffset: 0, extentOffset: 5);
    await tester.pump();

    final boldButton = find.widgetWithIcon(IconButton, Icons.format_bold);
    expect(boldButton, findsOneWidget);

    await tester.tap(boldButton);
    await tester.pump();

    expect(controller.text, '**hello**');
    // selection should cover the inner text (shifted by left.length)
    expect(controller.selection.baseOffset, 2);
    expect(controller.selection.extentOffset, 7);
  });
}
