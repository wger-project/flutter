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
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:wger/helpers/form_validators.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/l10n/generated/app_localizations_en.dart';

void main() {
  final i18n = AppLocalizationsEn();

  group('validateOptionalIntegerInRange', () {
    test('accepts empty input (optional)', () {
      expect(validateOptionalIntegerInRange(null, 0, 1800, i18n), isNull);
      expect(validateOptionalIntegerInRange('', 0, 1800, i18n), isNull);
    });

    test('accepts an integer within range, including the bounds', () {
      expect(validateOptionalIntegerInRange('0', 0, 1800, i18n), isNull);
      expect(validateOptionalIntegerInRange('900', 0, 1800, i18n), isNull);
      expect(validateOptionalIntegerInRange('1800', 0, 1800, i18n), isNull);
    });

    test('rejects a non-integer', () {
      expect(validateOptionalIntegerInRange('12.5', 0, 1800, i18n), i18n.enterValidNumber);
      expect(validateOptionalIntegerInRange('abc', 0, 1800, i18n), i18n.enterValidNumber);
    });

    test('rejects values outside the range', () {
      expect(validateOptionalIntegerInRange('-1', 0, 1800, i18n), i18n.formMinMaxValues(0, 1800));
      expect(validateOptionalIntegerInRange('1801', 0, 1800, i18n), i18n.formMinMaxValues(0, 1800));
    });
  });

  group('validateOptionalDecimal max bound', () {
    testWidgets('rejects values above max, accepts within and empty', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Form(
              key: formKey,
              child: Builder(
                builder: (context) => TextFormField(
                  validator: (t) => validateOptionalDecimal(
                    t,
                    NumberFormat.decimalPattern('en'),
                    context,
                    max: 100,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), '101');
      expect(formKey.currentState!.validate(), isFalse);

      await tester.enterText(find.byType(TextFormField), '100');
      expect(formKey.currentState!.validate(), isTrue);

      await tester.enterText(find.byType(TextFormField), '');
      expect(formKey.currentState!.validate(), isTrue);
    });
  });
}
