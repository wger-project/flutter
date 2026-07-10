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

import 'package:collection/collection.dart';
import 'package:health_bridge/health.dart';
import 'package:logging/logging.dart';
import 'package:powersync/powersync.dart' as ps;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/core/shared_preferences.dart';
import 'package:wger/features/health/models/health_metric.dart';
import 'package:wger/features/health/providers/health_repository.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';
import 'package:wger/features/measurements/providers/measurement_repository.dart';

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

  HealthSyncState copyWith({bool? isEnabled, bool? isSyncing, int? lastSyncCount}) {
    return HealthSyncState(
      isEnabled: isEnabled ?? this.isEnabled,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncCount: lastSyncCount ?? this.lastSyncCount,
    );
  }
}

/// Imports body metrics from Apple Health / Health Connect into measurement
/// categories. Read-only: reads the platform (via [HealthRepository]), writes to
/// the local Drift DB, and lets PowerSync push the rows up. Re-imports are
/// deduplicated via each measurement's [MeasurementEntry.externalId] (the
/// platform record UUID).
@Riverpod(keepAlive: true)
class HealthSyncNotifier extends _$HealthSyncNotifier {
  /// How far the read window reaches back before the last-sync watermark, to
  /// pick up records that arrived late with a past date.
  static const _syncOverlap = Duration(days: 30);

  final _logger = Logger('HealthSyncNotifier');
  late final HealthRepository _health;
  late final MeasurementRepository _measurements;

  List<HealthDataType> get _types => enabledHealthMetrics.map((m) => m.dataType).toList();

  @override
  HealthSyncState build() {
    _health = ref.read(healthRepositoryProvider);
    _measurements = ref.read(measurementRepositoryProvider);
    _loadPersistedState();
    return const HealthSyncState();
  }

  Future<void> _loadPersistedState() async {
    if (await PreferenceHelper.instance.getHealthSyncEnabled()) {
      state = state.copyWith(isEnabled: true);
    }
  }

  /// Whether a health platform is available on this device.
  Future<bool> isAvailable() => _health.isAvailable();

  /// Requests permissions, persists the preference, and runs an initial import.
  Future<int> enableSync() async {
    _logger.info('Enabling health sync');
    if (!await _health.ensureAuthorized(_types)) {
      return 0;
    }
    await PreferenceHelper.instance.setHealthSyncEnabled(true);
    state = state.copyWith(isEnabled: true);
    return syncOnAppOpen();
  }

  /// Clears the preference and disables importing.
  Future<void> disableSync() async {
    _logger.info('Disabling health sync');
    await PreferenceHelper.instance.clearHealthSyncPreferences();
    state = const HealthSyncState();
  }

  /// Reads the enabled metrics from the health platform and writes any new
  /// readings to the matching measurement categories. Returns the number of
  /// imported entries. A no-op unless the user enabled sync.
  Future<int> syncOnAppOpen() async {
    final prefs = PreferenceHelper.instance;
    if (!await prefs.getHealthSyncEnabled()) {
      return 0;
    }
    if (state.isSyncing) {
      return 0;
    }
    state = state.copyWith(isEnabled: true, isSyncing: true);

    try {
      if (!await _health.ensureAuthorized(_types)) {
        _logger.warning('Health permissions not granted during sync');
        state = state.copyWith(isSyncing: false);
        return 0;
      }

      // Health records can arrive late with past dates (e.g. a scale that
      // only syncs days after the measurement), so the read window reaches
      // back beyond the watermark; re-reads are deduplicated via externalId.
      final lastSyncStr = await prefs.getLastHealthSyncTimestamp();
      final startTime = lastSyncStr != null
          ? DateTime.parse(lastSyncStr).subtract(_syncOverlap)
          : DateTime(2000);
      final endTime = DateTime.now();
      _logger.info('Syncing health data from $startTime to $endTime');

      final readings = await _health.read(types: _types, start: startTime, end: endTime);
      if (readings.isEmpty) {
        _logger.info('No new health data');
        state = state.copyWith(isSyncing: false, lastSyncCount: 0);
        return 0;
      }

      final categories = await _measurements.getAllOnce();
      final source = _health.sourceName;
      var synced = 0;
      DateTime? latest;

      for (final metric in enabledHealthMetrics) {
        final metricReadings = readings.where((r) => r.type == metric.dataType);
        if (metricReadings.isEmpty) {
          continue;
        }

        final category = await _findOrCreateCategory(metric, categories);
        final seen = {
          for (final e in category.entries)
            if (e.externalId != null) e.externalId!,
        };

        for (final reading in metricReadings) {
          final uuid = reading.externalId;
          if (uuid != null && seen.contains(uuid)) {
            continue;
          }

          // The server stores values as Decimal with 2 places and rejects
          // anything more precise, so round away unit-conversion float noise
          // (1.803 m * 100 = 180.29999999999998).
          final value = (metric.toCategoryValue(reading.value) * 100).roundToDouble() / 100;

          await _measurements.addLocalDrift(
            MeasurementEntry(
              categoryId: category.id!,
              date: reading.date,
              value: value,
              notes: '',
              source: source,
              externalId: uuid,
            ),
          );

          if (uuid != null) {
            seen.add(uuid);
          }
          synced++;
          if (latest == null || reading.date.isAfter(latest)) {
            latest = reading.date;
          }
        }
      }

      if (latest != null) {
        await prefs.setLastHealthSyncTimestamp(latest.toIso8601String());
      }
      _logger.info('Imported $synced health measurements');
      state = state.copyWith(isSyncing: false, lastSyncCount: synced);
      return synced;
    } catch (e) {
      _logger.warning('Health sync failed: $e');
      state = state.copyWith(isSyncing: false, lastSyncCount: 0);
      return 0;
    }
  }

  /// Finds the category for [metric] (by `metric_type`, falling back to the
  /// canonical name to reuse a matching category the user created by hand) or
  /// creates it. The created category is appended to [categories] so a later
  /// metric in the same run reuses it.
  Future<MeasurementCategory> _findOrCreateCategory(
    HealthMetric metric,
    List<MeasurementCategory> categories,
  ) async {
    final existing = categories.firstWhereOrNull(
      (c) => c.metricType == metric.metricType || c.name == metric.canonicalName,
    );
    if (existing != null) {
      return existing;
    }

    final category = MeasurementCategory(
      id: ps.uuid.v7(),
      name: metric.canonicalName,
      unit: metric.unit,
      metricType: metric.metricType,
    );
    await _measurements.addLocalDriftCategory(category);
    categories.add(category);
    return category;
  }
}
