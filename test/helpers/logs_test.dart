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

import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:wger/helpers/logs.dart';

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
  });
}
