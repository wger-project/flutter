/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 wger Team
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

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/helpers/number_input.dart';

void main() {
  final de = LocalizedDecimalInputFormatter(',');
  final en = LocalizedDecimalInputFormatter('.');

  TextEditingValue apply(LocalizedDecimalInputFormatter formatter, String text, {int? cursor}) {
    return formatter.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: cursor ?? text.length),
      ),
    );
  }

  group('LocalizedDecimalInputFormatter', () {
    test('rewrites a typed dot to the locale separator', () {
      expect(apply(de, '80.5').text, '80,5');
    });

    test('rewrites a typed comma to the locale separator', () {
      expect(apply(en, '80,5').text, '80.5');
    });

    test('keeps input that already uses the locale separator', () {
      expect(apply(de, '80,5').text, '80,5');
      expect(apply(en, '80.5').text, '80.5');
    });

    test('leaves plain integers and empty input untouched', () {
      expect(apply(de, '80').text, '80');
      expect(apply(de, '').text, '');
    });

    test('strips letters', () {
      expect(apply(de, 'abc').text, '');
      expect(apply(de, '8a0').text, '80');
    });

    test('strips grouping separators a numeric keypad cannot produce', () {
      expect(apply(de, "1'234.5").text, '1234,5');
      expect(apply(de, '1 234,5').text, '1234,5');
    });

    test('keeps only the first separator', () {
      expect(apply(de, '1.2.3').text, '1,23');
      expect(apply(en, '1,2,3').text, '1.23');
    });

    test('keeps the cursor after the edited character', () {
      final result = apply(de, '8.5', cursor: 2);
      expect(result.text, '8,5');
      expect(result.selection.baseOffset, 2);
    });

    test('places the cursor at the end when the offset is unknown', () {
      final result = apply(de, '8.5', cursor: -1);
      expect(result.text, '8,5');
      expect(result.selection.baseOffset, 3);
    });
  });
}
