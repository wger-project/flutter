// This file performs setup of the PowerSync database
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:powersync/powersync.dart';
import 'package:wger/powersync/connector.dart';
import 'package:wger/powersync/schema.dart';

final logger = Logger('powersync-django');

/// Global reference to the database
late final PowerSyncDatabase db;

// Hacky flag to ensure the database is only initialized once, better to do this with listeners
bool _dbInitialized = false;

Future<String> getDatabasePath() async {
  final dir = await getApplicationSupportDirectory();
  return join(dir.path, 'powersync-demo.db');
}

// opens the database and connects if logged in
Future<void> openDatabase(bool connect, String baseUrl, String powersyncUrl) async {
  // Open the local database
  if (!_dbInitialized) {
    db = PowerSyncDatabase(schema: schema, path: await getDatabasePath(), logger: attachedLogger);
    await db.initialize();
    _dbInitialized = true;
  }

  if (connect) {
    // If the user is already logged in, connect immediately.
    // Otherwise, connect once logged in.

    final currentConnector = DjangoConnector(baseUrl: baseUrl, powersyncUrl: powersyncUrl);
    db.connect(connector: currentConnector);

    // TODO: should we respond to login state changing? like here:
    // https://www.powersync.com/blog/flutter-tutorial-building-an-offline-first-chat-app-with-supabase-and-powersync#implement-auth-methods
  }
}

/// Explicit sign out - clear database and log out.
Future<void> logout() async {
  await db.disconnectAndClear();
}
