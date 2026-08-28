/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
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

import 'package:flutter_riverpod/flutter_riverpod.dart' show Provider;
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:wger/core/shared_preferences.dart';
import 'package:wger/database/powersync/powersync.dart';
import 'package:wger/features/account/providers/timezone_sync.dart';
import 'package:wger/powersync/sync_watchdog.dart';

/// What a session change does to the local PowerSync database: disconnect it,
/// reconnect it with new credentials, or remove its data.
///
/// A seam as much as a grouping: `PowerSyncDatabase` is a `base` class and
/// cannot be faked, so a test that would otherwise touch the real singleton
/// overrides [powerSyncSessionProvider] instead.
class PowerSyncSession {
  final _logger = Logger('PowerSyncSession');

  /// Disconnects an already-built DB but keeps its data on disk. No-op when
  /// PowerSync hasn't been built yet.
  Future<void> disconnect() async {
    final db = builtPowerSyncInstance;
    if (db == null) {
      return;
    }
    try {
      await db.disconnect();
    } catch (e, s) {
      _logger.warning('PowerSync disconnect failed', e, s);
    }
  }

  /// Reconnects an already-built DB with a fresh connector for [serverUrl].
  /// No-op when PowerSync hasn't been built yet: the next access will build
  /// it with the current (post-login) auth state.
  void reconnect(String serverUrl, http.Client client, SyncStreamWatchdog watchdog) {
    final db = builtPowerSyncInstance;
    if (db == null) {
      return;
    }
    try {
      connectPowerSync(db, serverUrl, client, watchdog, reason: 'login completed');
    } catch (e, s) {
      _logger.warning('PowerSync reconnect failed', e, s);
    }
  }

  /// Removes the local data whether or not the DB has been built: when the
  /// instance exists we use PowerSync's own `disconnectAndClear`, otherwise
  /// (cold start, before any data widget has built it) we delete the on-disk
  /// files directly so no data survives.
  ///
  /// Throws if the wipe fails. Callers must abort before advancing the DB
  /// owner marker, otherwise the previous user's data stay on disk
  Future<void> wipe() async {
    final db = builtPowerSyncInstance;
    if (db != null) {
      try {
        await db.disconnectAndClear();
      } catch (e, s) {
        _logger.severe('local DB wipe via disconnectAndClear failed', e, s);
        rethrow;
      }
    } else {
      try {
        await deletePowerSyncDatabaseFile();
      } catch (e, s) {
        _logger.severe('local DB wipe via file delete failed', e, s);
        rethrow;
      }
    }

    // The account-scoped preferences leave with the data: the next account
    // must not inherit the health-sync opt-in and watermarks, nor a timezone
    // marker that would let the sync overwrite its chosen zone
    await PreferenceHelper.instance.clearHealthSyncPreferences();
    await PreferenceHelper.asyncPref.remove(reportedTimezonePrefKey);
  }
}

final powerSyncSessionProvider = Provider<PowerSyncSession>((ref) => PowerSyncSession());
