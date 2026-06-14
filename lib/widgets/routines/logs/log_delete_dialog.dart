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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/log.dart';
import 'package:wger/providers/workout_logs_notifier.dart';

/// Confirms and deletes [log], showing a success snackbar afterwards.
void showDeleteLogDialog(BuildContext context, String confirmDeleteName, Log log) async {
  final res = await showDialog(
    context: context,
    builder: (BuildContext contextDialog) {
      return AlertDialog(
        content: Text(AppLocalizations.of(context).confirmDelete(confirmDeleteName)),
        actions: [
          TextButton(
            key: const ValueKey('cancel-button'),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            onPressed: () => Navigator.of(contextDialog).pop(),
          ),
          TextButton(
            key: const ValueKey('delete-button'),
            child: Text(
              AppLocalizations.of(context).delete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onPressed: () async {
              await ProviderScope.containerOf(
                context,
              ).read(workoutLogProvider).deleteEntry(log.id.toString());

              Navigator.of(contextDialog).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context).successfullyDeleted,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
        ],
      );
    },
  );
  return res;
}
