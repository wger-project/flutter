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
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:health_bridge/health.dart';
import 'package:logging/logging.dart';
import 'package:powersync/powersync.dart' as ps;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/core/shared_preferences.dart';
import 'package:wger/features/health/models/health_metric.dart';
import 'package:wger/features/health/models/health_reading.dart';
import 'package:wger/features/health/providers/health_repository.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';
import 'package:wger/features/measurements/models/unit_conversion.dart';
import 'package:wger/features/measurements/providers/measurement_repository.dart';

part 'health_sync.freezed.dart';
part 'health_sync.g.dart';

@freezed
sealed class HealthSyncState with _$HealthSyncState {
  const factory HealthSyncState({
    @Default(false) bool isEnabled,
    @Default(false) bool isSyncing,
    @Default(0) int lastSyncCount,
  }) = _HealthSyncState;
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

  List<HealthDataType> get _types => enabledHealthMetrics.expand((m) => m.dataTypes).toList();

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
  ///
  /// Returns the number of imported entries, or `null` when the platform
  /// permissions were not granted (sync stays disabled).
  Future<int?> enableSync() async {
    _logger.info('Enabling health sync');
    if (!await _health.ensureAuthorized(_types)) {
      return null;
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
      var skippedMetric = false;
      DateTime? latest;

      for (final metric in enabledHealthMetrics) {
        // Pair each target category with the readings it receives: the metric's
        // own category, or one child per component for a group metric.
        final List<(MeasurementCategory, Iterable<HealthReading>)> targets;
        if (metric.components.isEmpty) {
          final metricReadings = readings.where((r) => r.type == metric.dataType);
          if (metricReadings.isEmpty) {
            continue;
          }
          final category = await _findOrCreateCategory(metric, categories);
          if (category == null) {
            skippedMetric = true;
            continue;
          }
          targets = [(category, metricReadings)];
        } else {
          final byComponent = [
            for (final component in metric.components)
              readings.where((r) => r.type == component.dataType),
          ];
          if (byComponent.every((r) => r.isEmpty)) {
            continue;
          }
          final children = await _findOrCreateGroupChildren(metric, categories);
          if (children == null) {
            skippedMetric = true;
            continue;
          }
          targets = [for (var i = 0; i < children.length; i++) (children[i], byComponent[i])];
        }

        for (final (category, metricReadings) in targets) {
          final (importedCount, newest) = await _importReadings(
            metric,
            metricReadings,
            category,
            source,
          );
          synced += importedCount;
          if (newest != null && (latest == null || newest.isAfter(latest))) {
            latest = newest;
          }
        }
      }

      // Advancing the watermark past readings a skipped metric could not
      // import would push them out of the overlap window for good, so keep
      // the old one until every metric got its category.
      if (latest != null && !skippedMetric) {
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

  /// Imports [metricReadings] into [category], deduplicating against the
  /// entries already present via their externalId. Returns the number of
  /// imported entries and the newest imported reading date.
  Future<(int, DateTime?)> _importReadings(
    HealthMetric metric,
    Iterable<HealthReading> metricReadings,
    MeasurementCategory category,
    String source,
  ) async {
    final seen = {
      for (final e in category.entries)
        if (e.externalId != null) e.externalId!,
    };
    var synced = 0;
    DateTime? latest;

    for (final reading in metricReadings) {
      final uuid = reading.externalId;
      if (uuid != null && seen.contains(uuid)) {
        continue;
      }

      // Body weight is stored in kg. Should a platform report it in
      // pounds, convert and keep the original for provenance.
      var raw = reading.value;
      String? sourceUnit;
      if (metric.metricType == MetricType.bodyWeight && reading.unit == HealthDataUnit.POUND) {
        sourceUnit = 'lb';
        raw = convertWeight(reading.value, from: 'lb', to: 'kg');
      }

      final converted = metric.toCategoryValue(raw);
      // The server stores values as Decimal with 2 places and rejects
      // anything more precise, so round away unit-conversion float noise
      // (1.803 m * 100 = 180.29999999999998).
      final value = (converted * 100).roundToDouble() / 100;

      await _measurements.addLocalDrift(
        MeasurementEntry(
          categoryId: category.id!,
          date: reading.date,
          value: value,
          notes: '',
          source: source,
          externalId: uuid,
          extraData: _extraDataFor(
            metric,
            reading,
            converted: sourceUnit != null || converted != reading.value,
            sourceUnit: sourceUnit,
          ),
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
    return (synced, latest);
  }

  /// Builds an imported entry's `extra_data` from the reading's provenance.
  ///
  /// `unit` is the only key with server semantics (kg|lb, validated for body
  /// weight); the rest is provenance for debugging and later duplicate
  /// detection. Keys without a value are omitted, never written as null.
  /// [converted] marks readings whose stored value differs from the platform
  /// value; the original is then kept in `source_value` (and `source_unit`
  /// when the difference is a weight-unit conversion).
  Map<String, dynamic> _extraDataFor(
    HealthMetric metric,
    HealthReading reading, {
    required bool converted,
    String? sourceUnit,
  }) {
    return {
      if (metric.metricType == MetricType.bodyWeight) 'unit': 'kg',
      if (reading.dateTo != null) 'date_to': reading.dateTo!.toIso8601String(),
      'recording_method': reading.recordingMethod.name,
      'record_type': reading.type.name,
      if (reading.sourceName != null) 'source_name': reading.sourceName,
      if (reading.sourceId != null) 'source_id': reading.sourceId,
      if (reading.deviceModel != null) 'device_model': reading.deviceModel,
      if (reading.sourceDeviceId != null) 'source_device_id': reading.sourceDeviceId,
      if (converted) 'source_value': reading.value,
      'source_unit': ?sourceUnit,
    };
  }

  /// Finds the category for [metric] (by `metric_type`, falling back to the
  /// canonical name to reuse a matching category the user created by hand) or
  /// creates it. The created category is appended to [categories] so a later
  /// metric in the same run reuses it.
  ///
  /// Body weight is the exception: it goes only into the official category,
  /// which the server creates for every user. It is never created here;
  /// returns `null` (skip the metric) while the initial sync has not
  /// delivered it yet.
  Future<MeasurementCategory?> _findOrCreateCategory(
    HealthMetric metric,
    List<MeasurementCategory> categories,
  ) async {
    if (metric.metricType == MetricType.bodyWeight) {
      final official = categories.firstWhereOrNull((c) => c.isOfficialBodyWeight);
      if (official == null) {
        _logger.info('Official body weight category not synced yet, skipping weight import');
      }
      return official;
    }

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

  /// Finds the child categories a group metric imports into, one per
  /// component matched by in-group position, creating the group and any
  /// missing children as needed. Returns `null` (skip the metric) when the
  /// matching category holds entries itself: the server allows measurements
  /// only on leaves, so attaching children would make its rows invalid.
  Future<List<MeasurementCategory>?> _findOrCreateGroupChildren(
    HealthMetric metric,
    List<MeasurementCategory> categories,
  ) async {
    final existing = categories.firstWhereOrNull(
      (c) =>
          c.parentId == null &&
          (c.metricType == metric.metricType || c.name == metric.canonicalName),
    );
    if (existing != null && existing.entries.isNotEmpty) {
      _logger.warning(
        'Category "${existing.name}" holds entries itself and cannot become '
        'a ${metric.metricType.name} group, skipping the import',
      );
      return null;
    }

    final parent =
        existing ??
        MeasurementCategory(
          id: ps.uuid.v7(),
          name: metric.canonicalName,
          unit: metric.unit,
          metricType: metric.metricType,
        );
    if (existing == null) {
      await _measurements.addLocalDriftCategory(parent);
      categories.add(parent);
    }

    final children = categories
        .where((c) => c.parentId == parent.id)
        .sortedBy<num>((c) => c.order)
        .toList();
    final result = <MeasurementCategory>[];
    for (var i = 0; i < metric.components.length; i++) {
      if (i < children.length) {
        result.add(children[i]);
        continue;
      }
      final child = MeasurementCategory(
        id: ps.uuid.v7(),
        name: metric.components[i].canonicalName,
        unit: metric.unit,
        parentId: parent.id,
        order: i,
      );
      await _measurements.addLocalDriftCategory(child);
      categories.add(child);
      result.add(child);
    }
    return result;
  }
}
