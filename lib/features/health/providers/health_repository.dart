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

import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/health.dart';
import 'package:logging/logging.dart';
import 'package:wger/features/health/models/health_metric.dart';
import 'package:wger/features/health/models/health_reading.dart';

final healthRepositoryProvider = Provider<HealthRepository>((ref) {
  return HealthRepository();
});

/// How usable the health platform is on this device.
enum HealthPlatformAvailability {
  available,

  /// Android without Health Connect installed.
  notInstalled,

  /// Android with a Health Connect too old for the SDK.
  updateRequired,

  /// Neither Apple Health nor Health Connect exists here (desktop, web).
  unsupported,
}

/// Wraps the `health` plugin so the rest of the app talks to a small, mockable
/// surface instead of Apple Health / Health Connect directly.
class HealthRepository {
  HealthRepository([Health? health]) : _health = health ?? Health();

  final Health _health;
  final _logger = Logger('HealthRepository');

  /// The measurement `source` value for readings from this platform: `apple`
  /// for Apple Health, `google` for Health Connect.
  String get sourceName => Platform.isIOS ? 'apple' : 'google';

  /// Whether a health platform is usable on this device.
  Future<bool> isAvailable() async => await availability() == HealthPlatformAvailability.available;

  /// How usable the device's health platform is.
  ///
  /// Android tells the two unusable cases apart, and both are the user's to
  /// fix: Health Connect can be installed or updated from the store, see
  /// [openHealthConnectInstall].
  Future<HealthPlatformAvailability> availability() async {
    // Checked before anything else: on web `dart:io` is a stub whose
    // Platform getters throw instead of returning false
    if (kIsWeb) {
      return HealthPlatformAvailability.unsupported;
    }
    if (Platform.isAndroid) {
      await _health.configure();
      return switch (await _health.getHealthConnectSdkStatus()) {
        HealthConnectSdkStatus.sdkAvailable => HealthPlatformAvailability.available,
        HealthConnectSdkStatus.sdkUnavailableProviderUpdateRequired =>
          HealthPlatformAvailability.updateRequired,
        _ => HealthPlatformAvailability.notInstalled,
      };
    }
    return Platform.isIOS
        ? HealthPlatformAvailability.available
        : HealthPlatformAvailability.unsupported;
  }

  /// Sends the user to the store page for installing or updating Health
  /// Connect. Android only, a no-op elsewhere.
  Future<void> openHealthConnectInstall() => _health.installHealthConnect();

  /// Whether the platform grants access to records older than 30 days.
  ///
  /// Android gates the history behind its own permission; without it Health
  /// Connect silently limits every read to the last 30 days, which would make
  /// the first import look complete while missing everything before that.
  /// Always true on iOS, which has no such gate.
  Future<bool> ensureHistoryAuthorized() async {
    if (kIsWeb || !Platform.isAndroid) {
      return true;
    }
    return _health.requestHealthDataHistoryAuthorization();
  }

  /// The subset of [types] the platform lets us read, without ever showing a
  /// permission dialog.
  ///
  /// Asked per type on purpose. Both platforms hand out access per data type,
  /// and Health Connect's dialog invites the user to untick individual ones,
  /// so a single declined type must cost only its own metric its import.
  /// (`hasPermissions` answers for the whole list at once, which turned one
  /// declined type into a full stop.)
  ///
  /// Only Android answers exactly. HealthKit does not disclose read access, so
  /// the types it maps come back as `requestedOrUnknown` and count as
  /// readable; a denial there only shows up when the read fails, see
  /// [isAuthorizationMissing].
  Future<Set<HealthDataType>> readableTypes(List<HealthDataType> types) async {
    if (types.isEmpty) {
      return {};
    }
    await _health.configure();

    try {
      final snapshot = await _health.getAuthorizationSnapshot(types.toSet().toList());
      if (!snapshot.available) {
        return {};
      }
      return {
        for (final entry in snapshot.types)
          if (_isReadable(entry.read)) entry.type,
      };
    } catch (e) {
      // The snapshot only refines what we try: without it every type is read
      // and the ones the platform refuses fail individually, which is the
      // behaviour this method improves on, not one it depends on
      _logger.warning('Could not read the authorization snapshot, trying every type: $e');
      return types.toSet();
    }
  }

