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
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:powersync/powersync.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:wger/core/http_overrides.dart';
import 'package:wger/core/logs.dart';
import 'package:wger/core/network/auth_http_client.dart';
import 'package:wger/core/network/network_provider.dart';
import 'package:wger/core/network/wger_base.dart';
import 'package:wger/powersync/api_client.dart';
import 'package:wger/powersync/connector.dart';
import 'package:wger/powersync/schema.dart';
import 'package:wger/powersync/sync_watchdog.dart';

part 'powersync.g.dart';

final _logger = Logger('powersync');
const _storageChannel = MethodChannel('de.wger.flutter/storage');
const _dbFilename = 'powersync-wger.db';

/// The database file plus the sidecars SQLite keeps next to it.
const _dbFileSuffixes = ['', '-wal', '-shm', '-journal'];

/// Subdirectory of the application support directory holding the database, so
/// the main file and its sidecars leave device backups as one unit: iOS marks
/// it `isExcludedFromBackup`, Android lists it in res/xml/backup_rules.xml.
@visibleForTesting
const dbDirectoryName = 'database';

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

/// Watches the sync status for a stream that keeps reconnecting without ever
/// delivering data (e.g. blocked by a VPN or firewall) and flags it, see
/// [SyncStreamWatchdog]. Fed from the DB's status stream by
/// [powerSyncInstanceProvider].
final syncWatchdogProvider = Provider<SyncStreamWatchdog>((ref) {
  final watchdog = SyncStreamWatchdog();
  ref.onDispose(watchdog.dispose);
  return watchdog;
});

