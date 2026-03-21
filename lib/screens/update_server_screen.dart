/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
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

/// Screen shown when the connected server's version is below the minimum
/// required by this build of the app. Mirrors [UpdateAppScreen] but surfaces
/// to the user that they need to ask their server administrator to upgrade,
/// rather than updating the app itself.
class UpdateServerScreen extends StatelessWidget {
  const UpdateServerScreen({super.key});

  static const routeName = '/update-server';

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);

    return Scaffold(
      body: AlertDialog(
        title: Text(
          i18n.serverUpdateTitle,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        content: Text(i18n.serverUpdateContent(MIN_SERVER_VERSION)),
        actions: null,
      ),
    );
  }
}
