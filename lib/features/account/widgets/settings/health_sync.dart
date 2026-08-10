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

import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:wger/core/formatting/formatting.dart';
import 'package:wger/features/health/providers/health_repository.dart';
import 'package:wger/features/health/providers/health_sync.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

class HealthSyncSettingsTile extends ConsumerStatefulWidget {
  const HealthSyncSettingsTile({super.key});

  @override
  ConsumerState<HealthSyncSettingsTile> createState() => _HealthSyncSettingsTileState();
}

class _HealthSyncSettingsTileState extends ConsumerState<HealthSyncSettingsTile> {
  final _logger = Logger('HealthSyncSettingsTile');
  HealthPlatformAvailability? _availability;

  @override
  void initState() {
    super.initState();
    _checkAvailability();
  }

  Future<void> _checkAvailability() async {
    final notifier = ref.read(healthSyncProvider.notifier);
    final availability = await notifier.availability();
    if (mounted) {
      setState(() => _availability = availability);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hide entirely (including the section header) while the platform check
    // is running, and on platforms that have no health platform at all
    if (_availability == null || _availability == HealthPlatformAvailability.unsupported) {
      return const SizedBox.shrink();
    }

    final syncState = ref.watch(healthSyncProvider);

    final i18n = AppLocalizations.of(context);

    if (_availability != HealthPlatformAvailability.available) {
      return Column(
        children: [
          ListTile(
            title: Text(i18n.health, style: Theme.of(context).textTheme.headlineSmall),
          ),
          _installTile(i18n),
        ],
      );
    }

    return Column(
      children: [
        ListTile(
          title: Text(i18n.health, style: Theme.of(context).textTheme.headlineSmall),
        ),
        SwitchListTile(
          title: Text(i18n.healthSync),
          subtitle: Text(i18n.healthSyncDescription),
          value: syncState.isEnabled,
          onChanged: syncState.isSyncing
              ? null
              : (enabled) async {
                  final notifier = ref.read(healthSyncProvider.notifier);
                  if (enabled) {
                    // null means the platform permissions were not granted.
                    // A platform that refuses the request outright throws, and
                    // that must not reach the global error dialog: to the user
                    // it is the same "no access" situation.
                    int? count;
                    try {
                      count = await notifier.enableSync();
                    } catch (e) {
                      _logger.warning('Enabling health sync failed', e);
                    }
                    if (!context.mounted) {
                      return;
                    }
                    if (count == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(i18n.healthSyncPermissionDenied)),
                      );
                    } else if (count > 0) {
                      // Imported entries land in the local Drift DB and surface through
                      // the measurement stream automatically, so no manual refresh is needed.
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(i18n.healthSyncSuccess(count))),
                      );
                    } else {
                      // An empty initial import usually means the platform has
                      // no data to give: either there is none, or the read
                      // access was declined, which at least iOS never reports
                      // (the request "succeeds" and reads come back empty).
                      // Point at the platform's permission settings.
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(i18n.healthSyncNoData(_platformName))),
                      );
                    }
                  } else {
                    await notifier.disableSync();
                  }
                },
        ),
        if (syncState.isEnabled) _statusTile(syncState, i18n),
      ],
    );
  }

  String get _platformName =>
      defaultTargetPlatform == TargetPlatform.iOS ? 'Apple Health' : 'Health Connect';

  /// Offered instead of the toggle when Health Connect is missing or too old:
  /// hiding the feature would leave the user with no idea it exists, or why
  /// it disappeared.
  Widget _installTile(AppLocalizations i18n) {
    final needsUpdate = _availability == HealthPlatformAvailability.updateRequired;
    return ListTile(
      leading: const Icon(Icons.download),
      title: Text(needsUpdate ? i18n.healthConnectUpdate : i18n.healthConnectInstall),
      subtitle: Text(i18n.healthConnectRequired),
      onTap: () async {
        await ref.read(healthSyncProvider.notifier).openHealthConnectInstall();
        // The store leaves the app, so re-check what came back
        await _checkAvailability();
      },
    );
  }

  /// Status line under the toggle: what the last sync did or why it didn't,
  /// a spinner while one is running, and tapping it syncs (or, when the
  /// platform withholds the data, asks for access again).
  Widget _statusTile(HealthSyncState syncState, AppLocalizations i18n) {
    if (syncState.isSyncing) {
      return ListTile(
        leading: const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
        title: Text(i18n.healthSyncSyncing),
        enabled: false,
      );
    }

    final needsPermission = syncState.issue == HealthSyncIssue.permissionsMissing;
    final colors = Theme.of(context).colorScheme;
    final lastSync = syncState.lastSyncTime;

    final String title;
    if (needsPermission) {
      title = i18n.healthSyncPermissionMissing(_platformName);
    } else if (syncState.issue == HealthSyncIssue.failed) {
      title = i18n.healthSyncFailed;
    } else if (lastSync != null) {
      title = i18n.healthSyncStatus(
        syncState.lastSyncCount,
        localizedDate(context).add_Hm().format(lastSync),
      );
    } else {
      title = i18n.healthSyncNow;
    }

    return ListTile(
      leading: Icon(
        needsPermission ? Icons.warning_amber : Icons.sync,
        color: needsPermission ? colors.error : null,
      ),
      title: Text(
        title,
        style: needsPermission ? TextStyle(color: colors.error) : null,
      ),
      subtitle: Text(needsPermission ? i18n.healthSyncGrantAccess : i18n.healthSyncNow),
      onTap: () async {
        final notifier = ref.read(healthSyncProvider.notifier);
        // Asking for the permissions shows the platform dialog, which only
        // ever happens because the user tapped here
        final count = needsPermission
            ? await notifier.retryWithPermissions()
            : await notifier.sync();
        // The status line already covers "nothing new" and every failure;
        // only actual imports get a snackbar
        if (mounted && count != null && count > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(i18n.healthSyncSuccess(count))),
          );
        }
      },
    );
  }
}
