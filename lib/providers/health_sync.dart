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

import 'dart:io';

import 'package:health/health.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/helpers/shared_preferences.dart';
import 'package:wger/models/body_weight/weight_entry.dart';
import 'package:wger/providers/base_provider.dart';
import 'package:wger/providers/wger_base_riverpod.dart';

part 'health_sync.g.dart';

class HealthSyncState {
  final bool isEnabled;
  final bool isSyncing;
  final int lastSyncCount;

  const HealthSyncState({
    this.isEnabled = false,
    this.isSyncing = false,
    this.lastSyncCount = 0,
  });

  HealthSyncState copyWith({
    bool? isEnabled,
    bool? isSyncing,
    int? lastSyncCount,
  }) {
    return HealthSyncState(
      isEnabled: isEnabled ?? this.isEnabled,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncCount: lastSyncCount ?? this.lastSyncCount,
    );
  }
}

const double kgToLb = 2.20462;

@Riverpod(keepAlive: true)
class HealthSyncNotifier extends _$HealthSyncNotifier {
  final _logger = Logger('HealthSyncNotifier');
  late final Health _health;
  late final WgerBaseProvider _baseProvider;

  static const _weightEntryUrl = 'weightentry';

  @override
  HealthSyncState build() {
    _health = Health();
    _baseProvider = ref.read(wgerBaseProvider);

    // Load persisted sync preference on startup
    _loadPersistedState();

    return const HealthSyncState();
  }

  Future<void> _loadPersistedState() async {
    final enabled = await PreferenceHelper.instance.getHealthSyncEnabled();
    if (enabled) {
      state = state.copyWith(isEnabled: true);
    }
  }

  /// Check if the health platform is available on this device
  Future<bool> isAvailable() async {
    if (Platform.isAndroid) {
      await _health.configure();
      final status = await _health.getHealthConnectSdkStatus();
      return status == HealthConnectSdkStatus.sdkAvailable;
    }
    // iOS always has HealthKit available
    return Platform.isIOS;
  }

  /// Enable health sync: request permissions, save preference, trigger initial sync.
  /// If [isMetric] is false, converts kg values from the health platform to lb before POSTing.
  Future<int> enableSync({bool isMetric = true}) async {
    _logger.info('Enabling health sync');

    await _health.configure();

    final authorized = await _health.requestAuthorization(
      [HealthDataType.WEIGHT],
      permissions: [HealthDataAccess.READ],
    );

    if (!authorized) {
      _logger.warning('Health permissions not granted');
      return 0;
    }

    await PreferenceHelper.instance.setHealthSyncEnabled(true);
    state = state.copyWith(isEnabled: true);

    return syncOnAppOpen(isMetric: isMetric);
  }

  /// Disable health sync: clear preferences
  Future<void> disableSync() async {
    _logger.info('Disabling health sync');
    await PreferenceHelper.instance.clearHealthSyncPreferences();
    state = const HealthSyncState();
  }

  /// Main sync method: read weight data from health platform, post new entries to backend.
  /// If [isMetric] is false, converts kg values from the health platform to lb before POSTing.
  Future<int> syncOnAppOpen({List<WeightEntry>? existingEntries, bool isMetric = true}) async {
    final prefs = PreferenceHelper.instance;
    final enabled = await prefs.getHealthSyncEnabled();
    if (!enabled) {
      return 0;
    }

    if (state.isSyncing) {
      return 0;
    }
    state = state.copyWith(isEnabled: true, isSyncing: true);

    try {
      await _health.configure();

      // Ensure we have permission to read weight data
      final hasPerms = await _health.hasPermissions(
        [HealthDataType.WEIGHT],
        permissions: [HealthDataAccess.READ],
      );
      if (hasPerms != true) {
        final authorized = await _health.requestAuthorization(
          [HealthDataType.WEIGHT],
          permissions: [HealthDataAccess.READ],
        );
        if (!authorized) {
          _logger.warning('Health permissions not granted during sync');
          state = state.copyWith(isSyncing: false);
          return 0;
        }
      }

      // Determine the start time for the query
      final lastSyncStr = await prefs.getLastHealthSyncTimestamp();
      final DateTime startTime;
      if (lastSyncStr != null) {
        startTime = DateTime.parse(lastSyncStr);
      } else {
        // Pull all available history on first sync
        startTime = DateTime(2000);
      }
      final endTime = DateTime.now();

      _logger.info('Syncing weight data from $startTime to $endTime');

      // Read weight data from health platform
      List<HealthDataPoint> dataPoints = await _health.getHealthDataFromTypes(
        types: [HealthDataType.WEIGHT],
        startTime: startTime,
        endTime: endTime,
      );
      dataPoints = _health.removeDuplicates(dataPoints);

      if (dataPoints.isEmpty) {
        _logger.info('No new weight data from health platform');
        state = state.copyWith(isSyncing: false, lastSyncCount: 0);
        return 0;
      }

      _logger.info('Found ${dataPoints.length} weight data points');

      // Build a Set of existing timestamps for O(1) dedup lookups
      final existingTimestamps = existingEntries != null
          ? {
              for (final e in existingEntries)
                DateTime(e.date.year, e.date.month, e.date.day, e.date.hour, e.date.minute),
            }
          : <DateTime>{};

      int syncedCount = 0;
      DateTime? latestSynced;

      for (final point in dataPoints) {
        try {
          final value = (point.value as NumericHealthValue).numericValue;
          final weightKg = value.toDouble();
          final timestamp = point.dateFrom;

          final weight = isMetric ? weightKg : weightKg * kgToLb;
          final weightRounded = (weight * 100).roundToDouble() / 100;

          // Skip if an entry with the same timestamp already exists locally
          final normalizedTimestamp = DateTime(
            timestamp.year,
            timestamp.month,
            timestamp.day,
            timestamp.hour,
            timestamp.minute,
          );
          if (existingTimestamps.contains(normalizedTimestamp)) {
            _logger.fine('Skipping duplicate entry for $timestamp');
            continue;
          }

          final entry = WeightEntry(weight: weightRounded, date: timestamp);
          await _baseProvider.post(
            entry.toJson(),
            _baseProvider.makeUrl(_weightEntryUrl),
          );

          syncedCount++;
          if (latestSynced == null || timestamp.isAfter(latestSynced)) {
            latestSynced = timestamp;
          }
        } catch (e) {
          _logger.warning('Failed to sync weight entry: $e');
          // Best-effort: continue with next entry
        }
      }

      // Update last sync timestamp to the latest successfully synced reading
      if (latestSynced != null) {
        await prefs.setLastHealthSyncTimestamp(latestSynced.toIso8601String());
      }

      _logger.info('Synced $syncedCount weight entries');
      state = state.copyWith(isSyncing: false, lastSyncCount: syncedCount);
      return syncedCount;
    } catch (e) {
      _logger.warning('Health sync failed: $e');
      state = state.copyWith(isSyncing: false, lastSyncCount: 0);
      return 0;
    }
  }
}
