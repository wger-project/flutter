/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
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
import 'package:powersync/powersync.dart' as ps;
import 'package:provider/provider.dart';
import 'package:wger/database/powersync/powersync.dart' show syncStatus;
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/auth.dart';
import 'package:wger/providers/gallery.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/providers/user.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/widgets/core/about.dart';
import 'package:wger/widgets/core/settings.dart';
import 'package:wger/widgets/user/forms.dart';

Widget _makeIcon(String text, IconData icon) {
  return Tooltip(
    message: text,
    child: SizedBox(width: 40, height: null, child: Icon(icon, size: 24)),
  );
}

Widget _getStatusIcon(ps.SyncStatus status) {
  if (status.anyError != null) {
    // The error message is verbose, could be replaced with something
    // more user-friendly
    if (!status.connected) {
      return _makeIcon(status.anyError!.toString(), Icons.cloud_off);
    } else {
      return _makeIcon(status.anyError!.toString(), Icons.sync_problem);
    }
  } else if (status.connecting) {
    return _makeIcon('Connecting', Icons.cloud_sync_outlined);
  } else if (!status.connected) {
    return _makeIcon('Not connected', Icons.cloud_off);
  } else if (status.uploading && status.downloading) {
    // The status changes often between downloading, uploading and both,
    // so we use the same icon for all three
    return _makeIcon('Uploading and downloading', Icons.cloud_sync_outlined);
  } else if (status.uploading) {
    return _makeIcon('Uploading', Icons.cloud_upload_outlined);
  } else if (status.downloading) {
    return _makeIcon('Downloading', Icons.cloud_download_outlined);
  } else {
    return _makeIcon('Connected', Icons.cloud_queue);
  }
}

class MainAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String _title;

  const MainAppBar(this._title);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncStatus);
    final statusIcon = _getStatusIcon(syncState);

    return AppBar(
      title: Text(_title),
      actions: [
        statusIcon,
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () async {
            return showDialog(
              context: context,
              builder: (BuildContext context) {
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
                        onTap: () => Navigator.pushNamed(
                          context,
                          FormScreen.routeName,
                          arguments: FormScreenArguments(
                            AppLocalizations.of(context).userProfile,
                            UserProfileForm(
                              context.read<UserProvider>().profile!,
                            ),
                          ),
                        ),
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
                        onTap: () {
                          final auth = context.read<AuthProvider>();
                          auth.logout();
                          context.read<RoutinesProvider>().clear();
                          context.read<NutritionPlansProvider>().clear();
                          // ref.read(bodyWeightStateProvider.notifier).clear();
                          context.read<GalleryProvider>().clear();
                          context.read<UserProvider>().clear();

                          Navigator.of(context).pop();
                          Navigator.of(context).pushReplacementNamed('/');
                        },
                      ),
                    ],
                  ),
                );
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
