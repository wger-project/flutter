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

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:powersync/powersync.dart' show SyncStatus;

final _logger = Logger('powersync');

/// Flags a sync stream that keeps reconnecting without ever delivering a
/// checkpoint.
///
/// That is the signature of a middlebox (VPN, ad blocker, antivirus, carrier
/// proxy) silently swallowing the long-lived stream request while short REST
/// requests still pass: the SDK sees a clean end-of-stream on every
/// iteration, so no exception is thrown, nothing is logged above FINE and
/// `SyncStatus.anyError` stays null. The UI shows "Connecting" forever
/// without a trace.
///
/// The watchdog arms a timer while the client wants to sync but has not
/// received a checkpoint in this connection epoch. Checkpoint progress
/// disarms it until [reset]; an active download or a surfaced error pauses
/// it (those cases are visible through other channels). If the timer
/// survives [timeout], [stalled] flips to true (the sync status dialog
/// shows a hint) and a WARNING lands in the app logs.
class SyncStreamWatchdog {
  SyncStreamWatchdog({this.timeout = const Duration(minutes: 2)});

  final Duration timeout;

  /// True while the stream looks blocked. Consumed by the sync status dialog.
  final ValueNotifier<bool> stalled = ValueNotifier(false);

  Timer? _timer;
  DateTime? _lastCheckpoint;
  bool _sawStatus = false;

  /// Set once a checkpoint arrived; the watchdog then stays quiet so a later
  /// idle connection (status events stop while nothing changes) cannot
  /// re-trigger it. [reset] re-arms for the next connection epoch.
  bool _disarmed = false;

  void onStatus(SyncStatus status) {
    final checkpoint = status.lastSyncedAt;
    // Progress is a NEW checkpoint: the first status event replays the
    // timestamp persisted in the local DB (which may be weeks old on a
    // blocked device), so only a change to a non-null value counts.
    final madeProgress = _sawStatus && checkpoint != null && checkpoint != _lastCheckpoint;
    _sawStatus = true;
    _lastCheckpoint = checkpoint;

    if (madeProgress) {
      _disarmed = true;
      _cancelTimer();
      if (stalled.value) {
        _logger.info('Sync stream recovered, checkpoint received');
        stalled.value = false;
      }
      return;
    }

    // Downloading means data is flowing (a first checkpoint on a large
    // account can take a while); an error is already surfaced by the sync
    // status dialog. Neither is the silent failure we are watching for.
    if (status.downloading || status.anyError != null) {
      _cancelTimer();
      return;
    }

    // A `connecting` flag briefly dropping between two retry iterations must
    // NOT clear the timer: the silent connect/EOF loop would reset it on
    // every cycle. Only [reset] (deliberate disconnect) clears it. While
    // already stalled there is nothing new to detect (and no reason to log
    // the warning again), so the timer stays off until recovery.
    if (!_disarmed && !stalled.value && (status.connecting || status.connected)) {
      _timer ??= Timer(timeout, _onTimeout);
    }
  }

  /// Call when the app disconnects on purpose (offline gate, logout), so a
  /// device that is simply offline is never reported as blocked.
  void reset() {
    _cancelTimer();
    _disarmed = false;
    stalled.value = false;
  }

  void dispose() {
    _cancelTimer();
    stalled.dispose();
  }

  void _onTimeout() {
    _timer = null;
    stalled.value = true;
    _logger.warning(
      'Sync stream keeps terminating without receiving any data. The '
      'connection to the sync service may be blocked by a VPN, ad blocker, '
      'antivirus or firewall on this network.',
    );
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }
}
