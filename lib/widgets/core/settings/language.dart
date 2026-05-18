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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/locale.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/user.dart';

/// Native language names for each supported locale. Keys are produced by
/// [encodeLocale] (e.g. `pl`, `pt_BR`, `zh_Hant`).
const Map<String, String> _languageNativeNames = {
  'am': 'አማርኛ',
  'ar': 'العربية',
  'ca': 'Català',
  'cs': 'Čeština',
  'de': 'Deutsch',
  'el': 'Ελληνικά',
  'en': 'English',
  'es': 'Español',
  'fa': 'فارسی',
  'fil': 'Filipino',
  'fr': 'Français',
  'he': 'עברית',
  'hi': 'हिन्दी',
  'hr': 'Hrvatski',
  'hu': 'Magyar',
  'id': 'Bahasa Indonesia',
  'it': 'Italiano',
  'ja': '日本語',
  'ko': '한국어',
  'mk': 'Македонски',
  'nb': 'Norsk bokmål',
  'nl': 'Nederlands',
  'pl': 'Polski',
  'pt': 'Português',
  'pt_BR': 'Português (Brasil)',
  'pt_PT': 'Português (Portugal)',
  'ro': 'Română',
  'ru': 'Русский',
  'sk': 'Slovenčina',
  'ta': 'தமிழ்',
  'th': 'ไทย',
  'tr': 'Türkçe',
  'uk': 'Українська',
  'ur': 'اردو',
  'zh': '中文',
  'zh_Hant': '繁體中文',
};

String _displayNameFor(Locale locale) {
  return _languageNativeNames[encodeLocale(locale)] ??
      _languageNativeNames[locale.languageCode] ??
      encodeLocale(locale);
}

class SettingsLanguage extends StatelessWidget {
  const SettingsLanguage({super.key});

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final userProvider = Provider.of<UserProvider>(context);

    final supported = [...AppLocalizations.supportedLocales]
      ..sort((a, b) => _displayNameFor(a).compareTo(_displayNameFor(b)));

    return ListTile(
      title: Text(i18n.appLanguage),
      trailing: DropdownButton<Locale?>(
        key: const ValueKey('appLanguageDropdown'),
        value: userProvider.userLocale,
        onChanged: (Locale? newValue) {
          userProvider.setUserLocale(newValue);
        },
        items: <DropdownMenuItem<Locale?>>[
          DropdownMenuItem<Locale?>(
            value: null,
            child: Text(i18n.appLanguageSystem),
          ),
          ...supported.map(
            (locale) => DropdownMenuItem<Locale?>(
              value: locale,
              child: Text(_displayNameFor(locale)),
            ),
          ),
        ],
      ),
    );
  }
}
