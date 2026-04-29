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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wger/database/powersync/powersync.dart' show syncStatus;
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/auth_notifier.dart';
import 'package:wger/providers/gallery_notifier.dart';
import 'package:wger/providers/user_profile_notifier.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/screens/settings_dashboard_widgets_screen.dart';
import 'package:wger/widgets/core/about.dart';
import 'package:wger/widgets/core/settings.dart';
import 'package:wger/widgets/core/sync_status_dialog.dart';
import 'package:wger/widgets/user/forms.dart';

class MainAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String _title;

  const MainAppBar(this._title);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncStatus);
    final status = syncStatusIconAndLabel(syncState, AppLocalizations.of(context));

    return AppBar(
      title: Text(_title),
      actions: [
        IconButton(
          icon: const Icon(Icons.widgets_outlined),
          onPressed: () {
            Navigator.of(context).pushNamed(ConfigureDashboardWidgetsScreen.routeName);
          },
        ),
        IconButton(
          icon: Icon(status.icon),
          onPressed: () => showDialog<void>(
            context: context,
            builder: (_) => SyncStatusDialog(syncState),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () async {
            return showDialog(
              context: context,
              builder: (BuildContext context) {
                return const MainSettingsDialog();
              },
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class MainSettingsDialog extends ConsumerWidget {
  const MainSettingsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).optionsLabel),
      actions: [
        TextButton(
          child: Text(
            MaterialLocalizations.of(context).closeButtonLabel,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      contentPadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            //dense: true,
            leading: const Icon(Icons.person),
            title: Text(AppLocalizations.of(context).userProfile),
            onTap: () {
              // Only navigate once the profile is loaded; otherwise the form
              // would crash on a null user.
              final profile = ref.read(userProfileProvider).value;
              if (profile == null) {
                return;
              }
              Navigator.pushNamed(
                context,
                FormScreen.routeName,
                arguments: FormScreenArguments(
                  AppLocalizations.of(context).userProfile,
                  UserProfileForm(profile),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            onTap: () => Navigator.of(context).pushNamed(SettingsPage.routeName),
            title: Text(AppLocalizations.of(context).settingsTitle),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            onTap: () => Navigator.of(context).pushNamed(AboutPage.routeName),
            title: Text(AppLocalizations.of(context).aboutPageTitle),
          ),
          const Divider(),
          ListTile(
            //dense: true,
            leading: const Icon(Icons.exit_to_app),
            title: Text(AppLocalizations.of(context).logout),
            onTap: () async {
              final navigator = Navigator.of(context);

              // Auth logout wipes the local PowerSync DB as part of its
              // lifecycle. Await it so we don't race the navigation.
              await ref.read(authProvider.notifier).logout();
              ref.read(galleryProvider.notifier).clear();
              ref.read(userProfileProvider.notifier).clear();

              navigator.pop();
              navigator.pushReplacementNamed('/');
            },
          ),
        ],
      ),
    );
  }
}

/// App bar that only displays a title
class EmptyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String _title;

  const EmptyAppBar(this._title);

  @override
  Widget build(BuildContext context) {
    return AppBar(title: Text(_title), actions: const []);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