  static bool _isReadable(HealthAuthorizationState state) => switch (state) {
    // iOS never reports more than "was requested at some point"
    HealthAuthorizationState.authorized || HealthAuthorizationState.requestedOrUnknown => true,
    _ => false,
  };

  /// Whether [error] is the platform refusing a read for lack of permissions.
  ///
  /// HealthKit throws this when authorization for a type was never requested
  /// for the current installation, which is the one permission problem iOS
  /// does report (a plain denial silently reads as "no data"). Reinstalling
  /// the app resets the grants while the app's own preferences survive, so a
  /// sync can hit this even though the user did grant access earlier.
  static bool isAuthorizationMissing(Object error) =>
      error is PlatformException &&
      (error.message ?? '').toLowerCase().contains('authorization not determined');

  /// Ensures READ access to [types] (requesting it if needed) and, on Android,
  /// access to historical data. Returns whether access is granted.
  ///
  /// Shows the platform's permission dialog, so only call this from a path the
  /// user started themselves.
  Future<bool> ensureAuthorized(List<HealthDataType> types) async {
    await _health.configure();

    if ((await readableTypes(types)).length < types.length) {
      // The return value is deliberately ignored: Android reports success as
      // soon as the dialog closes, whatever the user ticked there. Only the
      // snapshot afterwards says what we may actually read
      await _health.requestAuthorization(
        types,
        permissions: List.filled(types.length, HealthDataAccess.READ),
      );
    }

    final readable = await readableTypes(types);
    if (readable.isEmpty) {
      _logger.warning('Health permissions not granted');
      return false;
    }
    if (readable.length < types.length) {
      _logger.info('Health access granted for ${readable.length} of ${types.length} types');
    }

    // Not fatal: without it the import still works, it just cannot reach
    // further back than 30 days
    if (!await ensureHistoryAuthorized()) {
      _logger.warning(
        'Access to the health history was not granted, only the last 30 days can be imported',
      );
    }
    return true;
  }

  /// Reads all [types] between [start] and [end], platform-deduplicated and
  /// reduced to numeric [HealthReading]s.
  ///
  /// Types are read one by one: a single type the platform refuses (an
  /// unauthorized type throws rather than coming back empty) would otherwise
  /// cost every other type its import too. A failing type is logged by name
  /// and skipped; only when every type fails does the error propagate, so a
  /// wholesale denial still surfaces as one.
  ///
  /// Each type is read in windows of [window]: the plugin turns every record
  /// into a map and then serialises the whole batch for the method channel, so
  /// one query spanning years of a densely written type fills the Android app
  /// heap, which is capped at 256 MB however much RAM the device has, and the
  /// process is killed. How large a window a metric can afford is a property
  /// of the metric, see [HealthMetric.readWindow]. The windows are contiguous,
  /// and a record sitting exactly on a boundary is removed by the
  /// deduplication below.
  Future<List<HealthReading>> read({
    required List<HealthDataType> types,
    required DateTime start,
    required DateTime end,
    required Duration window,
  }) async {
    final points = <HealthDataPoint>[];
    Object? firstError;
    var failed = 0;

    for (final type in types) {
      try {
        var windowStart = start;
        var readForType = 0;
        while (windowStart.isBefore(end)) {
          final windowEnd = windowStart.add(window);
          final batch = await _health.getHealthDataFromTypes(
            types: [type],
            startTime: windowStart,
            endTime: windowEnd.isAfter(end) ? end : windowEnd,
          );
          // How much a window holds is what decides whether [window] is small
          // enough, so it is worth having in a bug report instead of being
          // reconstructed from GC lines afterwards
          if (batch.isNotEmpty) {
            _logger.finer('Read ${batch.length} ${type.name} records from $windowStart');
            readForType += batch.length;
          }
          points.addAll(batch);
          windowStart = windowEnd;
        }
        if (readForType > 0) {
          _logger.fine('Read $readForType ${type.name} records in total');
        }
      } catch (e) {
        // The whole type counts as failed even when earlier windows delivered:
        // importing half a type would let the watermark move past the readings
        // the failing windows never returned
        failed++;
        firstError ??= e;
        _logger.warning('Reading ${type.name} from the health platform failed: $e');
      }
    }

    if (firstError != null && failed == types.length) {
      throw firstError;
    }
    return _health
        .removeDuplicates(points)
        .map(HealthReading.fromDataPoint)
        .whereType<HealthReading>()
        .toList();
  }
}
