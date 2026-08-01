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
import 'package:flutter/widgets.dart' show AppLifecycleListener;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:health_bridge/health.dart';
import 'package:logging/logging.dart';
import 'package:powersync/powersync.dart' as ps;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/core/consts.dart';
import 'package:wger/core/network/auth_credentials_storage.dart';
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

final _uuidPattern = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$');

/// Stable id identifying the aggregate of [day] within [categoryId].
///
/// Deterministic, so re-reading a day within the overlap window updates the
/// same entry instead of adding a second one. It has to be a real UUID rather
/// than a readable `day-<date>` key, because the server stores `external_id`
/// as a UUIDField and rejects anything else permanently. The category id is
/// itself a UUID and serves as the v5 namespace, which is exactly the
/// "day X within category Y" relationship the id expresses.
String dailyAggregateExternalId(String categoryId, DateTime day) =>
    ps.uuid.v5(categoryId, DateFormatLists.format(day));

/// Why the last sync did not deliver, if it didn't.
enum HealthSyncIssue {
  /// The platform refuses to hand over data. Either the permissions were
  /// declined, or they were never actually granted to this installation
  /// (see [HealthRepository.isAuthorizationMissing]). Recoverable by asking
  /// for them again, which needs the user to start it.
  permissionsMissing,

  /// The import failed for another reason; the details are in the log.
  failed,
}

