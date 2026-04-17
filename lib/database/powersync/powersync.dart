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

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:powersync/powersync.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:wger/powersync/connector.dart';
import 'package:wger/powersync/schema.dart';
import 'package:wger/providers/wger_base_riverpod.dart';

part 'powersync.g.dart';

@Riverpod(keepAlive: true)
Future<PowerSyncDatabase> powerSyncInstance(Ref ref) async {
  final db = PowerSyncDatabase(
    schema: schema,
    path: await _getDatabasePath(),
    logger: attachedLogger,
  );
  await db.initialize();

  final baseProvider = ref.read(wgerBaseProvider);
  final currentConnector = DjangoConnector(baseUrl: baseProvider.serverUrl!);

  db.connect(connector: currentConnector);
  ref.onDispose(db.close);

  return db;
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
