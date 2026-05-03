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
import 'package:wger/helpers/consts.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/core/search_options.dart';

/// Dropdown that lets the user pick which language(s) to search in.
///
/// Shared between exercise and ingredient search filters. The widget is
/// purely presentational — the caller passes the currently [selected] value
/// and an [onChanged] callback to react to user input.
class SearchLanguageDropdown extends StatelessWidget {
  final SearchLanguage selected;
  final ValueChanged<SearchLanguage> onChanged;

  const SearchLanguageDropdown({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final isEnglish = languageCode == LANGUAGE_SHORT_ENGLISH;

    final items = <DropdownMenuItem<SearchLanguage>>[
      DropdownMenuItem(
        value: SearchLanguage.current,
        child: Text(i18n.searchLanguageCurrent(languageCode)),
      ),
      if (!isEnglish)
        DropdownMenuItem(
          value: SearchLanguage.currentAndEnglish,
          child: Text(i18n.searchLanguageEnglish(languageCode)),
        ),
      DropdownMenuItem(
        value: SearchLanguage.all,
        child: Text(i18n.searchLanguageAll),
      ),
    ];

    // If the persisted value isn't offered for the current locale (e.g.
    // currentAndEnglish on an English locale), fall back to null so the
    // dropdown shows a valid state until the auto-switch corrects it.
    SearchLanguage? value = selected;
    if (!items.any((it) => it.value == value)) {
      value = null;
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(i18n.language),
      subtitle: DropdownButton<SearchLanguage>(
        value: value,
        isExpanded: true,
        items: items,
        onChanged: (val) {
          if (val != null) {
            onChanged(val);
          }
        },
      ),
    );
  }
}
