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

import 'package:wger/l10n/generated/app_localizations.dart';

String? validateUrl(String? value, AppLocalizations i18n, {bool required = true}) {
  // Required?
  if (required && (value == null || value.trim().isEmpty)) {
    return i18n.enterValue;
  }

  if (!required && (value == null || value.trim().isEmpty)) {
    return null;
  }
  value = value!.trim();

  if (!value.startsWith('http://') && !value.startsWith('https://')) {
    return i18n.invalidUrl;
  }

  // Try to parse as URI. The earlier startsWith check guarantees a scheme
  // and the `//` authority delimiter, but `Uri.parse('http://')` still
  // succeeds with an empty host which we reject explicitly
  try {
    final uri = Uri.parse(value);
    if (uri.host.isEmpty) {
      return i18n.invalidUrl;
    }
  } catch (e) {
    return i18n.invalidUrl;
  }

  return null;
}
