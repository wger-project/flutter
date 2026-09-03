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

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wger/core/widgets/decimal_input.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

void main() {
  Widget wrap(Widget child, {String locale = 'en'}) {
    return MaterialApp(
      locale: Locale(locale),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );
  }

  testWidgets('renders the value with the en decimal separator', (WidgetTester tester) async {
    await tester.pumpWidget(
      wrap(DecimalInputWidget(value: 12.5, labelText: 'X', onChanged: (_) {})),
    );
    await tester.pumpAndSettle();

    expect(find.text('12.5'), findsOneWidget);
  });

  testWidgets('renders the value with the de decimal separator', (WidgetTester tester) async {
    await tester.pumpWidget(
      wrap(
        DecimalInputWidget(value: 12.5, labelText: 'X', onChanged: (_) {}),
        locale: 'de',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('12,5'), findsOneWidget);
  });

  testWidgets('reports the value parsed with the active locale', (WidgetTester tester) async {
    num? captured = 0;
    await tester.pumpWidget(
      wrap(
        DecimalInputWidget(value: null, labelText: 'X', onChanged: (v) => captured = v),
        locale: 'de',
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '7,5');

    expect(captured, 7.5);
  });

  testWidgets('accepts a dot typed on a comma-decimal keyboard', (WidgetTester tester) async {
    num? captured = 0;
    await tester.pumpWidget(
      wrap(
        DecimalInputWidget(value: null, labelText: 'X', onChanged: (v) => captured = v),
        locale: 'de',
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '7.5');

    expect(find.text('7,5'), findsOneWidget);
    expect(captured, 7.5);
  });

  testWidgets('drops decimal digits beyond two', (WidgetTester tester) async {
    num? captured = 0;
    await tester.pumpWidget(
      wrap(DecimalInputWidget(value: null, labelText: 'X', onChanged: (v) => captured = v)),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '7.555');

    expect(find.text('7.55'), findsOneWidget);
    expect(captured, 7.55);
  });

  testWidgets('reports null when the field is cleared', (WidgetTester tester) async {
    num? captured = 1;
    await tester.pumpWidget(
      wrap(DecimalInputWidget(value: 5, labelText: 'X', onChanged: (v) => captured = v)),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '');

    expect(captured, isNull);
  });

  testWidgets('a required empty field fails validation', (WidgetTester tester) async {
    final formKey = GlobalKey<FormState>();
    await tester.pumpWidget(
      wrap(
        Form(
          key: formKey,
          child: DecimalInputWidget(
            value: null,
            labelText: 'X',
            isRequired: true,
            onChanged: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(formKey.currentState!.validate(), isFalse);
  });

  testWidgets('an optional empty field passes validation', (WidgetTester tester) async {
    final formKey = GlobalKey<FormState>();
    await tester.pumpWidget(
      wrap(
        Form(
          key: formKey,
          child: DecimalInputWidget(value: null, labelText: 'X', onChanged: (_) {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(formKey.currentState!.validate(), isTrue);
  });

  group('steppers', () {
    Widget wrapStepped({
      num? value = 80,
      String locale = 'en',
      num? min,
      num? max,
      required ValueChanged<num?> onChanged,
    }) => wrap(
      DecimalInputWidget(
        value: value,
        labelText: 'X',
        min: min,
        max: max,
        steppers: const [1, 0.1],
        onChanged: onChanged,
      ),
      locale: locale,
    );

    testWidgets('a field without them has no buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(DecimalInputWidget(value: 80, labelText: 'X', onChanged: (_) {})),
      );
      await tester.pumpAndSettle();

      expect(find.byType(IconButton), findsNothing);
    });

    testWidgets('each button steps the field by its size and reports it', (
      WidgetTester tester,
    ) async {
      num? captured;
      await tester.pumpWidget(wrapStepped(onChanged: (value) => captured = value));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('stepper-minus-0')));
      await tester.pumpAndSettle();
      expect(find.text('79'), findsOneWidget);
      expect(captured, 79);

      await tester.tap(find.byKey(const Key('stepper-plus-1')));
      await tester.pumpAndSettle();
      expect(find.text('79.1'), findsOneWidget);
      expect(captured, 79.1);
    });

    testWidgets('steps in the format of the active locale', (WidgetTester tester) async {
      await tester.pumpWidget(wrapStepped(locale: 'de', onChanged: (_) {}));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('stepper-minus-1')));
      await tester.pumpAndSettle();

      expect(find.text('79,9'), findsOneWidget);
    });

    testWidgets('a step out of the valid range is ignored', (WidgetTester tester) async {
      num? captured;
      await tester.pumpWidget(
        wrapStepped(value: 80, min: 80, max: 80.5, onChanged: (value) => captured = value),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('stepper-minus-0')));
      await tester.tap(find.byKey(const Key('stepper-plus-0')));
      await tester.pumpAndSettle();

      expect(find.text('80'), findsOneWidget);
      expect(captured, isNull);
    });

    testWidgets('an empty field has nothing to step', (WidgetTester tester) async {
      await tester.pumpWidget(wrapStepped(value: null, onChanged: (_) {}));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('stepper-plus-0')));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('1'), findsNothing);
    });
  });
}
