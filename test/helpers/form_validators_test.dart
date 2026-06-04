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

import 'package:flutter_test/flutter_test.dart';
import 'package:wger/helpers/form_validators.dart';
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
}
