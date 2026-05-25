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
import 'package:intl/intl.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

/// Validates an optional decimal text field.
///
/// Empty input is allowed and returns `null`. Non-empty input must be
/// parseable by [numberFormat]; otherwise an `enterValidNumber` error
/// message is returned.
String? validateOptionalDecimal(
  String? text,
  NumberFormat numberFormat,
  BuildContext context,
) {
  final trimmed = (text ?? '').trim();
  if (trimmed.isEmpty) {
    return null;
  }
  if (numberFormat.tryParse(trimmed) == null) {
    return AppLocalizations.of(context).enterValidNumber;
  }
  return null;
}
