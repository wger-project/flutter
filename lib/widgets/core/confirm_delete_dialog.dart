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
import 'package:wger/l10n/generated/app_localizations.dart';

/// Shows a "confirm delete" dialog for [itemName].
///
/// On confirm it awaits [onConfirm], closes the dialog, calls [onDeleted] (for
/// extra navigation, e.g. popping a detail screen) and shows a "deleted"
/// snackbar. Cancelling or dismissing does nothing. Pass [title] for the few
/// callers that want a heading above the message.
Future<void> showConfirmDeleteDialog(
  BuildContext context, {
  required String itemName,
  required Future<void> Function() onConfirm,
  String? title,
  VoidCallback? onDeleted,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      final i18n = AppLocalizations.of(dialogContext);
      return AlertDialog(
        title: title != null ? Text(title) : null,
        content: Text(i18n.confirmDelete(itemName)),
        actions: [
          TextButton(
            key: const ValueKey('cancel-button'),
            child: Text(MaterialLocalizations.of(dialogContext).cancelButtonLabel),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          TextButton(
            key: const ValueKey('delete-button'),
            child: Text(
              i18n.delete,
              style: TextStyle(color: Theme.of(dialogContext).colorScheme.error),
            ),
            onPressed: () async {
              await onConfirm();
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
              if (context.mounted) {
                onDeleted?.call();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(i18n.successfullyDeleted, textAlign: TextAlign.center),
                  ),
                );
              }
            },
          ),
        ],
      );
    },
  );
}
