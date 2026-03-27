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
import 'package:wger/providers/health_sync.dart';

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
    if (_isAvailable == null || _isAvailable == false) {
      return const SizedBox.shrink();
    }

    final syncState = ref.watch(healthSyncProvider);

    return SwitchListTile(
      title: const Text('Health sync'),
      subtitle: const Text('Import weight from Apple Health or Health Connect'),
      value: syncState.isEnabled,
      onChanged: syncState.isSyncing
          ? null
          : (enabled) async {
              final notifier = ref.read(healthSyncProvider.notifier);
              if (enabled) {
                final count = await notifier.enableSync();
                if (context.mounted && count > 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Synced $count weight entries from Health')),
                  );
                }
              } else {
                await notifier.disableSync();
              }
            },
    );
  }
}
