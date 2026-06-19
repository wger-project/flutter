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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wger/helpers/locale.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/l10n/language_native_names.dart';
import 'package:wger/providers/app_settings_notifier.dart';

String _displayNameFor(Locale locale) {
  return languageNativeNames[encodeLocale(locale)] ??
      languageNativeNames[locale.languageCode] ??
      encodeLocale(locale);
}

class SettingsLanguage extends ConsumerWidget {
  const SettingsLanguage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = AppLocalizations.of(context);
    final userLocale = ref.watch(
      appSettingsProvider.select((s) => s.value?.userLocale),
    );

    final supported = [...AppLocalizations.supportedLocales]
      ..sort((a, b) => _displayNameFor(a).compareTo(_displayNameFor(b)));

    return ListTile(
      title: Text(i18n.appLanguage),
      trailing: DropdownButton<Locale?>(
        key: const ValueKey('appLanguageDropdown'),
        value: userLocale,
        onChanged: (Locale? newValue) {
          ref.read(appSettingsProvider.notifier).setUserLocale(newValue);
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
