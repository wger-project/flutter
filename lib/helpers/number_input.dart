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

/// A [TextInputFormatter] for non-negative decimal numbers.
///
/// A numeric keyboard cannot be pinned to a locale, so a user may only be able
/// to type '.' even when the locale expects ','. This formatter accepts both
/// '.' and ',' and rewrites the separator to [decimalSeparator], so the field
/// content always matches the active locale and parses correctly with
/// `NumberFormat.parse`. Digits are kept, at most one separator is allowed, and
/// every other character (grouping separators, spaces, letters) is dropped.
class LocalizedDecimalInputFormatter extends TextInputFormatter {
  LocalizedDecimalInputFormatter(this.decimalSeparator);

  /// Decimal separator of the active locale, e.g. obtained from
  /// `NumberFormat.decimalPattern(locale).symbols.DECIMAL_SEP`.
  final String decimalSeparator;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    final filtered = _filter(text);

    final base = newValue.selection.baseOffset;
    final cursor = (base < 0 || base > text.length)
        ? filtered.length
        : _filter(text.substring(0, base)).length;

    return TextEditingValue(
      text: filtered,
      selection: TextSelection.collapsed(offset: cursor),
    );
  }

  String _filter(String input) {
    const digits = '0123456789';
    final buffer = StringBuffer();
    var hasSeparator = false;
    for (var i = 0; i < input.length; i++) {
      final char = input[i];
      if (digits.contains(char)) {
        buffer.write(char);
      } else if (char == '.' || char == ',') {
        if (!hasSeparator) {
          buffer.write(decimalSeparator);
          hasSeparator = true;
        }
      }
    }
    return buffer.toString();
  }
}
