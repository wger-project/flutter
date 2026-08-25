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

import 'package:flutter/widgets.dart' show AppLifecycleListener;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/core/network/auth_credentials_storage.dart';
import 'package:wger/core/shared_preferences.dart';
import 'package:wger/features/health/models/health_metric.dart';
import 'package:wger/features/health/providers/health_importer.dart';
import 'package:wger/features/health/providers/health_repository.dart';
import 'package:wger/features/measurements/providers/measurement_repository.dart';

/// The importer's outcome is part of what this notifier exposes, so it reads
/// as one API from the outside.
export 'package:wger/features/health/providers/health_importer.dart'
    show HealthSyncIssue, dailyAggregateExternalId;

part 'health_sync.freezed.dart';
part 'health_sync.g.dart';

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

/// Drives the health import: the user's preference, when a run happens, and
/// what the settings screen shows about it.
///
/// The import itself is [HealthImporter], which this only starts and reports
/// on. Everything about how readings become measurements lives there.
@Riverpod(keepAlive: true)
class HealthSyncNotifier extends _$HealthSyncNotifier {
  /// Minimum pause between the automatic syncs, on app start and on resume.
  static const _autoSyncThrottle = Duration(minutes: 15);

  final _logger = Logger('HealthSyncNotifier');
  late final HealthRepository _health;
  late final HealthImporter _importer;

  @override
  HealthSyncState build() {
    _health = ref.read(healthRepositoryProvider);
    _importer = HealthImporter(
      health: _health,
      measurements: ref.read(measurementRepositoryProvider),
      prefs: PreferenceHelper.instance,
      credentials: ref.read(authCredentialsStorageProvider),
    );
    _loadPersistedState();

    // New readings often exist exactly when the app comes back from the
    // background (the user just weighed in, granted permissions, ...), so
    // resume triggers a sync as well, throttled to stay unobtrusive
    final lifecycleListener = AppLifecycleListener(onResume: syncIfDue);
    ref.onDispose(lifecycleListener.dispose);

    return const HealthSyncState();
  }

  Future<void> _loadPersistedState() async {
    if (await PreferenceHelper.instance.getHealthSyncEnabled()) {
      state = state.copyWith(isEnabled: true);
    }
  }

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
    if (!await _health.ensureAuthorized(healthDataTypes)) {
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
    if (!await _health.ensureAuthorized(healthDataTypes)) {
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

  /// Runs one import unless the last one finished less than
  /// [_autoSyncThrottle] ago, for the automatic triggers (app start, resume).
  ///
  /// Every run re-reads the overlap window of each metric, which is a month of
  /// platform records for the ones a watch writes continuously, so an app
  /// restarted a few times in a row must not do that on every start. What the
  /// user asks for from the settings goes through [sync] and is never skipped.
  Future<void> syncIfDue() async {
    final last = await PreferenceHelper.instance.getHealthSyncLastRun();
    if (last != null && DateTime.now().difference(last) < _autoSyncThrottle) {
      _logger.fine('Health sync ran at $last, skipping this one');
      return;
    }

    await sync();
  }

  /// Runs one import and reports it in the state. Returns the number of
  /// imported entries. A no-op unless the user enabled sync, and while one is
  /// already running. Triggered on app open, on app resume, and manually from
  /// the settings.
  Future<int> sync() async {
    if (!await PreferenceHelper.instance.getHealthSyncEnabled()) {
      return 0;
    }
    if (state.isSyncing) {
      return 0;
    }
    state = state.copyWith(isEnabled: true, isSyncing: true, issue: null);

    final result = await _importer.run();

    // The timestamp says when the metrics were last read, so a run that gave
    // up before reading any of them leaves the previous one standing
    if (result.completed) {
      await PreferenceHelper.instance.setHealthSyncLastRun(DateTime.now());
    }
    state = state.copyWith(
      isSyncing: false,
      lastSyncCount: result.imported,
      lastSyncTime: result.completed ? DateTime.now() : state.lastSyncTime,
      issue: result.issue,
    );
    return result.imported;
  }
}
