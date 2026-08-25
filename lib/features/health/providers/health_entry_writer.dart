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
import 'package:wger/features/health/models/daily_windows.dart';
import 'package:wger/features/health/models/health_metric.dart';
import 'package:wger/features/health/models/health_reading.dart';
import 'package:wger/features/health/providers/health_importer.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';
import 'package:wger/features/measurements/models/unit_conversion.dart';
import 'package:wger/features/measurements/providers/measurement_repository.dart';

final _uuidPattern = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$');

/// Turns the readings of one sync into measurement entries: one per reading,
/// or one per day for the metrics that aggregate.
///
/// Owns the categories they are written into (see [resolveTargets]) and the
/// two counters a run reports at the end. Created per run, since both are
/// about that run.
class HealthEntryWriter {
  HealthEntryWriter(this._measurements, this._source);

  final MeasurementRepository _measurements;

  /// The measurement `source` of this platform (`apple`, `google`)
  final String _source;

  final _logger = Logger('HealthEntryWriter');

  /// Platform record ids folded into a UUID during this run, see
  /// [_externalIdFor]. Expected to stay 0; anything else means a platform
  /// changed its id format under us.
  var normalizedIdCount = 0;

  /// Readings dropped during this run because their value is outside what its
  /// metric type allows, see [_isInRange].
  var outOfRangeCount = 0;

  /// Imports [metricReadings] into [target]'s category, deduplicating against
  /// the entries already present via their externalId. Returns the number of
  /// imported entries.
  Future<int> importReadings(
    HealthMetric metric,
    Iterable<HealthReading> metricReadings,
    ImportTarget target,
  ) async {
    final category = target.category;
    final seen = target.seen!;
    var synced = 0;

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

      if (_isInRange(value, category, metric)) {
        await _measurements.addLocalDrift(
          MeasurementEntry(
            categoryId: category.id!,
            date: reading.date,
            value: value,
            notes: '',
            source: _source,
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
      }
    }
    return synced;
  }

  /// Sorts [metricReadings] into the days they belong to and writes every day
  /// no later window can add samples to; the rest waits in [target]'s pending
  /// days until [flushPendingDays]. Returns the number of written entries.
  Future<int> collectDailyAggregates(
    HealthMetric metric,
    Iterable<HealthReading> metricReadings,
    ImportTarget target,
    DateTime windowEnd,
  ) async {
    for (final reading in metricReadings) {
      target.pending.putIfAbsent(dayOf(reading.date, metric), () => []).add(reading);
    }

    var synced = 0;
    // The windows only move forward, so a day that ends at or before this
    // window's end is complete and can stop holding its samples
    for (final day in target.pending.keys.toList()) {
      if (!dayEnd(day, metric).isAfter(windowEnd)) {
        synced += await _writeDailyAggregate(metric, day, target.pending.remove(day)!, target);
      }
    }
    return synced;
  }

  /// Writes the days still pending once the metric's read is complete: the
  /// newest one is usually among them, still growing while its day runs.
  Future<int> flushPendingDays(HealthMetric metric, ImportTarget target) async {
    var synced = 0;
    for (final day in target.pending.keys.toList()) {
      synced += await _writeDailyAggregate(metric, day, target.pending.remove(day)!, target);
    }
    return synced;
  }

  /// Writes [samples] as the one entry of [day], condensed per the metric's
  /// [HealthMetric.dailyAggregation]. Days are keyed by
  /// [dailyAggregateExternalId], so a re-read within the overlap window updates
  /// the aggregate in place when late samples change it (the current day keeps
  /// growing until it ends). The entry's date is the start of that day; for
  /// metrics that roll over (sleep) the samples' real window is kept in
  /// extra_data. Returns the number of written entries.
  Future<int> _writeDailyAggregate(
    HealthMetric metric,
    DateTime day,
    List<HealthReading> samples,
    ImportTarget target,
  ) async {
    final category = target.category;
    final values = samples.map((r) => metric.toCategoryValue(r.value)).toList();
    final aggregate = switch (metric.dailyAggregation!) {
      DailyAggregation.average => values.average,
      DailyAggregation.sum => values.sum,
      DailyAggregation.mergedDuration => mergedDurationMinutes(samples),
    };
    // Round like the raw import: the server stores Decimal with 2 places
    final value = (aggregate * 100).roundToDouble() / 100;
    final extraData = <String, dynamic>{
      if (metric.dailyAggregation == DailyAggregation.average) ...{
        'min': values.min,
        'max': values.max,
      },
      'sample_count': values.length,
      // The types actually seen, not the metric's own: a component can roll
      // several of them up (total sleep)
      'record_type': (samples.map((r) => r.type.name).toSet().toList()..sort()).join(','),
      // A rolled-over day is not the samples' calendar day, so keep the
      // window they actually cover
      if (metric.dayRollsOverAtHour != null) ...{
        'date_from': samples.map((r) => r.date).reduce(earlier).toIso8601String(),
        'date_to': samples.map((r) => r.dateTo ?? r.date).reduce(later).toIso8601String(),
      },
    };

    if (!_isInRange(value, category, metric)) {
      return 0;
    }
    final externalId = dailyAggregateExternalId(category.id!, day);
    final existing = target.stored![externalId];
    if (existing == null) {
      await _measurements.addLocalDrift(
        MeasurementEntry(
          categoryId: category.id!,
          date: day,
          value: value,
          notes: '',
          source: _source,
          externalId: externalId,
          extraData: extraData,
        ),
      );
      return 1;
    }
    if (existing.value != value ||
        !const MapEquality<String, dynamic>().equals(existing.extraData, extraData)) {
      await _measurements.updateLocalDrift(existing.copyWith(value: value, extraData: extraData));
      return 1;
    }
    return 0;
  }

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
    if (normalizedIdCount == 0) {
      _logger.warning(
        'Health platform returned a record id that is not a UUID ("$platformId"). '
        'Folding it into one so the entry can sync; see extra_data.source_record_id',
      );
    }
    normalizedIdCount++;
    return ps.uuid.v5(categoryId, platformId);
  }

