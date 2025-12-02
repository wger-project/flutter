/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

//import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:wger/core/wide_screen_wrapper.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/screens/configure_plates_screen.dart';
import 'package:wger/widgets/core/settings/ingredient_cache.dart';
import 'package:wger/widgets/core/settings/theme.dart';

class SettingsPage extends StatelessWidget {
  static String routeName = '/SettingsPage';

  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(i18n.settingsTitle)),
      body: WidescreenWrapper(
        child: ListView(
          children: [
            ListTile(
              title: Text(
                i18n.settingsCacheTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SettingsIngredientCache(),
            ListTile(title: Text(i18n.others, style: Theme.of(context).textTheme.headlineSmall)),
            const SettingsTheme(),
            ListTile(
              title: Text(i18n.selectAvailablePlates),
              onTap: () {
                Navigator.of(context).pushNamed(ConfigurePlatesScreen.routeName);
              },
              trailing: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }
}