@Riverpod(keepAlive: true)
Future<PowerSyncDatabase> powerSyncInstance(Ref ref) async {
  final db = PowerSyncDatabase(
    schema: schema,
    path: await getDatabasePath(),
    // The SDK's retry loop logs identical lines every few seconds during an
    // outage; collapsed so they don't crowd out the exportable log store.
    logger: repeatCollapsingLogger('PowerSync'),
  );
  await db.initialize();
  await _createRawTables(db);
  _builtInstance = db;

  final client = ref.read(authenticatedHttpClientProvider);
  final watchdog = ref.read(syncWatchdogProvider);

  // Whether any data ever arrived is the first question in every sync support
  // case, so the first checkpoint of this app run gets a log line. Later ones
  // would only repeat it. The progress is remembered from the events before
  // the checkpoint, it is already cleared again once the download finishes.
  var loggedFirstCheckpoint = false;
  SyncDownloadProgress? lastProgress;
  final statusSubscription = db.statusStream.listen((status) {
    watchdog.onStatus(status);
    lastProgress = status.downloadProgress ?? lastProgress;

    if (!loggedFirstCheckpoint && status.lastSyncedAt != null) {
      loggedFirstCheckpoint = true;
      final operations = lastProgress == null
          ? ''
          : ', ${lastProgress!.downloadedOperations} of '
                '${lastProgress!.totalOperations} operations downloaded';
      // On a warm start this is the checkpoint of an earlier run, replayed
      // from the local database, hence the timestamp.
      _logger.info(
        'Sync checkpoint received, last synced at '
        '${status.lastSyncedAt!.toUtc().toIso8601String()}$operations',
      );
    }
  });

  // Gated on the network adapter only, never on the reachability probe: a
  // probe failure is an indication, an unreachable backend is PowerSync's own
  // retry loop to handle (the connector throttles its log output while the
  // backend does not answer).
  void syncConnection(bool hasAdapter) {
    if (hasAdapter) {
      final serverUrl = ref.read(wgerBaseProvider).serverUrl;
      if (serverUrl == null) {
        _logger.info('Network adapter available, but no server configured: not connecting');
      } else if (skipAdapterReconnect(db.currentStatus)) {
        _logger.fine('Sync already connected, skipping reconnect');
      } else {
        connectPowerSync(db, serverUrl, client, watchdog, reason: 'network adapter available');
      }
    } else {
      _logger.info('No network adapter, disconnecting from the sync service');
      db.disconnect();
      // Deliberate disconnect: an offline device is not a blocked stream.
      watchdog.reset();
    }
  }

  syncConnection(ref.read(networkAdapterAvailableProvider));
  ref.listen(networkAdapterAvailableProvider, (_, hasAdapter) => syncConnection(hasAdapter));

  // The probe stays a diagnostic input for the watchdog: while short REST
  // requests fail too, a stream without checkpoints says nothing about the
  // blocked middlebox the watchdog looks for.
  watchdog.offline = !ref.read(networkStatusProvider);
  ref.listen(networkStatusProvider, (_, isOnline) => watchdog.offline = !isOnline);

  ref.onDispose(() {
    _builtInstance = null;
    statusSubscription.cancel();
    watchdog.reset();
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
/// `CREATE TABLE` statement per raw table, keyed by table name.
///
/// Not STRICT: keep SQLite's type affinity behaviour so PowerSync's inferred
/// inserts can bind values as they arrive from the JSON wire protocol without
/// us having to coerce types up front.
///
/// `id` is INTEGER, not the PowerSync-conventional TEXT, so it matches the
/// Drift `IntColumn id` and the integer `exercise_id` FK: the catalogue join
/// is then native INTEGER == INTEGER instead of relying on TEXT-vs-INTEGER
/// affinity coercion. PowerSync's string oplog id coerces to INTEGER on insert
/// (safe: Django exercise PKs are always numeric).
@visibleForTesting
const rawTableStatements = <String, String>{
  'exercises_exercise': '''
      CREATE TABLE IF NOT EXISTS exercises_exercise(
        id INTEGER NOT NULL PRIMARY KEY,
        uuid TEXT,
        category_id INTEGER,
        variation_group TEXT,
        created TEXT,
        last_update TEXT
      )
    ''',
  'exercises_translation': '''
      CREATE TABLE IF NOT EXISTS exercises_translation(
        id INTEGER NOT NULL PRIMARY KEY,
        uuid TEXT,
        language_id INTEGER,
        exercise_id INTEGER,
        description TEXT,
        name TEXT,
        created TEXT,
        last_update TEXT
      )
    ''',
};

const _rawTableIndexStatements = [
  'CREATE INDEX IF NOT EXISTS exercises_exercise__category ON exercises_exercise(category_id)',
  'CREATE INDEX IF NOT EXISTS exercises_exercise__variation ON exercises_exercise(variation_group)',
  'CREATE INDEX IF NOT EXISTS exercises_translation__language ON exercises_translation(language_id)',
  'CREATE INDEX IF NOT EXISTS exercises_translation__exercise ON exercises_translation(exercise_id)',
];

Future<void> _createRawTables(PowerSyncDatabase db) async {
  final rawTables = rawTableStatements.keys.toList();
  final existing = await db.getAll(
    'SELECT name FROM sqlite_master '
    'WHERE type = ? AND name IN (${rawTables.map((_) => '?').join(', ')})',
    ['table', ...rawTables],
  );

  if (existing.length == rawTables.length) {
    return;
  }

  await db.writeTransaction((tx) async {
    for (final statement in [...rawTableStatements.values, ..._rawTableIndexStatements]) {
      await tx.execute(statement);
    }
  });
}

/// Whether an adapter-triggered connect may be skipped: only while the stream
/// is already up. The SDK's connect() is never a no-op and would abort a
/// healthy stream; every other state (connecting, error, retry delay) still
/// reconnects, which doubles as the "retry now" signal when the adapter comes
/// back. Deliberate reconnects (login, manual retry) bypass this guard.
@visibleForTesting
bool skipAdapterReconnect(SyncStatus status) => status.connected;

/// Creates a fresh [DjangoConnector] for [baseUrl] and connects [db] to it.
/// Used both at initial creation and after a logout/login cycle to pick up
/// the new user's server URL / credentials. [client] is the authenticated
/// HTTP client (see [authenticatedHttpClientProvider]); the connector reuses
/// it for its REST calls so the same `Authorization` injection and
/// pre-emptive refresh apply.
///
/// [reason] just names the trigger in the log
void connectPowerSync(
  PowerSyncDatabase db,
  String baseUrl,
  http.Client client,
  SyncStreamWatchdog watchdog, {
  required String reason,
}) {
  _logger.info('Connecting to the sync service ($reason)');
  db.connect(
    connector: DjangoConnector(
      baseUrl: baseUrl,
      apiClient: ApiClient(baseUrl, client: client),
      client: client,
    ),
    options: syncOptionsFor(baseUrl),
  );
  // A connect that never starts the sync client emits no status event, so
  // arming the watchdog is inseparable from requesting the connection.
  watchdog.onConnectRequested();
}

/// Sync options carrying the self-signed cert exemption for [baseUrl], or
/// null when there is none. The stream downloads in a separate isolate whose
/// HTTP client does not see HttpOverrides.global, so it travels explicitly.
SyncOptions? syncOptionsFor(String baseUrl) {
  final exemptHost = kIsWeb ? null : WgerHttpOverrides.exemptHost(baseUrl);
  return exemptHost == null
      ? null
      : SyncOptions(httpClient: WgerHttpOverrides.syncHttpClientFactory(exemptHost));
}

/// Number of local changes still waiting in the upload queue. Emits again
/// whenever the queue changes, so consumers can show a live count.
final pendingUploadCountProvider = StreamProvider.autoDispose<int>((ref) async* {
  final db = await ref.watch(powerSyncInstanceProvider.future);
  yield* db
      .watch('SELECT count(*) AS count FROM ps_crud', triggerOnTables: ['ps_crud'])
      .map((rows) => rows.first['count'] as int);
});

final _syncStatusInternal = StreamProvider<SyncStatus?>((ref) {
  return Stream.fromFuture(
    ref.watch(powerSyncInstanceProvider.future),
  ).asyncExpand<SyncStatus?>((db) => db.statusStream).startWith(null);
});

final syncStatus = Provider((ref) {
  // ignore: invalid_use_of_internal_member
  return ref.watch(_syncStatusInternal).value ?? const SyncStatus.uninitialized();
});

/// Absolute path of the PowerSync database file. Creates [dbDirectoryName] and
/// moves a database left in the support directory root into it; a failed move
/// is logged and leaves the app on an empty database that syncs itself again.
@visibleForTesting
Future<String> getDatabasePath() async {
  // getApplicationSupportDirectory is not supported on Web
  if (kIsWeb) {
    return _dbFilename;
  }

  final supportDir = await getApplicationSupportDirectory();
  final dbDir = Directory(join(supportDir.path, dbDirectoryName));
  await dbDir.create(recursive: true);

  // Android declares the exclusion in its backup rules instead
  if (Platform.isIOS) {
    await excludeFromBackup(dbDir.path);
  }

  try {
    await _migrateLegacyDatabaseFiles(fromDirectory: supportDir, toDirectory: dbDir);
  } catch (e, s) {
    _logger.severe('Could not move the database into ${dbDir.path}', e, s);
  }

  return join(dbDir.path, _dbFilename);
}

/// Moves the database and its sidecars from [fromDirectory] into
/// [toDirectory], leaving behind whatever is missing or already there.
Future<void> _migrateLegacyDatabaseFiles({
  required Directory fromDirectory,
  required Directory toDirectory,
}) async {
  for (final suffix in _dbFileSuffixes) {
    final from = File(join(fromDirectory.path, '$_dbFilename$suffix'));
    final to = File(join(toDirectory.path, '$_dbFilename$suffix'));

    if (!from.existsSync() || to.existsSync()) {
      continue;
    }

    await from.rename(to.path);
  }
}

/// Asks the platform to keep [path] out of device backups. Best effort: the
/// database works either way, so a missing channel or a platform error is
/// logged rather than raised.
@visibleForTesting
Future<void> excludeFromBackup(String path) async {
  try {
    await _storageChannel.invokeMethod<void>('excludeFromBackup', {'path': path});
  } on MissingPluginException {
    _logger.warning('Could not exclude $path from backups: storage channel unavailable');
  } on PlatformException catch (e, s) {
    _logger.warning('Could not exclude $path from backups', e, s);
  }
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
  final path = await getDatabasePath();
  for (final suffix in _dbFileSuffixes) {
    final file = File('$path$suffix');
    try {
      if (file.existsSync()) {
        await file.delete();
      }
    } catch (e, s) {
      _logger.warning('deletePowerSyncDatabaseFile: failed to delete ${file.path}', e, s);
    }
  }
}
