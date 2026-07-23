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

// SyncStatus constructor is marked as @internal
// ignore_for_file: invalid_use_of_internal_member

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:powersync/powersync.dart' show SyncStatus;
import 'package:wger/powersync/sync_watchdog.dart';

void main() {
  late SyncStreamWatchdog watchdog;
  late List<LogRecord> records;

  setUp(() {
    watchdog = SyncStreamWatchdog();
    records = [];
    final sub = Logger.root.onRecord.listen(records.add);
    addTearDown(sub.cancel);
    addTearDown(watchdog.dispose);
  });

  Iterable<LogRecord> logLines(Level level, String needle) =>
      records.where((r) => r.level == level && r.message.contains(needle));

  test('flags a connection that never delivers a checkpoint', () {
    fakeAsync((async) {
      watchdog.onStatus(const SyncStatus(connecting: true));

      async.elapse(watchdog.timeout - const Duration(seconds: 1));
      expect(watchdog.stalled.value, isFalse);

      async.elapse(const Duration(seconds: 2));
      expect(watchdog.stalled.value, isTrue);
      expect(logLines(Level.WARNING, 'may be blocked'), hasLength(1));
    });
  });

  test('the silent connect/EOF retry loop does not reset the timer', () {
    fakeAsync((async) {
      // Mimic the status flapping of an iteration that starts, ends cleanly
      // and retries: connecting toggles, lastSyncedAt never moves.
      for (var i = 0; i < 20; i++) {
        watchdog.onStatus(const SyncStatus(connecting: true));
        async.elapse(const Duration(seconds: 5));
        watchdog.onStatus(const SyncStatus());
        async.elapse(const Duration(seconds: 5));
      }

      expect(watchdog.stalled.value, isTrue);
      expect(logLines(Level.WARNING, 'may be blocked'), hasLength(1));
    });
  });

  test('a checkpoint disarms the watchdog, idle time does not re-trigger it', () {
    fakeAsync((async) {
      watchdog.onStatus(const SyncStatus(connecting: true));
      async.elapse(const Duration(seconds: 10));
      watchdog.onStatus(SyncStatus(connected: true, lastSyncedAt: DateTime(2026, 7, 23)));

      // A healthy connection can sit idle without new status events for far
      // longer than the timeout.
      async.elapse(watchdog.timeout * 3);

      expect(watchdog.stalled.value, isFalse);
      expect(records, isEmpty);
    });
  });

  test('an active download holds the watchdog off', () {
    fakeAsync((async) {
      watchdog.onStatus(const SyncStatus(connected: true, downloading: true));
      async.elapse(watchdog.timeout * 2);

      expect(watchdog.stalled.value, isFalse);
    });
  });

  test('a surfaced sync error holds the watchdog off', () {
    fakeAsync((async) {
      watchdog.onStatus(SyncStatus(connecting: true, downloadError: Exception('boom')));
      async.elapse(watchdog.timeout * 2);

      expect(watchdog.stalled.value, isFalse);
    });
  });

  test('recovers and logs once when a checkpoint finally arrives', () {
    fakeAsync((async) {
      watchdog.onStatus(const SyncStatus(connecting: true));
      async.elapse(watchdog.timeout);
      expect(watchdog.stalled.value, isTrue);

      watchdog.onStatus(SyncStatus(connected: true, lastSyncedAt: DateTime(2026, 7, 23)));

      expect(watchdog.stalled.value, isFalse);
      expect(logLines(Level.INFO, 'recovered'), hasLength(1));
    });
  });

  test('reset() clears the pending timer and the stalled flag', () {
    fakeAsync((async) {
      watchdog.onStatus(const SyncStatus(connecting: true));
      async.elapse(watchdog.timeout);
      expect(watchdog.stalled.value, isTrue);

      watchdog.reset();
      expect(watchdog.stalled.value, isFalse);

      // No further timer fires after the reset.
      async.elapse(watchdog.timeout * 2);
      expect(watchdog.stalled.value, isFalse);
    });
  });

  test('re-arms after reset() for the next connection epoch', () {
    fakeAsync((async) {
      watchdog.onStatus(SyncStatus(connected: true, lastSyncedAt: DateTime(2026, 7, 23)));
      watchdog.reset();

      watchdog.onStatus(const SyncStatus(connecting: true));
      async.elapse(watchdog.timeout);

      expect(watchdog.stalled.value, isTrue);
    });
  });
}
