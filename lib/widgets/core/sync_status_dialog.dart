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
import 'package:intl/intl.dart';
import 'package:powersync/powersync.dart'
    show CredentialsException, PowerSyncProtocolException, SyncResponseException, SyncStatus;
import 'package:wger/l10n/generated/app_localizations.dart';

/// Classifies a sync error into a short English category label
String? _categoriseSyncError(Object error) {
  if (error is CredentialsException) {
    return 'Authentication error';
  }
  if (error is SyncResponseException) {
    if (error.statusCode == 401 || error.statusCode == 403) {
      return 'Authentication error';
    }
    if (error.statusCode >= 500) {
      return 'Server error';
    }
    return 'HTTP ${error.statusCode}';
  }
  if (error is PowerSyncProtocolException) {
    return 'Protocol error';
  }

  final typeName = error.runtimeType.toString();
  if (typeName.endsWith('SocketException') ||
      typeName == 'WebSocketChannelException' ||
      typeName == 'ClientException' ||
      typeName == 'HttpException') {
    return 'Connection error';
  }

  return null;
}

({IconData icon, String label}) syncStatusIconAndLabel(
  SyncStatus status,
  AppLocalizations i18n,
) {
  if (status.anyError != null) {
    return (
      icon: status.connected ? Icons.sync_problem : Icons.cloud_off,
      label: i18n.syncStatusError,
    );
  } else if (status.connecting) {
    // Distinct from the active-sync icon below: "queue" reads as
    // "trying to establish a connection", not "transferring data".
    return (icon: Icons.cloud_queue, label: i18n.syncStatusConnecting);
  } else if (!status.connected) {
    return (icon: Icons.cloud_off, label: i18n.syncStatusDisconnected);
  } else if (status.uploading && status.downloading) {
    // The status changes often between downloading, uploading and both,
    // so we use the same icon for all three
    return (icon: Icons.cloud_sync_outlined, label: i18n.syncStatusSyncing);
  } else if (status.uploading) {
    return (icon: Icons.cloud_upload_outlined, label: i18n.syncStatusUploading);
  } else if (status.downloading) {
    return (icon: Icons.cloud_download_outlined, label: i18n.syncStatusDownloading);
  } else {
    return (icon: Icons.cloud_done_outlined, label: i18n.syncStatusConnected);
  }
}

/// Shows the current powersync status
class SyncStatusDialog extends StatelessWidget {
  final SyncStatus _status;

  const SyncStatusDialog(this._status, {super.key});

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final status = syncStatusIconAndLabel(_status, i18n);
    final lastSynced = _status.lastSyncedAt;
    final errorCategory = _status.anyError == null ? null : _categoriseSyncError(_status.anyError!);

    return AlertDialog(
      title: Text(i18n.syncStatusDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(status.icon, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(status.label, style: theme.textTheme.titleMedium),
                    if (errorCategory != null)
                      Text(
                        errorCategory,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Last sync timestamp if available
          Text(i18n.syncStatusLastSynced, style: theme.textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(
            lastSynced == null
                ? '-/-'
                : DateFormat.yMd(
                    Localizations.localeOf(context).languageCode,
                  ).add_Hms().format(lastSynced.toLocal()),
          ),

          // Raw error in an expandable section. Only shown when an error
          // actually exists; otherwise we don't render the tile at all,
          // so the dialog stays compact in the happy case.
          if (_status.anyError != null) ...[
            const SizedBox(height: 8),
            Theme(
              // ExpansionTile draws its own dividers; suppress the default
              // divider colour so the tile blends with the dialog content.
              data: theme.copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 8),
                title: Text(i18n.syncStatusErrorDetails),
                children: [
                  SelectableText(
                    _status.anyError!.toString(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).closeButtonLabel),
        ),
      ],
    );
  }
}