@freezed
sealed class HealthSyncState with _$HealthSyncState {
  const factory HealthSyncState({
    @Default(false) bool isEnabled,
    @Default(false) bool isSyncing,
    @Default(0) int lastSyncCount,

    /// When the last successful sync finished; null until one succeeded in
    /// this session.
    DateTime? lastSyncTime,

    /// What went wrong during the last sync, null when it went through.
    HealthSyncIssue? issue,
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

  /// Minimum pause between the automatic re-syncs on app resume.
  static const _resumeThrottle = Duration(minutes: 15);

  final _logger = Logger('HealthSyncNotifier');
  late final HealthRepository _health;
  late final MeasurementRepository _measurements;

  /// Platform record ids folded into a UUID during the running sync, see
  /// [_externalIdFor]. Expected to stay 0; anything else means a platform
  /// changed its id format under us.
  var _normalizedIdCount = 0;

  List<HealthDataType> get _types => enabledHealthMetrics.expand((m) => m.dataTypes).toList();

  @override
  HealthSyncState build() {
    _health = ref.read(healthRepositoryProvider);
    _measurements = ref.read(measurementRepositoryProvider);
    _loadPersistedState();

    // New readings often exist exactly when the app comes back from the
    // background (the user just weighed in, granted permissions, ...), so
    // resume triggers a sync as well, throttled to stay unobtrusive
    final lifecycleListener = AppLifecycleListener(
      onResume: () {
        final last = state.lastSyncTime;
        if (last == null || DateTime.now().difference(last) >= _resumeThrottle) {
          sync();
        }
      },
    );
    ref.onDispose(lifecycleListener.dispose);

    return const HealthSyncState();
  }

  Future<void> _loadPersistedState() async {
    if (await PreferenceHelper.instance.getHealthSyncEnabled()) {
      state = state.copyWith(isEnabled: true);
    }
  }

  /// Whether a health platform is available on this device.
  Future<bool> isAvailable() => _health.isAvailable();

  /// How usable the device's health platform is, so the settings can offer
  /// installing or updating Health Connect instead of hiding the feature.
  Future<HealthPlatformAvailability> availability() => _health.availability();

  /// Sends the user to the store page for Health Connect. Android only.
  Future<void> openHealthConnectInstall() => _health.openHealthConnectInstall();

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
    return sync();
  }

  /// Asks the platform for the permissions again and retries the import.
  ///
  /// For [HealthSyncIssue.permissionsMissing]: this shows the platform dialog,
  /// so it belongs behind a user action, unlike the automatic [sync].
  /// Returns the number of imported entries, or `null` when access was again
  /// not granted.
  Future<int?> retryWithPermissions() async {
    _logger.info('Re-requesting health permissions');
    if (!await _health.ensureAuthorized(_types)) {
      state = state.copyWith(issue: HealthSyncIssue.permissionsMissing);
      return null;
    }
    return sync();
  }

  /// Clears the preference and disables importing.
  ///
  /// The sync watermark goes with it, so switching back on re-reads the full
  /// history. That is slower but never leaves a hole: everything recorded
  /// while the sync was off would otherwise stay outside the read window
  /// forever. Re-reads are deduplicated via externalId.
  Future<void> disableSync() async {
    _logger.info('Disabling health sync');
    await PreferenceHelper.instance.clearHealthSyncPreferences();
    state = const HealthSyncState();
  }

  /// Reads the enabled metrics from the health platform and writes any new
  /// readings to the matching measurement categories. Returns the number of
  /// imported entries. A no-op unless the user enabled sync. Triggered on app
  /// open, on app resume, and manually from the settings.
  Future<int> sync() async {
    final prefs = PreferenceHelper.instance;
    if (!await prefs.getHealthSyncEnabled()) {
      return 0;
    }
    if (state.isSyncing) {
      return 0;
    }
    state = state.copyWith(isEnabled: true, isSyncing: true, issue: null);
    _normalizedIdCount = 0;

    try {
      // Checked silently, never requested: this runs on app open and resume,
      // where a permission dialog would come out of nowhere. Asking again is
      // the user's call, see [retryWithPermissions].
      if (await _health.isAuthorizationKnownMissing(_types)) {
        _logger.warning('Health permissions not granted, skipping sync');
        state = state.copyWith(isSyncing: false, issue: HealthSyncIssue.permissionsMissing);
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
        state = state.copyWith(isSyncing: false, lastSyncCount: 0, lastSyncTime: DateTime.now());
        return 0;
      }

      // The ids of the typed categories are derived from the user, see
      // [deterministicCategoryId]. Without one nothing could be created that
      // another device would recognise as the same category
      final userId = await ref.read(authCredentialsStorageProvider).dbOwnerUserId();
      if (userId == null) {
        _logger.warning('Local database has no owner, skipping health sync');
        state = state.copyWith(isSyncing: false, issue: HealthSyncIssue.failed);
        return 0;
      }

      final categories = await _measurements.getAllOnce();
      final source = _health.sourceName;
      var synced = 0;
      var skippedMetric = false;
      var failedMetric = false;
      DateTime? latest;

      for (final metric in enabledHealthMetrics) {
        // One bad metric must not cost the others their import, and the
        // watermark has to stay put for whatever it could not write
        try {
          // Pair each target category with the readings it receives: the metric's
          // own category, or one child per component for a group metric.
          final List<(MeasurementCategory, Iterable<HealthReading>)> targets;
          if (metric.components.isEmpty) {
            final metricReadings = readings.where((r) => r.type == metric.dataType);
            if (metricReadings.isEmpty) {
              continue;
            }
            final category = await _findOrCreateCategory(metric, categories, userId);
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
            final children = await _findOrCreateGroupChildren(metric, categories, userId);
            if (children == null) {
              skippedMetric = true;
              continue;
            }
            targets = [for (var i = 0; i < children.length; i++) (children[i], byComponent[i])];
          }

          for (final (category, metricReadings) in targets) {
            final (importedCount, newest) = metric.dailyAggregation != null
                ? await _importDailyAggregates(metric, metricReadings, category, source)
                : await _importReadings(metric, metricReadings, category, source);
            synced += importedCount;
            if (newest != null && (latest == null || newest.isAfter(latest))) {
              latest = newest;
            }
          }
        } catch (e, s) {
          _logger.severe('Importing ${metric.metricType.name} failed', e, s);
          skippedMetric = true;
          failedMetric = true;
        }
      }

      // Advancing the watermark past readings a skipped metric could not
      // import would push them out of the overlap window for good, so keep
      // the old one until every metric got its category. A reading dated in
      // the future (a device with a wrong clock) must not drag the watermark
      // along with it either, or everything recorded until that date is
      // skipped on the next run.
      if (latest != null && !skippedMetric) {
        final watermark = latest.isAfter(endTime) ? endTime : latest;
        await prefs.setLastHealthSyncTimestamp(watermark.toIso8601String());
      }
      if (_normalizedIdCount > 0) {
        _logger.warning(
          'Folded $_normalizedIdCount platform record ids into UUIDs during this sync',
        );
      }
      _logger.info('Imported $synced health measurements');
      state = state.copyWith(
        isSyncing: false,
        lastSyncCount: synced,
        lastSyncTime: DateTime.now(),
        issue: failedMetric ? HealthSyncIssue.failed : null,
      );
      return synced;
    } catch (e, s) {
      // A read the platform refuses for lack of permissions is the one
      // permission problem iOS reports at all, so it is worth telling apart
      // from a genuine failure: the user can fix it by granting access again.
      final missing = HealthRepository.isAuthorizationMissing(e);
      if (missing) {
        _logger.warning('Health sync stopped, the platform reports no authorization', e);
      } else {
        _logger.severe('Health sync failed', e, s);
      }
      state = state.copyWith(
        isSyncing: false,
        lastSyncCount: 0,
        issue: missing ? HealthSyncIssue.permissionsMissing : HealthSyncIssue.failed,
      );
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
      final uuid = _externalIdFor(reading.externalId, category.id!);
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
            // Only set when the platform id had to be folded into a UUID
            sourceRecordId: uuid == reading.externalId ? null : reading.externalId,
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

  /// Imports [metricReadings] as one entry per day, condensed per the metric's
  /// [HealthMetric.dailyAggregation]. Days are keyed by
  /// [dailyAggregateExternalId], so a re-read within the overlap window updates
  /// the aggregate in place when late samples change it (the current day keeps
  /// growing until it ends). The entry's date is the start of that day; for
  /// metrics that roll over (sleep) the samples' real window is kept in
  /// extra_data. Returns the number of written entries and the newest
  /// processed sample date.
  Future<(int, DateTime?)> _importDailyAggregates(
    HealthMetric metric,
    Iterable<HealthReading> metricReadings,
    MeasurementCategory category,
    String source,
  ) async {
    var synced = 0;
    DateTime? latest;
    final byDay = groupBy(metricReadings, (r) => _dayOf(r.date, metric));

    for (final MapEntry(key: day, value: samples) in byDay.entries) {
      final values = samples.map((r) => metric.toCategoryValue(r.value)).toList();
      final aggregate = switch (metric.dailyAggregation!) {
        DailyAggregation.average => values.average,
        DailyAggregation.sum => values.sum,
      };
      // Round like the raw import: the server stores Decimal with 2 places
      final value = (aggregate * 100).roundToDouble() / 100;
      final extraData = <String, dynamic>{
        if (metric.dailyAggregation == DailyAggregation.average) ...{
          'min': values.min,
          'max': values.max,
        },
        'sample_count': values.length,
        'record_type': metric.dataType.name,
        // A rolled-over day is not the samples' calendar day, so keep the
        // window they actually cover
        if (metric.dayRollsOverAtHour != null) ...{
          'date_from': samples.map((r) => r.date).reduce(_earlier).toIso8601String(),
          'date_to': samples.map((r) => r.dateTo ?? r.date).reduce(_later).toIso8601String(),
        },
      };

      final externalId = dailyAggregateExternalId(category.id!, day);
      final existing = category.entries.firstWhereOrNull((e) => e.externalId == externalId);
      if (existing == null) {
        await _measurements.addLocalDrift(
          MeasurementEntry(
            categoryId: category.id!,
            date: day,
            value: value,
            notes: '',
            source: source,
            externalId: externalId,
            extraData: extraData,
          ),
        );
        synced++;
      } else if (existing.value != value ||
          !const MapEquality<String, dynamic>().equals(existing.extraData, extraData)) {
        await _measurements.updateLocalDrift(existing.copyWith(value: value, extraData: extraData));
        synced++;
      }

      for (final sample in samples) {
        if (latest == null || sample.date.isAfter(latest)) {
          latest = sample.date;
        }
      }
    }
    return (synced, latest);
  }

  /// The day a sample is attributed to. Plain calendar day, unless the metric
  /// rolls over: samples at or after [HealthMetric.dayRollsOverAtHour] then
  /// count towards the next day, so a night of sleep lands on the day the user
  /// wakes up instead of being split at midnight.
  DateTime _dayOf(DateTime date, HealthMetric metric) {
    final day = DateTime(date.year, date.month, date.day);
    final rollover = metric.dayRollsOverAtHour;
    return rollover != null && date.hour >= rollover ? day.add(const Duration(days: 1)) : day;
  }

  static DateTime _earlier(DateTime a, DateTime b) => a.isBefore(b) ? a : b;

  static DateTime _later(DateTime a, DateTime b) => a.isAfter(b) ? a : b;

  /// Builds an imported entry's `extra_data` from the reading's provenance.
  ///
  /// `unit` is the only key with server semantics (kg|lb, validated for body
  /// weight); the rest is provenance for debugging and later duplicate
  /// detection. Keys without a value are omitted, never written as null.
  /// [converted] marks readings whose stored value differs from the platform
  /// value; the original is then kept in `source_value` (and `source_unit`
  /// when the difference is a weight-unit conversion). [sourceRecordId] is the
  /// platform's own record id, kept when it had to be folded into a UUID.
  Map<String, dynamic> _extraDataFor(
    HealthMetric metric,
    HealthReading reading, {
    required bool converted,
    String? sourceUnit,
    String? sourceRecordId,
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
      'source_record_id': ?sourceRecordId,
    };
  }

  /// The id stored in `external_id` for a platform record.
  ///
  /// The server's `external_id` is a UUIDField and rejects anything else
  /// permanently, but Health Connect documents `Metadata.id` only as a
  /// platform-assigned String. Ids that are not UUIDs are therefore folded
  /// into one deterministically (same scheme as the daily aggregates, so the
  /// mapping is stable across syncs and dedup keeps working); the original is
  /// kept in `extra_data.source_record_id`, which is what a later delete-sync
  /// via `deleteByUUID` needs.
  String? _externalIdFor(String? platformId, String categoryId) {
    if (platformId == null || _uuidPattern.hasMatch(platformId)) {
      return platformId;
    }
    if (_normalizedIdCount == 0) {
      _logger.warning(
        'Health platform returned a record id that is not a UUID ("$platformId"). '
        'Folding it into one so the entry can sync; see extra_data.source_record_id',
      );
    }
    _normalizedIdCount++;
    return ps.uuid.v5(categoryId, platformId);
  }

  /// Finds the category for [metric] by its `metric_type`, or creates it. The
  /// created category is appended to [categories] so a later metric in the same
  /// run reuses it.
  ///
  /// Matching by name as well was dropped deliberately: it hit any hand-made
  /// category that happened to be called like the metric in English and missed
  /// it in every other language, so the target depended on the UI language.
  /// Adopting an existing category is done by giving it the metric type.
  ///
  /// Body weight is the exception: it goes only into the official category,
  /// which the server creates for every user. It is never created here;
  /// returns `null` (skip the metric) while the initial sync has not
  /// delivered it yet.
  Future<MeasurementCategory?> _findOrCreateCategory(
    HealthMetric metric,
    List<MeasurementCategory> categories,
    String userId,
  ) async {
    if (metric.metricType == MetricType.bodyWeight) {
      final official = categories.firstWhereOrNull((c) => c.isOfficialBodyWeight);
      if (official == null) {
        _logger.info('Official body weight category not synced yet, skipping weight import');
      }
      return official;
    }

    final existing = categories.firstWhereOrNull((c) => c.metricType == metric.metricType);
    if (existing != null) {
      return existing;
    }

    final category = MeasurementCategory(
      id: deterministicCategoryId(userId, metric.metricType),
      name: metric.canonicalName,
      unit: metric.unit,
      metricType: metric.metricType,
    );
    await _measurements.addLocalDriftCategory(category);
    categories.add(category);
    return category;
  }

  /// Finds the child categories a group metric imports into, one per
  /// component matched by its own metric type, creating the group and any
  /// missing children as needed. Returns `null` (skip the metric) when the
  /// matching category holds entries itself: the server allows measurements
  /// only on leaves, so attaching children would make its rows invalid.
  Future<List<MeasurementCategory>?> _findOrCreateGroupChildren(
    HealthMetric metric,
    List<MeasurementCategory> categories,
    String userId,
  ) async {
    final existing = categories.firstWhereOrNull(
      (c) => c.parentId == null && c.metricType == metric.metricType,
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
          id: deterministicCategoryId(userId, metric.metricType),
          name: metric.canonicalName,
          unit: metric.unit,
          metricType: metric.metricType,
        );
    if (existing == null) {
      await _measurements.addLocalDriftCategory(parent);
      categories.add(parent);
    }

    // The component categories come from the metric type, in the same order as
    // the metric's health data types, so the caller can pair them by index.
    // The server creates them on the very same ids when it sees the group
    final result = <MeasurementCategory>[];
    for (final (order, (metricType, name)) in metric.metricType.components.indexed) {
      final existingChild = categories.firstWhereOrNull(
        (c) => c.parentId == parent.id && c.metricType == metricType,
      );
      if (existingChild != null) {
        result.add(existingChild);
        continue;
      }
      final child = MeasurementCategory(
        id: deterministicCategoryId(userId, metricType),
        name: name,
        unit: metric.unit,
        metricType: metricType,
        parentId: parent.id,
        order: order,
      );
      await _measurements.addLocalDriftCategory(child);
      categories.add(child);
      result.add(child);
    }
    return result;
  }
}
