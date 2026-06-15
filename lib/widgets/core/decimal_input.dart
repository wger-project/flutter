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
import 'package:intl/intl.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/number_input.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

/// Locale-aware decimal text field.
///
/// Renders [value] with the active locale's number format and reports edits
/// through [onChanged] as a parsed [num], or null when the field is empty.
/// Display and parsing always go through the same NumberFormat, so a value can
/// never be mis-read because of a decimal-separator mismatch between locales.
class DecimalInputWidget extends StatelessWidget {
  const DecimalInputWidget({
    required this.value,
    required this.onChanged,
    required this.labelText,
    this.suffixText,
    this.isRequired = false,
    this.min,
    this.max,
    super.key,
  });

  /// The current value, or null when unset.
  final num? value;

  /// Called with the parsed value on every edit, or null when the field is
  /// cleared or its contents cannot be parsed.
  final ValueChanged<num?> onChanged;

  final String labelText;

  final String? suffixText;

  /// When true, an empty field fails validation instead of being accepted.
  final bool isRequired;

  /// Optional inclusive lower bound. When both [min] and [max] are set, a
  /// parsed value outside the range fails validation.
  final num? min;

  /// Optional inclusive upper bound. See [min].
  final num? max;

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final numberFormat = NumberFormat.decimalPattern(Localizations.localeOf(context).toString());

    return TextFormField(
      initialValue: value == null ? '' : numberFormat.format(value),
      decoration: InputDecoration(labelText: labelText, suffixText: suffixText),
      keyboardType: textInputTypeDecimal,
      inputFormatters: [LocalizedDecimalInputFormatter(numberFormat.symbols.DECIMAL_SEP)],
      onChanged: (text) {
        final trimmed = text.trim();
        onChanged(trimmed.isEmpty ? null : numberFormat.tryParse(trimmed));
      },
      validator: (text) {
        final trimmed = text?.trim() ?? '';
        if (trimmed.isEmpty) {
          return isRequired ? i18n.enterValue : null;
        }
        final parsed = numberFormat.tryParse(trimmed);
        if (parsed == null) {
          return i18n.enterValidNumber;
        }
        if (min != null && max != null && (parsed < min! || parsed > max!)) {
          return i18n.formMinMaxValues(min!.toInt(), max!.toInt());
        }
        return null;
      },
    );
  }
}
