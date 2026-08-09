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

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:wger/core/log_file_store.dart';

void main() {
  // The store registers an AppLifecycleListener, which needs a binding
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory directory;
  late PersistentLogStore store;

  setUp(() {
    directory = Directory.systemTemp.createTempSync('wger-logs-test');
    store = PersistentLogStore();
  });

  tearDown(() {
    store.dispose();
    directory.deleteSync(recursive: true);
  });

  Future<void> start(String version) =>
      store.init(directory: directory.path, startMarker: '--- app start, $version ---');

  test('writes the start marker and the queued entries', () async {
    await start('1.0.0+1');
    store.add(LogRecord(Level.INFO, 'this is a test', 'testLogger'));
    await store.flush();

    final content = File('${directory.path}/wger-logs.0.txt').readAsStringSync();
    expect(content, contains('--- app start, 1.0.0+1 ---'));
    expect(content, contains('this is a test'));
  });

  test('nothing is written before the next flush', () async {
    await start('1.0.0+1');
    store.add(LogRecord(Level.INFO, 'this is a test', 'testLogger'));

    final content = File('${directory.path}/wger-logs.0.txt').readAsStringSync();
    expect(content, isNot(contains('this is a test')));
  });

  test('the entries of the previous run survive a restart', () async {
    await start('1.0.0+1');
    store.add(LogRecord(Level.INFO, 'before the restart', 'testLogger'));
    await store.flush();

    await start('1.0.0+2');

    expect(store.previousRunLines.join('\n'), contains('before the restart'));
    expect(store.previousRunLines.join('\n'), contains('--- app start, 1.0.0+1 ---'));

    // The new run starts with an empty file of its own
    final content = File('${directory.path}/wger-logs.0.txt').readAsStringSync();
    expect(content, contains('--- app start, 1.0.0+2 ---'));
    expect(content, isNot(contains('before the restart')));
  });

  test('multi-line entries are restored as one entry', () async {
    await start('1.0.0+1');
    store.add(
      LogRecord(
        Level.WARNING,
        'boom',
        'testLogger',
        Exception('nope'),
        StackTrace.fromString('#0 first frame\n#1 second frame'),
      ),
    );
    await store.flush();

    await start('1.0.0+2');

    final restored = store.previousRunLines.where((entry) => entry.contains('boom'));
    expect(restored, hasLength(1));
    expect(restored.first, contains('#0 first frame'));
    expect(restored.first, contains('#1 second frame'));
  });

  test('entries logged before the store is ready are kept, but bounded', () async {
    for (var i = 0; i < 300; i++) {
      store.add(LogRecord(Level.INFO, 'early log $i', 'testLogger'));
    }

    await start('1.0.0+1');
    await store.flush();

    final content = File('${directory.path}/wger-logs.0.txt').readAsStringSync();
    expect(content, contains('early log 299'));
    expect(content, isNot(contains('early log 0\n')));
  });

  test('the files stay bounded', () async {
    await start('1.0.0+1');
    for (var i = 0; i < 4000; i++) {
      store.add(LogRecord(Level.INFO, 'this is log $i with some padding text', 'testLogger'));
      await store.flush();
    }

    final current = File('${directory.path}/wger-logs.0.txt').lengthSync();
    final older = File('${directory.path}/wger-logs.1.txt').lengthSync();
    expect(current + older, lessThan(512 * 1024));

    // Rotating keeps the newest entries
    await start('1.0.0+2');
    expect(store.previousRunLines.last, contains('this is log 3999'));
  });
}
