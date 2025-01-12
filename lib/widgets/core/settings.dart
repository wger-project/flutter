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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wger/providers/auth.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/providers/user.dart';
import 'package:wger/theme/theme.dart';


class SettingsPage extends StatelessWidget {
  static String routeName = '/SettingsPage';

  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final exerciseProvider = Provider.of<ExercisesProvider>(context, listen: false);
    final nutritionProvider = Provider.of<NutritionPlansProvider>(context, listen: false);
    final switchProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).settingsTitle),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(AppLocalizations.of(context).settingsExerciseCacheDescription),
            trailing: IconButton(
              key: const ValueKey('cacheIconExercises'),
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await exerciseProvider.clearAllCachesAndPrefs();

                if (context.mounted) {
                  final snackBar = SnackBar(
                    content: Text(AppLocalizations.of(context).settingsCacheDeletedSnackbar),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
            ),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context).settingsIngredientCacheDescription),
            trailing: IconButton(
              key: const ValueKey('cacheIconIngredients'),
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await nutritionProvider.clearIngredientCache();

                if (context.mounted) {
                  final snackBar = SnackBar(
                    content: Text(AppLocalizations.of(context).settingsCacheDeletedSnackbar),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
            ),
          ),
          ListTile(
            title: Text('Dark Mode'),
            trailing: Switch(
              value: switchProvider.isSwitched, // Use the state from the provider
              onChanged: (value) {
                switchProvider.toggleSwitch(value); // Update the state when the switch is toggled
              },
              activeColor:  wgerPrimaryButtonColor, // Custom color when switch is on
              inactiveThumbColor: wgerSecondaryColorLight, // Custom color when switch is off
              inactiveTrackColor: wgerSecondaryColor, // Color of the track when the switch is off
            ),
          ),
        ],
      ),
    );
  }
}
