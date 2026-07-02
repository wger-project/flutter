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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wger/features/account/providers/user_profile_notifier.dart';
import 'package:wger/features/weight/providers/health_sync.dart';
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
    // Hide entirely if platform check hasn't completed or is unavailable
    if (_isAvailable != true) {
      return const SizedBox.shrink();
    }

    final syncState = ref.watch(healthSyncProvider);

    final i18n = AppLocalizations.of(context);

    return SwitchListTile(
      title: Text(i18n.healthSync),
      subtitle: Text(i18n.healthSyncDescription),
      value: syncState.isEnabled,
      onChanged: syncState.isSyncing
          ? null
          : (enabled) async {
              final notifier = ref.read(healthSyncProvider.notifier);
              if (enabled) {
                final profile = ref.read(userProfileProvider).value;
                final isMetric = profile?.isMetric ?? true;
                final count = await notifier.enableSync(isMetric: isMetric);
                // Synced entries land in the local Drift DB and surface through
                // the weight stream automatically, so no manual refresh is needed.
                if (context.mounted && count > 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(i18n.healthSyncSuccess(count))),
                  );
                }
              } else {
                await notifier.disableSync();
              }
            },
    );
  }
}
