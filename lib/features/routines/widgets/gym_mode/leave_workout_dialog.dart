/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 wger Team
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
import 'package:wger/l10n/generated/app_localizations.dart';

/// Asks the user to confirm leaving gym mode with a workout in progress.
///
/// Returns whether the workout should be left. Dismissing the dialog without
/// choosing (tapping outside, back gesture) keeps the workout, so that a second
/// accidental gesture can't leave it either.
Future<bool> confirmLeaveWorkout(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final i18n = AppLocalizations.of(dialogContext);
      return AlertDialog(
        title: Text(i18n.leaveWorkoutTitle),
        content: Text(i18n.leaveWorkoutConfirmation),
        actions: [
          TextButton(
            key: const ValueKey('keep-training-button'),
            child: Text(MaterialLocalizations.of(dialogContext).cancelButtonLabel),
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          TextButton(
            key: const ValueKey('leave-workout-button'),
            child: Text(i18n.leaveWorkout),
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      );
    },
  );

  return confirmed ?? false;
}
