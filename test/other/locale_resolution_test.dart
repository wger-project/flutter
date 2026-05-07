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
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/helpers/locale.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

void main() {
  const supported = AppLocalizations.supportedLocales;

  group('resolveLocale', () {
    test('returns null when device locale list is null', () {
      expect(resolveLocale(null, supported), isNull);
    });

    test('returns null when device locale list is empty', () {
      expect(resolveLocale([], supported), isNull);
    });

    test('returns the first locale when its language is supported', () {
      // Simulates Android 13 per-app language picker: user picked Spanish.
      final result = resolveLocale([const Locale('es')], supported);
      expect(result, const Locale('es'));
    });

    test('returns the first locale even with country code (e.g. pt-BR)', () {
      final result = resolveLocale([const Locale('pt', 'BR')], supported);
      expect(result, const Locale('pt', 'BR'));
    });

    test('returns the first locale when only language matches (e.g. es-MX → es)', () {
      // Device locale es-MX is not in supportedLocales explicitly, but Spanish is.
      // We return the device locale and let AppLocalizations' delegate
      // do the language-code lookup.
      final result = resolveLocale([const Locale('es', 'MX')], supported);
      expect(result, const Locale('es', 'MX'));
    });

    test('returns null when first locale is unsupported, falling through to Flutter default', () {
      // Vietnamese is not in supportedLocales. Returning null lets Flutter's
      // basicLocaleListResolution walk the remaining preferences.
      final result = resolveLocale([const Locale('vi')], supported);
      expect(result, isNull);
    });

    test('returns null when primary is unsupported even if a later preference is supported', () {
      // Returning null here lets Flutter's basicLocaleListResolution walk the
      // rest of the preference list and pick the supported `de`.
      final result = resolveLocale(
        [const Locale('vi'), const Locale('de')],
        supported,
      );
      expect(result, isNull);
    });

    test('honours supported locales passed in (decoupled from AppLocalizations)', () {
      const tiny = [Locale('en'), Locale('de')];
      expect(resolveLocale([const Locale('de')], tiny), const Locale('de'));
      expect(resolveLocale([const Locale('fr')], tiny), isNull);
    });
  });
}
