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
import 'package:wger/features/health/models/daily_windows.dart';
import 'package:wger/features/health/models/health_metric.dart';
import 'package:wger/features/health/providers/health_entry_writer.dart';
import 'package:wger/features/health/providers/health_repository.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';
import 'package:wger/features/measurements/providers/measurement_repository.dart';

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

/// How far a run has come, in the platform queries it walks through.
///
/// Their durations vary by orders of magnitude (an empty window returns in
/// milliseconds), so this says how much is left, not how long it takes.
typedef HealthSyncProgress = ({int windowsDone, int windowsTotal});

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
    this.onProgress,
  }) : _health = health,
       _measurements = measurements,
       _prefs = prefs,
       _credentials = credentials;

  final HealthRepository _health;
  final MeasurementRepository _measurements;
  final PreferenceHelper _prefs;
  final AuthCredentialsStorage _credentials;

  /// Reports how far the run has come, after every read window and at the end
  /// of every metric.
  final void Function(HealthSyncProgress progress)? onProgress;

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

  /// Writes what the running import reads, and counts what it had to fold or
  /// drop. Replaced per run, see [run].
  late HealthEntryWriter _writer;

  /// Reads the enabled metrics from the health platform and writes any new
  /// readings to the matching measurement categories.
  ///
  /// Permissions are checked silently, never requested: this runs on app open
  /// and resume, where a platform dialog would come out of nowhere. Asking
  /// again is the user's call, which the notifier offers.
  Future<HealthImportResult> run() async {
    try {
      final readable = await _health.readableTypes(healthDataTypes);
      final metrics = healthMetrics.where((m) => m.dataTypes.every(readable.contains)).toList();
      if (metrics.isEmpty) {
        _logger.warning('Health permissions not granted, skipping sync');
        return (imported: 0, issue: HealthSyncIssue.permissionsMissing, completed: false);
      }
      if (metrics.length < healthMetrics.length) {
        // A declined type costs its own metric its import, nothing else. Both
        // platforms hand out access per type, so this is the normal state
        // after a user unticked one, not an error
        final blocked = healthMetrics.where((m) => !metrics.contains(m));
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

      _writer = HealthEntryWriter(_measurements, _health.sourceName);
      final run = await _prepare(metrics, readable, userId);
      _reportProgress(run);
      for (final metric in metrics) {
        await _syncMetric(metric, run);
      }
      await _persist(run, readable);

      _logger.info(
        'Imported ${run.synced} health measurements, '
        '${run.watermarks.length} of ${metrics.length} metrics now have a watermark',
      );
      return run.result();
    } catch (e, s) {
      return _failureResult(e, s);
    }
  }

  /// Everything the metrics are read against: where each one starts, which
  /// categories exist, and what the run collects along the way.
  Future<_SyncRun> _prepare(
    List<HealthMetric> metrics,
    Set<HealthDataType> readable,
    String userId,
  ) async {
    final categories = await _measurements.getCategoriesOnce();

    final run = _SyncRun(
      userId: userId,
      categories: categories,
      endTime: DateTime.now(),
      watermarks: await _readWatermarks(),
      // Metrics the platform has nothing for never get a category, so counting
      // them as missing would ask for the full window on every sync
      knownEmpty: {...?await _prefs.getHealthSyncEmptyMetrics()},
      withoutCategory: _missingCategories(
        metrics,
        categories,
      ).map((m) => m.metricType.name).toSet(),
      newlyReadable: await _newlyReadableTypes(readable),
    );
    // Only known once the starts are: a metric reading its full history is
    // hundreds of windows, one starting at its watermark a handful
    run.windowsPerMetric.addEntries(
      metrics.map((m) => MapEntry(m.metricType.name, run.windowsFor(m))),
    );
    return run;
  }

  /// Reads one metric and writes what it delivers, then moves its watermark.
  ///
  /// One bad metric must not cost the others their import, so everything here
  /// is caught: its own watermark then stays put for whatever it could not
  /// write, and the run remembers what kind of failure it was.
  Future<void> _syncMetric(HealthMetric metric, _SyncRun run) async {
    final name = metric.metricType.name;
    final startTime = run.startFor(metric);
    final readsFullHistory = startTime == _fullHistoryStart;
    final windowsBefore = run.windowsDone;
    // One line per metric would be eight per sync in the exportable log,
    // where the summary at the end is what a report needs
    _logger.fine('Syncing $name from $startTime to ${run.endTime}');

    try {
      var delivered = false;
      DateTime? latest;
      // The categories the metric imports into, resolved on the first
      // batch that delivers: a metric the platform has nothing for must
      // not create them
      List<ImportTarget>? targets;

      // Read per metric, one window at a time: how much of the timeline
      // one platform query may cover depends on how densely the metric is
      // written, see [HealthMetric.readWindow]. Windows already written
      // stay written when a later one fails; the watermark below then
      // holds, and the re-read is deduplicated via the external ids
      await _health.read(
        types: metric.dataTypes,
        start: windowStartFor(startTime, metric),
        end: run.endTime,
        window: metric.readWindow,
        onWindow: () {
          run.windowsDone++;
          _reportProgress(run);
        },
        onBatch: (batch, windowEnd) async {
          final readings = batch.where((r) => metric.dataTypes.contains(r.type)).toList();
          if (readings.isEmpty) {
            return;
          }
          delivered = true;
          targets ??= await _writer.resolveTargets(metric, run.categories, run.userId);
          for (final target in targets!) {
            final routed = readings.where((r) => target.dataTypes.contains(r.type));
            run.synced += metric.dailyAggregation != null
                ? await _writer.collectDailyAggregates(metric, routed, target, windowEnd)
                : await _writer.importReadings(metric, routed, target);
          }
          for (final reading in readings) {
            if (latest == null || reading.date.isAfter(latest!)) {
              latest = reading.date;
            }
          }
        },
      );
      // The newest day can still be growing, so it is only written once
      // no window can add to it anymore
      for (final target in targets ?? const <ImportTarget>[]) {
        run.synced += await _writer.flushPendingDays(metric, target);
      }

      if (!delivered) {
        if (readsFullHistory && run.withoutCategory.contains(name)) {
          run.knownEmpty.add(name);
        }
        run.watermarks[name] = run.endTime;
        return;
      }
      run.knownEmpty.remove(name);

      // A reading dated in the future (a device with a wrong clock) must
      // not drag the watermark along with it, or everything recorded until
      // that date is skipped on the next run
      run.watermarks[name] = latest == null || latest!.isAfter(run.endTime) ? run.endTime : latest!;
    } on SkipMetric {
      // Nothing was written and the watermark holds; the cause is logged
      // where the metric was skipped
    } catch (e, s) {
      if (HealthRepository.isAuthorizationMissing(e)) {
        // The one permission failure iOS reports, and it reports it only
        // when the read runs. Worth telling apart, the user can fix it
        _logger.warning('No authorization to read $name', e);
        run.permissionsMissing = true;
      } else {
        _logger.severe('Importing $name failed', e, s);
        run.failedMetric = true;
      }
    } finally {
      // A metric that stopped early read fewer windows than it was counted
      // for, and the progress must not stay short of its share for that
      run.windowsDone = windowsBefore + run.windowsPerMetric[name]!;
      _reportProgress(run);
    }
  }

  void _reportProgress(_SyncRun run) =>
      onProgress?.call((windowsDone: run.windowsDone, windowsTotal: run.windowsTotal));

  /// Writes what the run learned, once every metric has had its turn.
  Future<void> _persist(_SyncRun run, Set<HealthDataType> readable) async {
    // Recorded after the metrics ran, so a sync that died earlier tries
    // again rather than remembering an access it never used
    await _prefs.setHealthSyncReadableTypes(readable.map((t) => t.name).toList());
    // A metric that threw is in neither set and keeps its full-window read
    await _prefs.setHealthSyncEmptyMetrics(run.knownEmpty.toList());
    await _writeWatermarks(run.watermarks);

    if (_writer.normalizedIdCount > 0) {
      _logger.warning(
        'Folded ${_writer.normalizedIdCount} platform record ids into UUIDs during this sync',
      );
    }
    if (_writer.outOfRangeCount > 0) {
      _logger.warning('Dropped ${_writer.outOfRangeCount} readings outside their metric limits');
    }
  }

  /// The result of a run that gave up before the metrics ran.
  ///
  /// A read the platform refuses for lack of permissions is the one permission
  /// problem iOS reports at all, so it is worth telling apart from a genuine
  /// failure: the user can fix it by granting access again.
  HealthImportResult _failureResult(Object e, StackTrace s) {
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

  /// The type names the platform now lets us read but did not last time.
  ///
  /// Such a type has no history in wger for the same reason a deleted category
  /// has none: nothing was ever imported for it, so the watermark says nothing
  /// about it. That happens when the user grants access they had declined, and
  /// after an app update that added the type.
  ///
  /// The names rather than a flag: only the metrics built on them have that
  /// hole, and the full history of every other one would be read for nothing.
  Future<Set<String>> _newlyReadableTypes(Set<HealthDataType> readable) async {
    final previous = await _prefs.getHealthSyncReadableTypes();
    if (previous == null) {
      return {};
    }

    final newlyReadable = readable.map((t) => t.name).toSet().difference(previous.toSet());
    if (newlyReadable.isNotEmpty) {
      _logger.info(
        'Access to ${newlyReadable.join(', ')} is new, '
        'reading their full history instead of from the watermark',
      );
    }
    return newlyReadable;
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
}

/// The state one [HealthImporter.run] carries across its metrics: what the
/// reads are measured against, and what they produced.
class _SyncRun {
  _SyncRun({
    required this.userId,
    required this.categories,
    required this.endTime,
    required this.watermarks,
    required this.knownEmpty,
    required this.withoutCategory,
    required this.newlyReadable,
  });

  /// Owner of the local database, whose typed category ids are derived from it
  final String userId;

  /// The categories that exist, grown by the ones a metric creates
  final List<MeasurementCategory> categories;

  /// End of every read window of this run, so the metrics cover the same span
  final DateTime endTime;

  /// How far each metric has been imported, moved as they deliver
  final Map<String, DateTime> watermarks;

  /// Metrics the platform is known to have nothing for, see
  /// setHealthSyncEmptyMetrics
  final Set<String> knownEmpty;

  /// Metrics without a category to import into
  final Set<String> withoutCategory;

  /// Type names the platform lets us read but did not last time
  final Set<String> newlyReadable;

  /// How many read windows each metric takes, by metric name
  final windowsPerMetric = <String, int>{};

  /// Windows read so far, across the metrics that already ran
  var windowsDone = 0;

  var synced = 0;
  var failedMetric = false;
  var permissionsMissing = false;

  int get windowsTotal => windowsPerMetric.values.sum;

  /// Into how many windows [HealthRepository.read] slices this metric's span.
  int windowsFor(HealthMetric metric) {
    final span = endTime.difference(windowStartFor(startFor(metric), metric));
    return span.isNegative ? 0 : (span.inMicroseconds / metric.readWindow.inMicroseconds).ceil();
  }

  /// Where the read of [metric] starts.
  ///
  /// A metric with nothing imported yet has no watermark to go from, and one
  /// without a category has no history behind its watermark either: reading
  /// from it would import what happened since and leave everything before it
  /// missing, silently. Those read the full history; everything else starts
  /// an overlap window before its watermark.
  DateTime startFor(HealthMetric metric) {
    final name = metric.metricType.name;
    final hasNoHistory =
        metric.dataTypes.any((t) => newlyReadable.contains(t.name)) ||
        watermarks[name] == null ||
        (withoutCategory.contains(name) && !knownEmpty.contains(name));

    return hasNoHistory
        ? HealthImporter._fullHistoryStart
        : watermarks[name]!.subtract(HealthImporter._syncOverlap);
  }

  /// What the run reports back: a failing metric outweighs a missing
  /// permission, since it is the one the user cannot act on themselves.
  HealthImportResult result() => (
    imported: synced,
    issue: failedMetric
        ? HealthSyncIssue.failed
        : permissionsMissing
        ? HealthSyncIssue.permissionsMissing
        : null,
    completed: true,
  );
}

/// then stays put and the readings are retried on the next sync.
