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
import 'package:wger/core/formatting/formatting.dart';
import 'package:wger/features/health/providers/health_sync.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

class HealthSyncSettingsTile extends ConsumerStatefulWidget {
  const HealthSyncSettingsTile({super.key});

  @override
  ConsumerState<HealthSyncSettingsTile> createState() => _HealthSyncSettingsTileState();
}

class _HealthSyncSettingsTileState extends ConsumerState<HealthSyncSettingsTile> {
  bool? _isAvailable;

  @override
  void initState() {
    super.initState();
    _checkAvailability();
  }

  Future<void> _checkAvailability() async {
    final notifier = ref.read(healthSyncProvider.notifier);
    final available = await notifier.isAvailable();
    if (mounted) {
      setState(() => _isAvailable = available);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hide entirely (including the section header) if the platform check
    // hasn't completed or no health platform is available
    if (_isAvailable != true) {
      return const SizedBox.shrink();
    }

    final syncState = ref.watch(healthSyncProvider);

    final i18n = AppLocalizations.of(context);

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
                    // null means the platform permissions were not granted
                    final count = await notifier.enableSync();
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

  /// Status line under the toggle: what the last sync did, a spinner while
  /// one is running, and tapping it starts one manually.
  Widget _statusTile(HealthSyncState syncState, AppLocalizations i18n) {
    final lastSync = syncState.lastSyncTime;
    return ListTile(
      leading: syncState.isSyncing
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          : const Icon(Icons.sync),
      title: Text(
        syncState.isSyncing
            ? i18n.healthSyncSyncing
            : lastSync != null
            ? i18n.healthSyncStatus(
                syncState.lastSyncCount,
                localizedDate(context).add_Hm().format(lastSync),
              )
            : i18n.healthSyncNow,
      ),
      subtitle: syncState.isSyncing || lastSync == null ? null : Text(i18n.healthSyncNow),
      enabled: !syncState.isSyncing,
      onTap: syncState.isSyncing
          ? null
          : () async {
              final count = await ref.read(healthSyncProvider.notifier).sync();
              // The status line already reflects "nothing new"; only actual
              // imports get a snackbar
              if (mounted && count > 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(i18n.healthSyncSuccess(count))),
                );
              }
            },
    );
  }
}
