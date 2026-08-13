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
import 'package:wger/core/network/auth_credentials_storage.dart';
import 'package:wger/core/shared_preferences.dart';
import 'package:wger/features/health/models/health_metric.dart';
import 'package:wger/features/health/models/health_reading.dart';
import 'package:wger/features/health/providers/health_repository.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';
import 'package:wger/features/measurements/models/unit_conversion.dart';
import 'package:wger/features/measurements/providers/measurement_repository.dart';

final _uuidPattern = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$');

/// Stable id identifying the aggregate of [day] within [categoryId].
///
/// Deterministic, so re-reading a day within the overlap window updates the
/// same entry instead of adding a second one. It has to be a real UUID rather
/// than a readable `day-<date>` key, because the server stores `external_id`
/// as a UUIDField and rejects anything else permanently. The category id is
/// itself a UUID and serves as the v5 namespace, which is exactly the
/// "day X within category Y" relationship the id expresses.
///
/// The day is formatted by hand: `DateFormat` renders its digits in the
/// current locale, so a locale with its own numerals would give every day a
/// second id and re-import the whole history.
String dailyAggregateExternalId(String categoryId, DateTime day) => ps.uuid.v5(
  categoryId,
  '${day.year.toString().padLeft(4, '0')}-'
  '${day.month.toString().padLeft(2, '0')}-'
  '${day.day.toString().padLeft(2, '0')}',
);

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

/// What one [HealthImporter.run] produced.
///
/// `completed` is false when the run gave up before reading any metric, which
/// is what tells a caller apart from an import that simply found nothing.
typedef HealthImportResult = ({int imported, HealthSyncIssue? issue, bool completed});

/// Imports body metrics from Apple Health / Health Connect into measurement
/// categories.
///
/// Read-only towards the platform: reads it via [HealthRepository], writes to
/// the local Drift DB, and lets PowerSync push the rows up. Re-imports are
/// deduplicated via each measurement's [MeasurementEntry.externalId] (the
/// platform record UUID).
///
/// Plain Dart and constructed with its dependencies rather than reading them
/// from a container, so a run needs nothing but the four below. What drives
/// the runs, and the state they produce, is the notifier's.
class HealthImporter {
  HealthImporter({
    required HealthRepository health,
    required MeasurementRepository measurements,
    required PreferenceHelper prefs,
    required AuthCredentialsStorage credentials,
  }) : _health = health,
       _measurements = measurements,
       _prefs = prefs,
       _credentials = credentials;

  final HealthRepository _health;
  final MeasurementRepository _measurements;
  final PreferenceHelper _prefs;
  final AuthCredentialsStorage _credentials;

  final _logger = Logger('HealthImporter');

  /// How far a read window reaches back before the metric's watermark, to
  /// pick up records that arrived late with a past date. Re-reads are
  /// deduplicated via their external id.
  static const _syncOverlap = Duration(days: 30);

  /// Where a full read starts, i.e. when a metric has no watermark to go from.
  ///
  /// Not the epoch: every window before the first record is a platform query
  /// that returns nothing, and for a metric read in weekly windows those add
  /// up. Health Connect shipped in 2022 and HealthKit's own data rarely
  /// predates a wearable, so this cuts the empty part without cutting real
  /// history in practice.
  static final _fullHistoryStart = DateTime(2020);

  /// Platform record ids folded into a UUID during the running import, see
  /// [_externalIdFor]. Expected to stay 0; anything else means a platform
  /// changed its id format under us.
  var _normalizedIdCount = 0;

  /// Readings dropped during the running import because their value is outside
  /// what its metric type allows, see [_isInRange].
  var _outOfRangeCount = 0;

