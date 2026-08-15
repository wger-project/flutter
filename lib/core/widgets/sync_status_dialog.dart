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
import 'package:logging/logging.dart';
import 'package:powersync/powersync.dart' show SyncStatus;
import 'package:url_launcher/url_launcher.dart';
import 'package:wger/core/error_dialogs.dart' show CopyToClipboardButton;
import 'package:wger/core/errors.dart' show buildGithubIssueUrl;
import 'package:wger/core/formatting/formatting.dart';
import 'package:wger/core/logs.dart';
import 'package:wger/core/widgets/log_overview.dart' show LogOverviewPage;
import 'package:wger/database/powersync/powersync.dart'
    show pendingUploadCountProvider, syncStatus, syncWatchdogProvider;
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/powersync/sync_diagnostics.dart';
import 'package:wger/powersync/sync_watchdog.dart' show StalledReason;

final _logger = Logger('SyncStatusDialog');

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

/// Shows the current powersync status. Watches the status, the upload queue
/// and the watchdog, so the content keeps updating while the dialog is open.
class SyncStatusDialog extends ConsumerWidget {
  /// Drops the current sync connection and opens a fresh one. When null,
  /// the reconnect action is not shown.
  final VoidCallback? onReconnect;

  /// Server this app is syncing against. Hidden when null.
  final String? serverUrl;

  const SyncStatusDialog({this.onReconnect, this.serverUrl, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final syncState = ref.watch(syncStatus);
    // The queue count loads async for a moment; treat that as an empty queue
    final pendingUploads = ref.watch(pendingUploadCountProvider).value ?? 0;
    final status = syncStatusIconAndLabel(syncState, i18n);
    final lastSynced = syncState.lastSyncedAt;
    final errorCategory = syncState.anyError == null
        ? null
        : categoriseSyncError(syncState.anyError!);

    // stalled: the sync stream keeps reconnecting without ever receiving
    // data (see SyncStreamWatchdog). There is no error to show in that
    // case, so the dialog adds a hint about likely network-side blockers.
    final watchdog = ref.watch(syncWatchdogProvider);
    return ValueListenableBuilder<bool>(
      valueListenable: watchdog.stalled,
      builder: (context, stalled, _) => AlertDialog(
        // The report button below only appears once something is visibly
        // wrong; copying the snapshot has to work in every state, a sync
        // that looks idle is exactly the case we need reports for.
        title: Row(
          children: [
            Expanded(child: Text(i18n.syncStatusDialogTitle)),
            CopyToClipboardButton(
              text: formatSyncDiagnostics(
                syncState,
                pendingUploads: pendingUploads,
                server: serverCategory(serverUrl),
                local: ref.watch(localSyncStateProvider).value,
              ),
              iconOnly: true,
            ),
          ],
        ),
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

            // Stalled or errored sync. The hint follows the signature the
            // watchdog saw: only one of them is a blocked connection.
            if (stalled && syncState.anyError == null) ...[
              const SizedBox(height: 8),
              Text(
                switch (watchdog.stalledReason) {
                  StalledReason.notStarted => i18n.syncStatusStalledNotStartedHint,
                  StalledReason.notApplied => i18n.syncStatusStalledNotAppliedHint,
                  _ => i18n.syncStatusStalledHint,
                },
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],

            // Progress through the running download, so a long initial sync
            // is visibly moving instead of sitting on a static label.
            if (syncState.downloadProgress case final progress?) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(value: progress.downloadedFraction),
              const SizedBox(height: 4),
              Text(
                '${progress.downloadedOperations} / ${progress.totalOperations}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (pendingUploads > 0) ...[
              const SizedBox(height: 8),
              Text(
                i18n.syncStatusPendingUploads(pendingUploads),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Last sync timestamp if available
            Text(i18n.syncStatusLastSynced, style: theme.textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(
              lastSynced != null
                  ? localizedDate(context).add_Hms().format(lastSynced.toLocal())
                  : syncState.hasSynced == false
                  ? i18n.syncStatusNeverSynced
                  : '-/-',
            ),
            if (serverUrl != null) ...[
              const SizedBox(height: 16),
              Text(i18n.serverSectionLabel, style: theme.textTheme.labelMedium),
              const SizedBox(height: 4),
              Text(serverUrl!),
            ],

            // Raw error in an expandable section. Only shown when an error
            // actually exists; otherwise we don't render the tile at all,
            if (syncState.anyError != null) ...[
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
                      syncState.anyError!.toString(),
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
          // The stalled hint and the WARNING land in the application logs;
          // give the user a direct path to them.
          if (stalled && syncState.anyError == null)
            TextButton(
              onPressed: () {
                final navigator = Navigator.of(context);
                navigator.pop();
                navigator.pushNamed(LogOverviewPage.routeName);
              },
              child: Text(i18n.applicationLogs),
            ),
          // Pre-filled bug report including the sync snapshot. Sync problems
          // usually never raise the fatal error dialog, so this is their
          // report path.
          if (stalled || syncState.anyError != null)
            TextButton(
              onPressed: () async {
                final local = await collectLocalSyncState();
                final url = buildGithubIssueUrl(
                  issueTitle: 'Sync error',
                  issueErrorMessage:
                      syncState.anyError?.toString() ??
                      'Sync stream stalled (connects but receives no data)',
                  applicationLogs: InMemoryLogStore().getFormattedLogs(),
                  syncDiagnostics: formatSyncDiagnostics(
                    syncState,
                    pendingUploads: pendingUploads,
                    server: serverCategory(serverUrl),
                    local: local,
                  ),
                );
                try {
                  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                } catch (e, s) {
                  _logger.warning('Error opening issue tracker', e, s);
                }
              },
              child: const Text('Report issue'),
            ),
          // A stuck stream (firewall, VPN, flaky DNS) often recovers on a
          // fresh connection and can look healthy here while hanging, so the
          // action is not gated on an error. Absent only while offline, where
          // reconnecting would just spin against an unreachable backend.
          if (onReconnect != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onReconnect!();
              },
              child: Text(i18n.syncStatusReconnect),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(MaterialLocalizations.of(context).closeButtonLabel),
          ),
        ],
      ),
    );
  }
}
