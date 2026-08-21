/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2026 wger Team
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

import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:wger/core/logs.dart';

void main() {
  group('log store test cases', () {
    late InMemoryLogStore logStore;

    setUp(() {
      logStore = InMemoryLogStore();
      logStore.clear();
    });

    test('class returns a singleton', () {
      final logStore1 = InMemoryLogStore();
      final logStore2 = InMemoryLogStore();
      expect(identical(logStore1, logStore2), true);
    });

    test('correctly adds LogRecords', () {
      logStore.add(LogRecord(Level.FINE, 'this is fine!!!', 'testLogger'));
      logStore.add(LogRecord(Level.INFO, 'this is a test', 'testLogger'));

      expect(logStore.logs.length, 2);
      expect(logStore.getFormattedLogs(minLevel: Level.INFO).length, 1);
      expect(logStore.getFormattedLogs(minLevel: Level.FINE).length, 2);
    });

    test('total number of logs is limited', () {
      for (var i = 0; i < 600; i++) {
        logStore.add(LogRecord(Level.INFO, 'this is log $i', 'testLogger'));
      }

      expect(logStore.logs.length, 500);
      expect(logStore.logs.first.message, 'this is log 100');
    });

    test('getFormattedLogs respects maxEntries parameter', () {
      for (var i = 0; i < 10; i++) {
        logStore.add(LogRecord(Level.INFO, 'this is log $i', 'testLogger'));
      }

      final formatted = logStore.getFormattedLogs(minLevel: Level.INFO, maxEntries: 5);
      expect(formatted.length, 5);
      expect(formatted.first.contains('this is log 9'), true);
    });

    test('getFormattedLogs default returns up to 50 entries', () {
      for (var i = 0; i < 60; i++) {
        logStore.add(LogRecord(Level.INFO, 'this is log $i', 'testLogger'));
      }

      final formatted = logStore.getFormattedLogs(minLevel: Level.INFO);
      expect(formatted.length, 50);
      expect(formatted.first.contains('this is log 59'), true);
    });

    test('getFormattedLogs with maxEntries larger than available returns all', () {
      for (var i = 0; i < 3; i++) {
        logStore.add(LogRecord(Level.INFO, 'this is log $i', 'testLogger'));
      }

      final formatted = logStore.getFormattedLogs(minLevel: Level.INFO, maxEntries: 10);
      expect(formatted.length, 3);
      expect(formatted.first.contains('this is log 2'), true);
    });

    test('formatted entries include the error and the stack trace', () {
      logStore.add(
        LogRecord(
          Level.WARNING,
          'Sync service error',
          'testLogger',
          Exception('connection refused'),
          StackTrace.fromString('#0 first frame\n#1 second frame'),
        ),
      );

      final formatted = logStore.getFormattedLogs(minLevel: Level.INFO).first;
      expect(formatted, contains('Sync service error'));
      expect(formatted, contains('connection refused'));
      expect(formatted, contains('#0 first frame'));
      expect(formatted, contains('#1 second frame'));
    });

    test('formatted entries use UTC timestamps', () {
      final record = LogRecord(Level.INFO, 'this is a test', 'testLogger');
      logStore.add(record);

      final formatted = logStore.getFormattedLogs(minLevel: Level.INFO).first;
      expect(formatted, startsWith(record.time.toUtc().toIso8601String()));
      expect(formatted, contains('Z '));
    });
  });

  group('log formatting', () {
    test('long errors are clamped', () {
      final record = LogRecord(Level.WARNING, 'boom', 'testLogger', 'x' * 2000);

      expect(formatLogDetails(record).length, lessThan(1000));
      expect(formatLogDetails(record), contains('…'));
    });

    test('long stack traces are shortened', () {
      final frames = List.generate(40, (i) => '#$i some frame').join('\n');
      final record = LogRecord(
        Level.WARNING,
        'boom',
        'testLogger',
        Exception('nope'),
        StackTrace.fromString(frames),
      );

      final formatted = formatLogDetails(record);
      expect(formatted, contains('#0 some frame'));
      expect(formatted, isNot(contains('#39 some frame')));
      expect(formatted, contains('more frames'));
    });

    test('entries without an error render just the message', () {
      final record = LogRecord(Level.INFO, 'nothing to see here', 'testLogger');

      expect(formatLogDetails(record), 'nothing to see here');
    });
  });
  group('repeatCollapsingLogger', () {
    late List<LogRecord> records;
    late DateTime now;

    setUp(() {
      records = [];
      now = DateTime(2026, 8, 21, 12);
      final sub = Logger.root.onRecord.listen(records.add);
      addTearDown(sub.cancel);
    });

    Iterable<String> forwarded(String name) =>
        records.where((r) => r.loggerName == name).map((r) => r.message);

    test('a first occurrence is forwarded immediately', () {
      withClock(Clock(() => now), () {
        final logger = repeatCollapsingLogger('CollapseFirst');
        logger.warning('Sync error: Sync service error');

        expect(forwarded('CollapseFirst'), ['Sync error: Sync service error']);
      });
    });

    test('alternating messages are each collapsed on their own', () {
      // The SDK retry loop cycles two or three distinct lines every few
      // seconds; suppressing only consecutive duplicates would never fire.
      withClock(Clock(() => now), () {
        final logger = repeatCollapsingLogger('CollapseCycle');
        for (var i = 0; i < 5; i++) {
          logger.info('Starting Rust sync iteration');
          logger.warning('Sync error: Sync service error');
          now = now.add(const Duration(seconds: 5));
        }

        expect(forwarded('CollapseCycle'), [
          'Starting Rust sync iteration',
          'Sync error: Sync service error',
        ]);
      });
    });

    test('after the interval the repeat is logged again, with a count', () {
      withClock(Clock(() => now), () {
        final logger = repeatCollapsingLogger(
          'CollapseAgain',
          interval: const Duration(minutes: 5),
        );
        for (var i = 0; i < 4; i++) {
          logger.warning('Sync error: Sync service error');
          now = now.add(const Duration(minutes: 2));
        }

        expect(forwarded('CollapseAgain'), [
          'Sync error: Sync service error',
          'Sync error: Sync service error (repeated 2x since last logged)',
        ]);
      });
    });

    test('a different message passes through right away', () {
      withClock(Clock(() => now), () {
        final logger = repeatCollapsingLogger('CollapseOther');
        logger.warning('Sync error: Sync service error');
        logger.warning('Sync error: Configuration error');

        expect(
          forwarded('CollapseOther'),
          ['Sync error: Sync service error', 'Sync error: Configuration error'],
        );
      });
    });

    test('records below the log level are dropped, not tracked', () {
      Logger.root.level = Level.INFO;
      addTearDown(() => Logger.root.level = Level.ALL);

      withClock(Clock(() => now), () {
        final logger = repeatCollapsingLogger('CollapseLevel');
        logger.fine('Credentials: PowerSyncCredentials<...>');

        expect(forwarded('CollapseLevel'), isEmpty);
      });
    });
  });
}
