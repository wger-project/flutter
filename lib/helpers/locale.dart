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

import 'package:flutter/widgets.dart';

/// Resolves the active locale for [WidgetsApp.localeListResolutionCallback].
///
/// If the first device locale shares a language with any [supportedLocales],
/// it is returned directly. Otherwise `null` is returned so Flutter's default
/// `basicLocaleListResolution` can walk the rest of the preference list and
/// find the best supported match.
Locale? resolveLocale(List<Locale>? locales, Iterable<Locale> supportedLocales) {
  if (locales == null || locales.isEmpty) {
    return null;
  }
  final first = locales.first;
  if (supportedLocales.any((s) => s.languageCode == first.languageCode)) {
    return first;
  }
  return null;
}