  /// Reads the enabled metrics from the health platform and writes any new
  /// readings to the matching measurement categories.
  ///
  /// Permissions are checked silently, never requested: this runs on app open
  /// and resume, where a platform dialog would come out of nowhere. Asking
  /// again is the user's call, which the notifier offers.
  Future<HealthImportResult> run() async {
    _normalizedIdCount = 0;
    _outOfRangeCount = 0;

    try {
      final readable = await _health.readableTypes(enabledHealthDataTypes);
      final metrics = enabledHealthMetrics
          .where((m) => m.dataTypes.every(readable.contains))
          .toList();
      if (metrics.isEmpty) {
        _logger.warning('Health permissions not granted, skipping sync');
        return (imported: 0, issue: HealthSyncIssue.permissionsMissing, completed: false);
      }
      if (metrics.length < enabledHealthMetrics.length) {
        // A declined type costs its own metric its import, nothing else. Both
        // platforms hand out access per type, so this is the normal state
        // after a user unticked one, not an error
        final blocked = enabledHealthMetrics.where((m) => !metrics.contains(m));
        _logger.info(
          'No access to ${blocked.map((m) => m.metricType.name).join(', ')}, '
          'importing the remaining ${metrics.length} metrics',
        );
      }

      // The ids of the typed categories are derived from the user, see
      // [deterministicCategoryId]. Without one nothing could be created that
      // another device would recognise as the same category
      final userId = await _credentials.dbOwnerUserId();
      if (userId == null) {
        _logger.warning('Local database has no owner, skipping health sync');
        return (imported: 0, issue: HealthSyncIssue.failed, completed: false);
      }

      final categories = await _measurements.getCategoriesOnce();

      final watermarks = await _readWatermarks();
      // Metrics the platform has nothing for never get a category, so counting
      // them as missing would ask for the full window on every sync
      final knownEmpty = {...?await _prefs.getHealthSyncEmptyMetrics()};
      final withoutCategory = _missingCategories(
        metrics,
        categories,
      ).map((m) => m.metricType.name).toSet();
      final readsEverything = await _hasNewlyReadableTypes(readable);
      final endTime = DateTime.now();

      final source = _health.sourceName;
      var synced = 0;
      var failedMetric = false;
      var permissionsMissing = false;

      for (final metric in metrics) {
        final name = metric.metricType.name;
        // A metric with nothing imported yet has no watermark to go from, and
        // one without a category has no history behind its watermark either:
        // reading from it would import what happened since and leave
        // everything before it missing, silently
        final startTime =
            readsEverything ||
                watermarks[name] == null ||
                (withoutCategory.contains(name) && !knownEmpty.contains(name))
            ? _fullHistoryStart
            : watermarks[name]!.subtract(_syncOverlap);
        final readsFullHistory = startTime == _fullHistoryStart;
        // One line per metric would be eight per sync in the exportable log,
        // where the summary below is what a report needs
        _logger.fine('Syncing $name from $startTime to $endTime');

        // One bad metric must not cost the others their import, and its own
        // watermark has to stay put for whatever it could not write
        try {
          // Read per metric: how much of the timeline one platform query may
          // cover depends on how densely the metric is written, see
          // [HealthMetric.readWindow]
          final readings = await _health.read(
            types: metric.dataTypes,
            start: _windowStartFor(startTime, metric),
            end: endTime,
            window: metric.readWindow,
          );

          // Pair each target category with the readings it receives: the metric's
          // own category, or one child per component for a group metric.
          final List<(MeasurementCategory, Iterable<HealthReading>)> targets;
          if (metric.components.isEmpty) {
            final metricReadings = readings.where((r) => metric.dataTypes.contains(r.type));
            if (metricReadings.isEmpty) {
              if (readsFullHistory && withoutCategory.contains(name)) {
                knownEmpty.add(name);
              }
              watermarks[name] = endTime;
              continue;
            }
            knownEmpty.remove(name);
            final category = await _findOrCreateCategory(metric, categories, userId);
            if (category == null) {
              continue;
            }
            targets = [(category, metricReadings)];
          } else {
            final byComponent = [
              for (final component in metric.components)
                readings.where((r) => component.dataTypes.contains(r.type)),
            ];
            if (byComponent.every((r) => r.isEmpty)) {
              if (readsFullHistory && withoutCategory.contains(name)) {
                knownEmpty.add(name);
              }
              watermarks[name] = endTime;
              continue;
            }
            knownEmpty.remove(name);
            final children = await _findOrCreateGroupChildren(metric, categories, userId);
            if (children == null) {
              continue;
            }
            targets = [for (var i = 0; i < children.length; i++) (children[i], byComponent[i])];
          }

          DateTime? latest;
          for (final (category, metricReadings) in targets) {
            final (importedCount, newest) = metric.dailyAggregation != null
                ? await _importDailyAggregates(metric, metricReadings, category, source)
                : await _importReadings(metric, metricReadings, category, source);
            synced += importedCount;
            if (newest != null && (latest == null || newest.isAfter(latest))) {
              latest = newest;
            }
          }

          // A reading dated in the future (a device with a wrong clock) must
          // not drag the watermark along with it, or everything recorded until
          // that date is skipped on the next run
          watermarks[name] = latest == null || latest.isAfter(endTime) ? endTime : latest;
        } catch (e, s) {
          if (HealthRepository.isAuthorizationMissing(e)) {
            // The one permission failure iOS reports, and it reports it only
            // when the read runs. Worth telling apart, the user can fix it
            _logger.warning('No authorization to read ${metric.metricType.name}', e);
            permissionsMissing = true;
          } else {
            _logger.severe('Importing ${metric.metricType.name} failed', e, s);
            failedMetric = true;
          }
        }
      }

      // Recorded after the metrics ran, so a sync that died earlier tries
      // again rather than remembering an access it never used
      await _prefs.setHealthSyncReadableTypes(readable.map((t) => t.name).toList());
      // A metric that threw is in neither set and keeps its full-window read
      await _prefs.setHealthSyncEmptyMetrics(knownEmpty.toList());
      await _writeWatermarks(watermarks);

      if (_normalizedIdCount > 0) {
        _logger.warning(
          'Folded $_normalizedIdCount platform record ids into UUIDs during this sync',
        );
      }
      if (_outOfRangeCount > 0) {
        _logger.warning('Dropped $_outOfRangeCount readings outside their metric limits');
      }
      _logger.info(
        'Imported $synced health measurements, '
        '${watermarks.length} of ${metrics.length} metrics now have a watermark',
      );
      return (
        imported: synced,
        issue: failedMetric
            ? HealthSyncIssue.failed
            : permissionsMissing
            ? HealthSyncIssue.permissionsMissing
            : null,
        completed: true,
      );
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
      return (
        imported: 0,
        issue: missing ? HealthSyncIssue.permissionsMissing : HealthSyncIssue.failed,
        completed: false,
      );
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
    final seen = await _measurements.getExternalIds(category.id!);
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

      if (_isInRange(value, category, metric)) {
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
      }

      // Also for a dropped reading: it will never become importable, so
      // holding the watermark back would only mean reading it again forever
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
    // Read once for the whole category: a day is looked up by its key below,
    // and a full history holds one aggregate per day
    final stored = await _measurements.getEntriesByExternalId(category.id!);

    for (final MapEntry(key: day, value: samples) in byDay.entries) {
      final values = samples.map((r) => metric.toCategoryValue(r.value)).toList();
      final aggregate = switch (metric.dailyAggregation!) {
        DailyAggregation.average => values.average,
        DailyAggregation.sum => values.sum,
        DailyAggregation.mergedDuration => _mergedDurationMinutes(samples),
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
          'date_from': samples.map((r) => r.date).reduce(_earlier).toIso8601String(),
          'date_to': samples.map((r) => r.dateTo ?? r.date).reduce(_later).toIso8601String(),
        },
      };

      if (_isInRange(value, category, metric)) {
        final externalId = dailyAggregateExternalId(category.id!, day);
        final existing = stored[externalId];
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
          await _measurements.updateLocalDrift(
            existing.copyWith(value: value, extraData: extraData),
          );
          synced++;
        }
      }

      for (final sample in samples) {
        if (latest == null || sample.date.isAfter(latest)) {
          latest = sample.date;
        }
      }
    }
    return (synced, latest);
  }

  /// How far each metric has been imported.
  Future<Map<String, DateTime>> _readWatermarks() async {
    final stored = await _prefs.getHealthSyncWatermarks();
    return {for (final e in stored.entries) e.key: DateTime.parse(e.value)};
  }

  Future<void> _writeWatermarks(Map<String, DateTime> watermarks) async {
    await _prefs.setHealthSyncWatermarks({
      for (final e in watermarks.entries) e.key: e.value.toIso8601String(),
    });
  }

  /// The time [samples] cover in minutes, counting overlapping stretches once.
  ///
  /// Adding the durations up would report a night twice when two sources both
  /// recorded it, which is the normal case for sleep: a phone writes the night
  /// as undifferentiated sleep while a watch writes the same night as its
  /// stages. A sample without an end is taken to last as long as its value
  /// says.
  double _mergedDurationMinutes(Iterable<HealthReading> samples) {
    final intervals =
        samples
            .map(
              (r) => (
                r.date,
                r.dateTo ?? r.date.add(Duration(microseconds: (r.value * 60 * 1000000).round())),
              ),
            )
            .toList()
          ..sort((a, b) => a.$1.compareTo(b.$1));

    var total = Duration.zero;
    DateTime? start;
    DateTime? end;
    for (final (from, to) in intervals) {
      if (end == null || from.isAfter(end)) {
        if (start != null) {
          total += end!.difference(start);
        }
        start = from;
        end = to;
        continue;
      }
      if (to.isAfter(end)) {
        end = to;
      }
    }
    if (start != null) {
      total += end!.difference(start);
    }
    return total.inMicroseconds / Duration.microsecondsPerMinute;
  }

  /// Where the read window starts for [metric].
  ///
  /// A daily aggregate is recomputed from what the window returns, so a start
  /// inside a day would overwrite it with a fraction of it.
  DateTime _windowStartFor(DateTime start, HealthMetric metric) {
    if (metric.dailyAggregation == null) {
      return start;
    }

    final rollover = metric.dayRollsOverAtHour;
    if (rollover == null) {
      return DateTime(start.year, start.month, start.day);
    }

    // Before the rollover hour the current day began on the previous one
    final dayBegan = start.hour >= rollover ? start.day : start.day - 1;
    return DateTime(start.year, start.month, dayBegan, rollover);
  }

  /// The day a sample is attributed to. Plain calendar day, unless the metric
  /// rolls over: samples at or after [HealthMetric.dayRollsOverAtHour] then
  /// count towards the next day, so a night of sleep lands on the day the user
  /// wakes up instead of being split at midnight.
  DateTime _dayOf(DateTime date, HealthMetric metric) {
    final rollover = metric.dayRollsOverAtHour;
    final rollsOver = rollover != null && date.hour >= rollover;

    // Calendar arithmetic, not +24h: a DST day is 23 or 25 hours long
    return DateTime(date.year, date.month, date.day + (rollsOver ? 1 : 0));
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

    if (_outOfRangeCount == 0) {
      _logger.warning(
        'Dropping a ${category.metricType.name} reading of $value ${metric.unit}, '
        'outside the accepted ${limits.min} to ${limits.max}',
      );
    }
    _outOfRangeCount++;
    return false;
  }

  /// Whether the platform now lets us read a type it did not last time.
  ///
  /// Such a type has no history in wger for the same reason a deleted category
  /// has none: nothing was ever imported for it, so the watermark says nothing
  /// about it. That happens when the user grants access they had declined, and
  /// after an app update that added the type.
  Future<bool> _hasNewlyReadableTypes(Set<HealthDataType> readable) async {
    final previous = await _prefs.getHealthSyncReadableTypes();
    if (previous == null) {
      return false;
    }

    final newlyReadable = readable.map((t) => t.name).toSet().difference(previous.toSet());
    if (newlyReadable.isNotEmpty) {
      _logger.info(
        'Access to ${newlyReadable.join(', ')} is new, '
        'reading the full history instead of from the watermark',
      );
    }
    return newlyReadable.isNotEmpty;
  }

  /// The enabled metrics that have no category to import into.
  ///
  /// Their history in wger is empty, either because the user deleted the
  /// category or because the metric was only just enabled, so the watermark
  /// says nothing about them: reading from it would import what has happened
  /// since and leave everything before it missing, silently. The sync falls
  /// back to the full window for that run instead. Since the categories exist
  /// afterwards, the next sync is back on the watermark, and the entries the
  /// other metrics re-read are deduplicated via their external ids.
  ///
  /// The caller excludes the metrics the platform has nothing for, see
  /// setHealthSyncEmptyMetrics.
  List<HealthMetric> _missingCategories(
    List<HealthMetric> metrics,
    List<MeasurementCategory> categories,
  ) {
    bool hasCategories(HealthMetric metric) {
      if (metric.metricType == MetricType.bodyWeight) {
        return categories.any((c) => c.isOfficialBodyWeight);
      }

      final group = categories.firstWhereOrNull(
        (c) => c.parentId == null && c.metricType == metric.metricType,
      );
      if (group == null) {
        return false;
      }
      // Empty for everything but a group metric, whose readings live in one
      // child category per component
      return metric.metricType.components.every(
        (component) => categories.any((c) => c.parentId == group.id && c.metricType == component),
      );
    }

    final missing = metrics.where((m) => !hasCategories(m)).toList();
    if (missing.isNotEmpty) {
      _logger.info('No category for ${missing.map((m) => m.metricType.name).join(', ')}');
    }
    return missing;
  }

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
    if (existing != null && await _measurements.hasEntries(existing.id!)) {
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
    for (final (order, metricType) in metric.metricType.components.indexed) {
      final existingChild = categories.firstWhereOrNull(
        (c) => c.parentId == parent.id && c.metricType == metricType,
      );
      if (existingChild != null) {
        result.add(existingChild);
        continue;
      }
      final child = MeasurementCategory(
        id: deterministicCategoryId(userId, metricType),
        name: metricType.canonicalName,
        unit: metricType.defaultUnit,
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
