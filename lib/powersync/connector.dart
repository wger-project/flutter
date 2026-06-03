/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
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
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:powersync/powersync.dart';
import 'package:wger/core/error_dialogs.dart';
import 'package:wger/helpers/jwt.dart';
import 'package:wger/powersync/api_client.dart';

final logger = Logger('powersync-django');

/// Exception thrown when the wger backend returned a 200 response whose
/// body indicates that the operation was rejected (validation failure,
/// missing object, ownership violation, unknown table…). Carries the
/// raw error map so the global error dialog can display the detail.
class BackendUploadException implements Exception {
  final String table;
  final UpdateType op;
  final String error;
  final Object? details;

  BackendUploadException({
    required this.table,
    required this.op,
    required this.error,
    required this.details,
  });

  @override
  String toString() {
    final detailsStr = details == null ? '' : '\n$details';
    return 'Backend rejected $op on $table: $error$detailsStr';
  }
}

class DjangoConnector extends PowerSyncBackendConnector {
  final String baseUrl;
  final ApiClient apiClient;

  /// IDs of CRUD operations that already triggered a user-facing
  /// rejection dialog this session. Without this gate the same
  /// permanent-failure op would re-pop the dialog on every sync tick
  /// (PowerSync keeps re-driving `uploadData` until the transaction
  /// is completed, and our `transaction.complete()` only fires once
  /// the loop finishes, so we'd see the dialog at every iteration).
  /// Resets on app restart.
  final Set<String> _reportedFailedOps = {};

  DjangoConnector({required this.baseUrl, required this.apiClient});

  /// Get a token to authenticate against the PowerSync instance.
  @override
  Future<PowerSyncCredentials?> fetchCredentials() async {
    // See the auth docs here:
    // https://docs.powersync.com/usage/installation/authentication-setup/custom
    final Map<String, dynamic> session;
    try {
      session = await apiClient.getPowersyncToken();
    } on http.ClientException catch (e) {
      // Backend unreachable (offline). Returning null skips this attempt;
      // PowerSync retries on its own schedule. Without this, the raw
      // SocketException stack trace floods the logs on every retry.
      logger.fine('PowerSync credential fetch skipped, backend unreachable: ${e.message}');
      return null;
    } on SocketException catch (e) {
      logger.fine('PowerSync credential fetch skipped, backend unreachable: ${e.message}');
      return null;
    }

    final token = session['token'] as String;
    final payload = decodeJwtPayload(token);
    return PowerSyncCredentials(
      endpoint: session['powersync_url'],
      token: token,
      userId: payload?['sub']?.toString(),
      expiresAt: jwtExp(payload),
    );
  }

  /// Date-only fields per table.
  ///
  /// PowerSync serialises every SQLite `DateTime` column as an ISO-8601 timestamp
  /// (e.g. `2024-11-01T00:00:00.000Z`), but Django's `DateField` only accepts
  /// `YYYY-MM-DD`. For these columns we strip the time component before uploading.
  ///
  /// Keep in sync with `models.DateField` columns in the Django side.
  /// `auto_now_add=True` fields (e.g. `nutrition_nutritionplan.creation_date`)
  /// are read-only on the serializer and therefore safe to leave out.
  static const Map<String, Set<String>> _dateOnlyFields = {
    'manager_routine': {'start', 'end'},
    'manager_workoutsession': {'date'},
    'nutrition_nutritionplan': {'start', 'end'},
    'gallery_image': {'date'},
  };

  /// Transform a record before sending it to the backend.
  ///
  /// Note that PowerSync hands us [op.opData] as native SQLite primitives only
  /// (`null`, `int`, `double`, `String`, `Uint8List`).
  ///
  ///   * inject the row [id] (PowerSync stores it separately from the
  ///     payload),
  ///   * strip the `_id` suffix from foreign-key column names so the
  ///     Django serializers see `category` / `routine` / etc,
  ///   * trim the time component from date-only fields (see
  ///     [_dateOnlyFields]).
  @visibleForTesting
  Map<String, dynamic> genericTransform(
    String table,
    Map<String, dynamic>? src,
    String id,
  ) => _genericTransform(table, src, id);

  Map<String, dynamic> _genericTransform(
    String table,
    Map<String, dynamic>? src,
    String id,
  ) {
    final out = <String, dynamic>{'id': id};
    if (src == null) {
      return out;
    }

    final dateFields = _dateOnlyFields[table] ?? const <String>{};

    src.forEach((k, v) {
      if (k == 'id') {
        return;
      }
      final key = k.endsWith('_id') ? k.substring(0, k.length - 3) : k;
      out[key] = (dateFields.contains(key) && v is String && v.length >= 10)
          ? v.substring(0, 10)
          : v;
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

    await processTransaction(transaction);
  }

  /// Uploads every op in [transaction] and, on success, completes it so the
  /// ops leave the local queue. Backend rejections are reported but swallowed
  /// (see [_handleUploadResponse]), and a network error rethrows so PowerSync
  /// retries the whole transaction once the backend is reachable again.
  @visibleForTesting
  Future<void> processTransaction(CrudTransaction transaction) async {
    try {
      for (final op in transaction.crud) {
        final record = {
          'table': op.table,
          'data': _genericTransform(op.table, op.opData, op.id),
        };

        // logger.finer('Uploading record $record to server with operation ${op.op}');

        final http.Response response;
        switch (op.op) {
          case UpdateType.put:
            response = await apiClient.upsert(record);
            break;
          case UpdateType.patch:
            response = await apiClient.update(record);
            break;
          case UpdateType.delete:
            response = await apiClient.delete(record);
            break;
        }

        _handleUploadResponse(op, response);
      }
      await transaction.complete();
    } on http.ClientException catch (e) {
      // Backend unreachable (offline or down). The transaction stays queued;
      // rethrowing lets PowerSync retry it once the backend is reachable.
      logger.fine('Upload deferred, backend unreachable: ${e.message}');
      rethrow;
    } on SocketException catch (e) {
      logger.fine('Upload deferred, backend unreachable: ${e.message}');
      rethrow;
    } on Exception catch (e) {
      logger.severe('Error uploading data', e);
      // Error may be retryable - e.g. network error or temporary server error.
      // Throwing an error here causes this call to be retried after a delay.
      rethrow;
    }
  }

  /// Inspects the backend response for a given CRUD op. If the body reports a
  /// logical / validation rejection we surface it via the global error dialog
  /// but do **not** rethrow, otherwise that would trigger a PowerSync retry loop.
  void _handleUploadResponse(CrudEntry op, http.Response response) {
    if (response.statusCode != 200 || response.body.isEmpty) {
      return;
    }

    final Object? decoded;
    try {
      decoded = json.decode(response.body);
    } on FormatException {
      // Non-JSON response on a 200, uncommon but harmless to ignore.
      return;
    }
    if (decoded is! Map<String, dynamic> || !decoded.containsKey('error')) {
      return;
    }

    if (!_reportedFailedOps.add(op.id)) {
      // Already shown for this operation in the current session.
      return;
    }

    final exception = BackendUploadException(
      table: op.table,
      op: op.op,
      error: decoded['error']?.toString() ?? 'Unknown error',
      details: decoded['details'],
    );
    logger.warning('Backend rejected upload', exception);
    showGeneralErrorDialog(exception, StackTrace.current);
  }
}
