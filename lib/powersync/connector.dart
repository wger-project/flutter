// This file performs setup of the PowerSync database
import 'package:logging/logging.dart';
import 'package:powersync/powersync.dart';
import 'package:wger/powersync/api_client.dart';

final logger = Logger('powersync-django');

/// Postgres Response codes that we cannot recover from by retrying.
final List<RegExp> fatalResponseCodes = [
  // Class 22 — Data Exception
  // Examples include data type mismatch.
  RegExp(r'^22...$'),
  // Class 23 — Integrity Constraint Violation.
  // Examples include NOT NULL, FOREIGN KEY and UNIQUE violations.
  RegExp(r'^23...$'),
  // INSUFFICIENT PRIVILEGE - typically a row-level security violation
  RegExp(r'^42501$'),
];

class DjangoConnector extends PowerSyncBackendConnector {
  late String baseUrl;
  late String powersyncUrl;
  late ApiClient apiClient;

  DjangoConnector({String? baseUrl, String? powersyncUrl}) {
    this.baseUrl = baseUrl ?? 'http://localhost:8000';
    this.powersyncUrl = powersyncUrl ?? 'http://localhost:8080';

    apiClient = ApiClient(this.baseUrl);
  }

  /// Get a token to authenticate against the PowerSync instance.
  @override
  Future<PowerSyncCredentials?> fetchCredentials() async {
    // Somewhat contrived to illustrate usage, see auth docs here:
    // https://docs.powersync.com/usage/installation/authentication-setup/custom
    // final wgerSession = await apiClient.getWgerJWTToken();
    final session = await apiClient.getPowersyncToken();
    // note: we don't set userId and expires property here. not sure if needed
    logger.info('Powersync Url: $powersyncUrl');
    return PowerSyncCredentials(
      endpoint: powersyncUrl,
      token: session['token'],
    );
  }

  // Upload pending changes to Postgres via Django backend
  // this is generic. on the django side we inspect the request and do model-specific operations
  // would it make sense to do api calls here specific to the relevant model? (e.g. put to a todo-specific endpoint)
  @override
  Future<void> uploadData(PowerSyncDatabase database) async {
    final transaction = await database.getNextCrudTransaction();

    if (transaction == null) {
      return;
    }

    try {
      for (final op in transaction.crud) {
        final record = {
          'table': op.table,
          'data': {'id': op.id, ...?op.opData},
        };

        logger.fine('Uploading record $record');
        logger.fine(op.clientId);
        logger.fine(op.metadata);

        switch (op.op) {
          case UpdateType.put:
            logger.fine('Upserting record');
            await apiClient.upsert(record);
            break;
          case UpdateType.patch:
            logger.fine('Patching record');
            await apiClient.update(record);
            break;
          case UpdateType.delete:
            logger.fine('Deleting record');
            await apiClient.delete(record);
            break;
        }
      }
      await transaction.complete();
    } on Exception catch (e) {
      logger.severe('Error uploading data', e);
      // Error may be retryable - e.g. network error or temporary server error.
      // Throwing an error here causes this call to be retried after a delay.
      rethrow;
    }
  }
}
