/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020,  wger Team
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
  late ApiClient apiClient;

  DjangoConnector({String? baseUrl}) {
    this.baseUrl = baseUrl ?? 'http://localhost:8000';

    apiClient = ApiClient(this.baseUrl);
  }

  /// Get a token to authenticate against the PowerSync instance.
  @override
  Future<PowerSyncCredentials?> fetchCredentials() async {
    // Somewhat contrived to illustrate usage, see auth docs here:
    // https://docs.powersync.com/usage/installation/authentication-setup/custom
    final session = await apiClient.getPowersyncToken();

    // note: we don't set userId and expires property here. not sure if needed
    return PowerSyncCredentials(
      endpoint: session['powersync_url'],
      token: session['token'],
    );
  }

  /// Transform a record before sending it to the backend.
  Map<String, dynamic> _genericTransform(Map<String, dynamic>? src, String id) {
    final out = <String, dynamic>{'id': id};
    if (src == null) {
      return out;
    }

    src.forEach((k, v) {
      if (k == 'id') {
        return;
      }
      final key = k.endsWith('_id') ? k.substring(0, k.length - 3) : k;

      if (v is DateTime) {
        out[key] = v.toUtc().toIso8601String();
        return;
      }

      out[key] = v;
    });
    return out;
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
          'data': _genericTransform(op.opData, op.id),
          // 'data': {'id': op.id, ...?op.opData},
        };

        logger.finer('Uploading record $record to server with operation ${op.op}');

        switch (op.op) {
          case UpdateType.put:
            await apiClient.upsert(record);
            break;
          case UpdateType.patch:
            await apiClient.update(record);
            break;
          case UpdateType.delete:
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
