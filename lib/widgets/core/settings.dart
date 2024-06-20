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
import 'package:wger/providers/exercises.dart';

class SettingsPage extends StatefulWidget {
  static String routeName = '/SettingsPage';

  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final exerciseProvider = Provider.of<ExercisesProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).settingsTitle),
      ),
      body: ListView(
        children: [
          ListTile(
            // leading: const Icon(Icons.cached),
            title: Text(AppLocalizations.of(context).settingsCacheTitle),
            subtitle: Text(AppLocalizations.of(context).settingsCacheDescription),
            trailing: IconButton(
              key: const ValueKey('cacheIcon'),
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await exerciseProvider.clearAllCachesAndPrefs();

                if (context.mounted) {
                  final snackBar = SnackBar(
                    content: Text(AppLocalizations.of(context).settingsCacheDeletedSnackbar),
                  );

                  // Find the ScaffoldMessenger in the widget tree
                  // and use it to show a SnackBar.
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