  /// Whether [value] is within what the server accepts for [category].
  ///
  /// A value outside those bounds is rejected with a 400, and a validation
  /// failure is permanent by design: the entry would sit in the local database
  /// and never sync. So it is dropped here instead of written. Nobody ever
  /// complains about a dropped wearable artifact, which makes this log the only
  /// signal that a bound is too tight.
  ///
  /// The unit is the metric's, not the category's: body weight is imported in
  /// kilograms and stamped as such, even into a category labelled in pounds.
  bool _isInRange(num value, MeasurementCategory category, HealthMetric metric) {
    final limits = category.metricType.limits(metric.unit);
    if (limits.contains(value)) {
      return true;
    }

    if (outOfRangeCount == 0) {
      _logger.warning(
        'Dropping a ${category.metricType.name} reading of $value ${metric.unit}, '
        'outside the accepted ${limits.min} to ${limits.max}',
      );
    }
    outOfRangeCount++;
    return false;
  }

  /// The categories [metric] imports into, paired with the state their import
  /// carries across the read windows.
  ///
  /// Throws [SkipMetric] when the metric cannot be imported right now (no
  /// official body weight category yet, or a group conflict); the cause is
  /// logged where it is decided.
  Future<List<ImportTarget>> resolveTargets(
    HealthMetric metric,
    List<MeasurementCategory> categories,
    String userId,
  ) async {
    if (metric.components.isEmpty) {
      final category = await _findOrCreateCategory(metric, categories, userId);
      if (category == null) {
        throw const SkipMetric();
      }
      return [await _targetFor(metric, category, metric.dataTypes)];
    }

    final children = await _findOrCreateGroupChildren(metric, categories, userId);
    if (children == null) {
      throw const SkipMetric();
    }
    return [
      for (final (i, component) in metric.components.indexed)
        await _targetFor(metric, children[i], component.dataTypes),
    ];
  }

  Future<ImportTarget> _targetFor(
    HealthMetric metric,
    MeasurementCategory category,
    List<HealthDataType> dataTypes,
  ) async => ImportTarget(
    category: category,
    dataTypes: dataTypes,
    // Loaded once per run: a full history holds one row per record or day,
    // and every batch of the run deduplicates against the same state
    seen: metric.dailyAggregation == null ? await _measurements.getExternalIds(category.id!) : null,
    stored: metric.dailyAggregation != null
        ? await _measurements.getEntriesByExternalId(category.id!)
        : null,
  );

  /// Finds the category for [metric] by its `metric_type`, or creates it. The
  /// created category is appended to [categories] so a later metric in the same
  /// run reuses it.
  ///
  /// Matching by name as well was dropped deliberately: it hit any hand-made
  /// category that happened to be called like the metric in English and missed
  /// it in every other language, so the target depended on the UI language. A
  /// hand-kept category cannot be adopted into a metric type yet, see the plan.
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

    final category = MeasurementCategory.forMetricType(userId, metric.metricType);
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
    if (existing != null && await _measurements.hasEntries(existing.id!)) {
      _logger.warning(
        'Category "${existing.name}" holds entries itself and cannot become '
        'a ${metric.metricType.name} group, skipping the import',
      );
      return null;
    }

    final parent = existing ?? MeasurementCategory.forMetricType(userId, metric.metricType);
    // Collected and written in one transaction, so a group is never left
    // without the children its readings live in
    final toCreate = <MeasurementCategory>[if (existing == null) parent];

    // The component categories come from the metric type, in the same order as
    // the metric's health data types, so the caller can pair them by index.
    // The server creates them on the very same ids when it sees the group
    final result = <MeasurementCategory>[];
    for (final (order, metricType) in metric.metricType.components.indexed) {
      final existingChild = categories.firstWhereOrNull(
        (c) => c.parentId == parent.id && c.metricType == metricType,
      );
      if (existingChild != null) {
        result.add(existingChild);
        continue;
      }
      final child = MeasurementCategory.forMetricType(
        userId,
        metricType,
        parentId: parent.id,
        order: order,
      );
      toCreate.add(child);
      result.add(child);
    }
    if (toCreate.isNotEmpty) {
      await _measurements.addLocalDriftCategoryGroup(toCreate);
      categories.addAll(toCreate);
    }
    return result;
  }
}

/// One category a metric imports into, with the state the import carries
/// across the read windows.
class ImportTarget {
  ImportTarget({required this.category, required this.dataTypes, this.seen, this.stored});

  final MeasurementCategory category;

  /// The readings this target receives, matched by their platform type.
  final List<HealthDataType> dataTypes;

  /// External ids already imported; raw metrics only.
  final Set<String>? seen;

  /// Stored aggregates by external id; aggregating metrics only.
  final Map<String, MeasurementEntry>? stored;

  /// Days still collecting samples, until no read window can add to them
  /// anymore. Never more than the newest day per window boundary, which is
  /// what keeps the peak memory at one window plus one day.
  final pending = <DateTime, List<HealthReading>>{};
}

/// Stops reading a metric that cannot be imported right now; its watermark
/// then stays put and the readings are retried on the next sync.
class SkipMetric implements Exception {
  const SkipMetric();
}
