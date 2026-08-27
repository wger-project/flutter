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

import 'package:drift/drift.dart' show DriftSqlType, Table, TableInfo;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:powersync/powersync.dart' show SyncStatus;
import 'package:wger/core/http_overrides.dart';
import 'package:wger/database/powersync/database.dart';
import 'package:wger/database/powersync/powersync.dart';
import 'package:wger/powersync/schema.dart';

/// PowerSync manages the JSON view tables itself, but the raw tables are
/// materialised from hand-written DDL. Nothing fails loudly when that DDL and
/// the Drift definitions drift apart: the column is simply not there, and
/// every read of it comes back empty.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Deliberately without `createMigrator().createAll()`: the raw tables have
  /// to come from the DDL under test. On a database that already carries
  /// Drift's own schema the `CREATE TABLE IF NOT EXISTS` would be a no-op and
  /// the comparison would check Drift against itself.
  late DriftPowersyncDatabase db;

  setUp(() => db = DriftPowersyncDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  TableInfo<Table, Object?> driftTable(String name) =>
      db.allTables.firstWhere((table) => table.actualTableName == name);

  /// Column name to SQLite type, as the DDL actually creates them.
  Future<Map<String, String>> createdColumns(String table) async {
    await db.customStatement(rawTableStatements[table]!);
    final rows = await db.customSelect('PRAGMA table_info($table)').get();

    return {
      for (final row in rows) row.read<String>('name'): row.read<String>('type'),
    };
  }

  test('every raw table in the schema has a statement', () {
    expect(
      rawTableStatements.keys.toSet(),
      schema.rawTables.map((table) => table.name).toSet(),
    );
  });

  test('the created columns match the Drift definitions', () async {
    for (final table in rawTableStatements.keys) {
      expect(
        (await createdColumns(table)).keys.toSet(),
        driftTable(table).$columns.map((column) => column.name).toSet(),
        reason: 'the raw table $table does not carry every Drift column',
      );
    }
  });

  test('the created columns use the affinity of their Drift type', () async {
    // `store_date_time_values_as_text` is on, so a Drift DateTimeColumn has to
    // be created as TEXT here as well
    const expectedAffinity = {
      DriftSqlType.string: 'TEXT',
      DriftSqlType.int: 'INTEGER',
      DriftSqlType.dateTime: 'TEXT',
    };

    for (final table in rawTableStatements.keys) {
      final created = await createdColumns(table);

      for (final column in driftTable(table).$columns) {
        final expected = expectedAffinity[column.type];
        expect(
          expected,
          isNotNull,
          reason: 'no affinity defined for ${column.type} ($table.${column.name})',
        );
        expect(
          created[column.name],
          expected,
          reason:
              '$table.${column.name} is created as ${created[column.name]}, '
              'but Drift reads it as ${column.type}',
        );
      }
    }
  });

  group('syncOptionsFor', () {
    tearDown(() {
      WgerHttpOverrides.allowSelfSignedCerts = false;
      WgerHttpOverrides.trustedHost = null;
    });

    test('hands the sync isolate a client factory while the server cert is exempt', () {
      WgerHttpOverrides.allowSelfSignedCerts = true;
      WgerHttpOverrides.trustServer('https://gym.example.com');

      expect(syncOptionsFor('https://gym.example.com')?.httpClient, isNotNull);
    });

    test('is null without an exemption', () {
      expect(syncOptionsFor('https://gym.example.com'), isNull);
    });
  });

  group('skipAdapterReconnect', () {
    // SyncStatus has only @internal constructors, so there is no public way
    // to build one in a test.
    SyncStatus status({bool connected = false, bool connecting = false, Object? downloadError}) =>
        // ignore: invalid_use_of_internal_member
        SyncStatus(
          connected: connected,
          connecting: connecting,
          lastSyncedAt: null,
          downloadProgress: null,
          downloading: false,
          uploading: false,
          downloadError: downloadError,
          uploadError: null,
          priorityStatusEntries: const [],
          streamSubscriptions: null,
        );

    test('skips only while the stream is up', () {
      expect(skipAdapterReconnect(status(connected: true)), isTrue);
    });

    test('still reconnects in every other state', () {
      // connecting and the retry loop after an error are the "retry now"
      // cases an adapter comeback must be able to interrupt.
      expect(skipAdapterReconnect(status(connecting: true)), isFalse);
      expect(skipAdapterReconnect(status(downloadError: Exception('stream died'))), isFalse);
      expect(skipAdapterReconnect(status()), isFalse);
    });
  });

  group('getDatabasePath', () {
    const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
    late TestDefaultBinaryMessenger messenger;
    late Directory supportDir;

    File inRoot(String suffix) => File(join(supportDir.path, 'powersync-wger.db$suffix'));

    File inDbDir(String suffix) =>
        File(join(supportDir.path, dbDirectoryName, 'powersync-wger.db$suffix'));

    setUp(() {
      supportDir = Directory.systemTemp.createTempSync('wger_db_path');
      messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(
        pathProviderChannel,
        (call) async => call.method == 'getApplicationSupportDirectory' ? supportDir.path : null,
      );
    });

    tearDown(() {
      messenger.setMockMethodCallHandler(pathProviderChannel, null);
      supportDir.deleteSync(recursive: true);
    });

    test('puts the database in its own subdirectory', () async {
      expect(await getDatabasePath(), inDbDir('').path);
      expect(Directory(join(supportDir.path, dbDirectoryName)).existsSync(), isTrue);
    });

    test('takes the sidecars along when it moves an older database', () async {
      // A database moved without its WAL loses everything the WAL still holds
      for (final suffix in ['', '-wal', '-shm']) {
        inRoot(suffix).writeAsStringSync('old$suffix');
      }

      await getDatabasePath();

      for (final suffix in ['', '-wal', '-shm']) {
        expect(inRoot(suffix).existsSync(), isFalse, reason: '$suffix stayed behind');
        expect(inDbDir(suffix).readAsStringSync(), 'old$suffix');
      }
    });

    test('never overwrites the database it already moved', () async {
      Directory(join(supportDir.path, dbDirectoryName)).createSync();
      inDbDir('').writeAsStringSync('current');
      inRoot('').writeAsStringSync('stale');

      await getDatabasePath();

      expect(inDbDir('').readAsStringSync(), 'current');
    });

    test('hands back a path even when the move fails', () async {
      // A directory where the file belongs: File.existsSync() says no, so the
      // move is attempted and fails. The app has to start regardless.
      inRoot('').writeAsStringSync('old');
      Directory(inDbDir('').path).createSync(recursive: true);

      expect(await getDatabasePath(), inDbDir('').path);
      expect(inRoot('').existsSync(), isTrue);
    });
  });

  group('excludeFromBackup', () {
    const storageChannel = MethodChannel('de.wger.flutter/storage');
    late TestDefaultBinaryMessenger messenger;

    setUp(() => messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger);
    tearDown(() => messenger.setMockMethodCallHandler(storageChannel, null));

    test('hands the platform the directory', () async {
      final calls = <MethodCall>[];
      messenger.setMockMethodCallHandler(storageChannel, (call) async {
        calls.add(call);
        return null;
      });

      await excludeFromBackup('/support/database');

      expect(calls.single.method, 'excludeFromBackup');
      expect(calls.single.arguments, {'path': '/support/database'});
    });

    test('shrugs off a platform without the channel', () async {
      await expectLater(excludeFromBackup('/support/database'), completes);
    });

    test('shrugs off a platform that refuses', () async {
      messenger.setMockMethodCallHandler(
        storageChannel,
        (call) async => throw PlatformException(code: 'EXCLUDE_FROM_BACKUP_FAILED'),
      );

      await expectLater(excludeFromBackup('/support/database'), completes);
    });
  });
}
