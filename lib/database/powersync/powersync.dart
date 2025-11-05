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

  final currentConnector = DjangoConnector(baseUrl: baseProvider.auth.serverUrl!);
  db.connect(connector: currentConnector);

  // if (ref.read(sessionProvider).value != null) {
  //   currentConnector = DjangoConnector();
  //   db.connect(connector: currentConnector);
  // }

  // final instance = Supabase.instance.client.auth;
  // final sub = instance.onAuthStateChange.listen((data) async {
  //   final event = data.event;
  //   if (event == AuthChangeEvent.signedIn) {
  //     currentConnector = DjangoConnector();
  //     db.connect(connector: currentConnector!);
  //   } else if (event == AuthChangeEvent.signedOut) {
  //     currentConnector = null;
  //     await db.disconnect();
  //   } else if (event == AuthChangeEvent.tokenRefreshed) {
  //     currentConnector?.prefetchCredentials();
  //   }
  // });
  // ref.onDispose(sub.cancel);
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
  const dbFilename = 'powersync-demo.db';
  // getApplicationSupportDirectory is not supported on Web
  if (kIsWeb) {
    return dbFilename;
  }
  final dir = await getApplicationSupportDirectory();
  return join(dir.path, dbFilename);
}
