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

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:powersync/powersync.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:wger/powersync/api_client.dart';
import 'package:wger/powersync/connector.dart';
import 'package:wger/powersync/schema.dart';
import 'package:wger/providers/auth_http_client.dart';
import 'package:wger/providers/network_provider.dart';
import 'package:wger/providers/wger_base.dart';

part 'powersync.g.dart';

final _logger = Logger('powersync');

PowerSyncDatabase? _builtInstance;

/// The PowerSync database once [powerSyncInstanceProvider] has finished
/// building, otherwise null.
///
/// Synchronous, build-free accessor for callers that should act on the DB only
/// when it already exists (the auth notifier's session-reset paths). Awaiting
/// [powerSyncInstanceProvider] through `ref` would instead be async and would
/// build the DB on demand, the opposite of the no-op-when-absent behaviour
/// those paths need.
PowerSyncDatabase? get builtPowerSyncInstance => _builtInstance;

@Riverpod(keepAlive: true)
Future<PowerSyncDatabase> powerSyncInstance(Ref ref) async {
  final db = PowerSyncDatabase(
    schema: schema,
    path: await _getDatabasePath(),
    logger: attachedLogger,
  );
  await db.initialize();
  await _createRawTables(db);
  _builtInstance = db;

  final client = ref.read(authenticatedHttpClientProvider);

  // Connect to the sync service only while the device is online. PowerSync's
  // own retry loop would otherwise log a credential error on every iteration
  // against an unreachable backend
  void syncConnection(bool isOnline) {
    if (isOnline) {
      final serverUrl = ref.read(wgerBaseProvider).serverUrl;
      if (serverUrl != null) {
        connectPowerSync(db, serverUrl, client);
      }
    } else {
      db.disconnect();
    }
  }

  syncConnection(ref.read(networkStatusProvider));
  ref.listen(networkStatusProvider, (_, isOnline) => syncConnection(isOnline));

  ref.onDispose(() {
    _builtInstance = null;
    db.close();
  });

  return db;
}

/// Materialise the native SQLite tables for the raw entries declared in
/// [schema]. PowerSync only manages the JSON view tables itself, so any
/// `RawTable` entry must have its `CREATE TABLE`/`CREATE INDEX` statements
/// applied by us.
///
/// Skips all work when the raw tables already exist, so warm restarts don't
/// take a write lock on the DB.
Future<void> _createRawTables(PowerSyncDatabase db) async {
  // Not STRICT: keep SQLite's type affinity behaviour so PowerSync's
  // inferred inserts can bind values as they arrive from the JSON wire
  // protocol without us having to coerce types up front.
  const rawTables = ['exercises_exercise', 'exercises_translation'];
  final existing = await db.getAll(
    'SELECT name FROM sqlite_master '
    'WHERE type = ? AND name IN (${rawTables.map((_) => '?').join(', ')})',
    ['table', ...rawTables],
  );

  if (existing.length == rawTables.length) {
    return;
  }

  await db.writeTransaction((tx) async {
    await tx.execute('''
      CREATE TABLE IF NOT EXISTS exercises_exercise(
        id TEXT NOT NULL PRIMARY KEY,
        uuid TEXT,
        category_id INTEGER,
        variation_group TEXT,
        created TEXT,
        last_update TEXT
      )
    ''');
    await tx.execute(
      'CREATE INDEX IF NOT EXISTS exercises_exercise__category '
      'ON exercises_exercise(category_id)',
    );
    await tx.execute(
      'CREATE INDEX IF NOT EXISTS exercises_exercise__variation '
      'ON exercises_exercise(variation_group)',
    );

    await tx.execute('''
      CREATE TABLE IF NOT EXISTS exercises_translation(
        id TEXT NOT NULL PRIMARY KEY,
        uuid TEXT,
        language_id INTEGER,
        exercise_id INTEGER,
        description TEXT,
        name TEXT,
        created TEXT,
        last_update TEXT
      )
    ''');
    await tx.execute(
      'CREATE INDEX IF NOT EXISTS exercises_translation__language '
      'ON exercises_translation(language_id)',
    );
    await tx.execute(
      'CREATE INDEX IF NOT EXISTS exercises_translation__exercise '
      'ON exercises_translation(exercise_id)',
    );
  });
}

/// Creates a fresh [DjangoConnector] for [baseUrl] and connects [db] to it.
/// Used both at initial creation and after a logout/login cycle to pick up
/// the new user's server URL / credentials. [client] is the authenticated
/// HTTP client (see [authenticatedHttpClientProvider]); the connector reuses
/// it for its REST calls so the same `Authorization` injection and
/// pre-emptive refresh apply.
void connectPowerSync(PowerSyncDatabase db, String baseUrl, http.Client client) {
  db.connect(
    connector: DjangoConnector(
      baseUrl: baseUrl,
      apiClient: ApiClient(baseUrl, client: client),
    ),
  );
}

final _syncStatusInternal = StreamProvider<SyncStatus?>((ref) {
  return Stream.fromFuture(
    ref.watch(powerSyncInstanceProvider.future),
  ).asyncExpand<SyncStatus?>((db) => db.statusStream).startWith(null);
});

final syncStatus = Provider((ref) {
  // ignore: invalid_use_of_internal_member
  return ref.watch(_syncStatusInternal).value ?? const SyncStatus();
});

@riverpod
bool didCompleteSync(Ref ref, [StreamPriority? priority]) {
  final status = ref.watch(syncStatus);
  if (priority != null) {
    return status.statusForPriority(priority).hasSynced ?? false;
  } else {
    return status.hasSynced ?? false;
  }
}

Future<String> _getDatabasePath() async {
  const dbFilename = 'powersync-wger.db';

  // getApplicationSupportDirectory is not supported on Web
  if (kIsWeb) {
    return dbFilename;
  }
  final dir = await getApplicationSupportDirectory();
  return join(dir.path, dbFilename);
}

/// Deletes the on-disk PowerSync SQLite files (main DB plus WAL/SHM/journal
/// sidecars). Used to purge a previous user's data on login as a different
/// user when [powerSyncInstanceProvider] has not been built yet, so the
/// usual `disconnectAndClear()` route is unavailable.
///
/// Best-effort: missing files are treated as success, individual delete
/// failures are logged and swallowed so a single locked sidecar doesn't
/// block the rest. On web the database is backed by IndexedDB rather than
/// a real file, so this is a no-op there.
Future<void> deletePowerSyncDatabaseFile() async {
  if (kIsWeb) {
    _logger.warning('deletePowerSyncDatabaseFile: not supported on web, skipping');
    return;
  }
  final path = await _getDatabasePath();
  for (final suffix in ['', '-wal', '-shm', '-journal']) {
    final file = File('$path$suffix');
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e, s) {
      _logger.warning('deletePowerSyncDatabaseFile: failed to delete ${file.path}', e, s);
    }
  }
}
