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
import 'package:provider/provider.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/providers/user.dart';
import 'package:wger/screens/configure_plates_screen.dart';
import 'package:wger/widgets/core/settings/exercise_cache.dart';

class SettingsPage extends StatelessWidget {
  static String routeName = '/SettingsPage';

  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final nutritionProvider = Provider.of<NutritionPlansProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(i18n.settingsTitle)),
      body: ListView(
        children: [
          ListTile(
            title: Text(i18n.settingsCacheTitle, style: Theme.of(context).textTheme.headlineSmall),
          ),
          const SettingsExerciseCache(),
          ListTile(
            title: Text(i18n.settingsIngredientCacheDescription),
            subtitle: Text('${nutritionProvider.ingredients.length} cached ingredients'),
            trailing: IconButton(
              key: const ValueKey('cacheIconIngredients'),
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await nutritionProvider.clearIngredientCache();

                if (context.mounted) {
                  final snackBar = SnackBar(content: Text(i18n.settingsCacheDeletedSnackbar));

                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
            ),
          ),
          ListTile(title: Text(i18n.others, style: Theme.of(context).textTheme.headlineSmall)),
          ListTile(
            title: Text(i18n.themeMode),
            trailing: DropdownButton<ThemeMode>(
              key: const ValueKey('themeModeDropdown'),
              value: userProvider.themeMode,
              onChanged: (ThemeMode? newValue) {
                if (newValue != null) {
                  userProvider.setThemeMode(newValue);
                }
              },
              items: ThemeMode.values.map<DropdownMenuItem<ThemeMode>>((ThemeMode value) {
                final label = (() {
                  switch (value) {
                    case ThemeMode.system:
                      return i18n.systemMode;
                    case ThemeMode.light:
                      return i18n.lightMode;
                    case ThemeMode.dark:
                      return i18n.darkMode;
                  }
                })();

                return DropdownMenuItem<ThemeMode>(value: value, child: Text(label));
              }).toList(),
            ),
          ),
          ListTile(
            title: Text(i18n.selectAvailablePlates),
            onTap: () {
              Navigator.of(context).pushNamed(ConfigurePlatesScreen.routeName);
            },
            trailing: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
