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
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/misc.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/auth_notifier.dart';

/// Shown when the wger server is reachable but PowerSync is not, AND the
/// user has never completed a sync (i.e. has no usable local data).
class PowerSyncUnreachableScreen extends ConsumerWidget {
  const PowerSyncUnreachableScreen({super.key});

  static const routeName = '/powersync-unreachable';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = AppLocalizations.of(context);

    return Scaffold(
      body: Center(
        child: AlertDialog(
          title: Text(
            i18n.powerSyncUnreachableTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          content: SingleChildScrollView(
            child: Text(i18n.powerSyncUnreachableContent),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                await ref.read(authProvider.notifier).logout();
                navigator.pushReplacementNamed('/');
              },
              child: Text(i18n.logout),
            ),
            TextButton(
              onPressed: () => launchURL(READTHEDOCS_URL, context),
              child: Text(i18n.aboutViewDocsTitle),
            ),
            FilledButton(
              onPressed: () => ref.read(authProvider.notifier).retryAutoLogin(),
              child: Text(i18n.serverUnreachableRetry),
            ),
          ],
        ),
      ),
    );
  }
}
