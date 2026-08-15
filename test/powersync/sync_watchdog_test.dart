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

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:wger/powersync/sync_watchdog.dart';

import '../helpers/sync_status.dart';

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
      watchdog.onStatus(buildSyncStatus(connecting: true));

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
        watchdog.onStatus(buildSyncStatus(connecting: true));
        async.elapse(const Duration(seconds: 5));
        watchdog.onStatus(buildSyncStatus());
        async.elapse(const Duration(seconds: 5));
      }

      expect(watchdog.stalled.value, isTrue);
      expect(logLines(Level.WARNING, 'may be blocked'), hasLength(1));
    });
  });

  test('the checkpoint replayed by the first status event does not disarm it', () {
    fakeAsync((async) {
      // The first event of a connection replays whatever is persisted in the
      // local DB, which on the blocked devices this watchdog exists for is
      // weeks old. Treating that as progress would leave the outage silent.
      watchdog.onStatus(
        buildSyncStatus(connecting: true, lastSyncedAt: DateTime(2026, 7, 1)),
      );

      async.elapse(watchdog.timeout * 2);

      expect(watchdog.stalled.value, isTrue);
      expect(logLines(Level.WARNING, 'may be blocked'), hasLength(1));
    });
  });

  test('a repeated old checkpoint does not disarm it either', () {
    fakeAsync((async) {
      // A reconnect loop re-sends the same stale timestamp on every attempt
      final stale = DateTime(2026, 7, 1);
      for (var i = 0; i < 5; i++) {
        watchdog.onStatus(buildSyncStatus(connecting: true, lastSyncedAt: stale));
        async.elapse(const Duration(seconds: 10));
      }

      async.elapse(watchdog.timeout);

      expect(watchdog.stalled.value, isTrue);
    });
  });

  test('a checkpoint disarms the watchdog, idle time does not re-trigger it', () {
    fakeAsync((async) {
      watchdog.onStatus(buildSyncStatus(connecting: true));
      async.elapse(const Duration(seconds: 10));
      watchdog.onStatus(buildSyncStatus(connected: true, lastSyncedAt: DateTime(2026, 7, 23)));

      // A healthy connection can sit idle without new status events for far
      // longer than the timeout.
      async.elapse(watchdog.timeout * 3);

      expect(watchdog.stalled.value, isFalse);
      expect(records, isEmpty);
    });
  });

  test('an active download holds the watchdog off', () {
    fakeAsync((async) {
      watchdog.onStatus(buildSyncStatus(connected: true, downloading: true));
      async.elapse(watchdog.timeout * 2);

      expect(watchdog.stalled.value, isFalse);
    });
  });

  test('flags a connection that only produces errors', () {
    fakeAsync((async) {
      // Error loop in the five second rhythm of the SDK's retry: visible in
      // the sync dialog, but no checkpoint ever arrives.
      for (var i = 0; i < 30; i++) {
        watchdog.onStatus(buildSyncStatus(connecting: true));
        async.elapse(const Duration(seconds: 2));
        watchdog.onStatus(buildSyncStatus(downloadError: Exception('boom')));
        async.elapse(const Duration(seconds: 3));
      }

      expect(watchdog.stalled.value, isTrue);
      final warnings = logLines(Level.WARNING, 'has been failing');
      expect(warnings, hasLength(1));
      expect(warnings.first.error.toString(), contains('boom'));
    });
  });

  test('an error while data is downloading does not flag anything', () {
    fakeAsync((async) {
      watchdog.onStatus(
        buildSyncStatus(connected: true, downloading: true, uploadError: Exception('boom')),
      );
      async.elapse(watchdog.timeout * 2);

      expect(watchdog.stalled.value, isFalse);
    });
  });

  test('recovers and logs once when a checkpoint finally arrives', () {
    fakeAsync((async) {
      watchdog.onStatus(buildSyncStatus(connecting: true));
      async.elapse(watchdog.timeout);
      expect(watchdog.stalled.value, isTrue);

      watchdog.onStatus(buildSyncStatus(connected: true, lastSyncedAt: DateTime(2026, 7, 23)));

      expect(watchdog.stalled.value, isFalse);
      expect(logLines(Level.INFO, 'recovered'), hasLength(1));
    });
  });

  test('reset() clears the pending timer and the stalled flag', () {
    fakeAsync((async) {
      watchdog.onStatus(buildSyncStatus(connecting: true));
      async.elapse(watchdog.timeout);
      expect(watchdog.stalled.value, isTrue);

      watchdog.reset();
      expect(watchdog.stalled.value, isFalse);

      // No further timer fires after the reset.
      async.elapse(watchdog.timeout * 2);
      expect(watchdog.stalled.value, isFalse);
    });
  });

  test('stays quiet while the backend is unreachable for plain requests', () {
    fakeAsync((async) {
      watchdog.offline = true;
      watchdog.onStatus(buildSyncStatus(connecting: true));

      async.elapse(watchdog.timeout * 2);

      expect(watchdog.stalled.value, isFalse);
      expect(records, isEmpty);
    });
  });

  test('a probe misfiring under load does not restart the detection', () {
    fakeAsync((async) {
      // The reachability probe times out while a large download saturates
      // the line and recovers right after. If that restarted the clock, the
      // watchdog would never reach its timeout on exactly the connection it
      // is meant to flag.
      watchdog.onStatus(buildSyncStatus(connecting: true));
      async.elapse(watchdog.timeout - const Duration(seconds: 10));

      watchdog.offline = true;
      watchdog.offline = false;
      watchdog.onStatus(buildSyncStatus(connecting: true));

      async.elapse(const Duration(seconds: 11));
      expect(watchdog.stalled.value, isTrue);
    });
  });

  test('going offline clears the flag and reports nothing further', () {
    fakeAsync((async) {
      watchdog.onStatus(buildSyncStatus(connecting: true));
      async.elapse(watchdog.timeout);
      expect(watchdog.stalled.value, isTrue);

      watchdog.offline = true;
      expect(watchdog.stalled.value, isFalse);

      async.elapse(watchdog.timeout * 2);
      expect(watchdog.stalled.value, isFalse);
    });
  });

  test('re-arms on the next status once the backend answers again', () {
    fakeAsync((async) {
      watchdog.offline = true;
      watchdog.onStatus(buildSyncStatus(connecting: true));
      async.elapse(watchdog.timeout);
      expect(watchdog.stalled.value, isFalse);

      watchdog.offline = false;
      watchdog.onStatus(buildSyncStatus(connecting: true));
      async.elapse(watchdog.timeout);

      expect(watchdog.stalled.value, isTrue);
    });
  });

  test('re-arms after reset() for the next connection epoch', () {
    fakeAsync((async) {
      watchdog.onStatus(buildSyncStatus(connected: true, lastSyncedAt: DateTime(2026, 7, 23)));
      watchdog.reset();

      watchdog.onStatus(buildSyncStatus(connecting: true));
      async.elapse(watchdog.timeout);

      expect(watchdog.stalled.value, isTrue);
    });
  });
}
