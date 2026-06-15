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
import 'package:wger/core/exceptions/http_exception.dart';
import 'package:wger/helpers/jwt.dart';
import 'package:wger/powersync/api_client.dart';

final logger = Logger('powersync-django');

/// Thrown for an upload status that should be retried, not discarded such as
/// HTTP status codes 5xx, 408, 429, or an unrecovered 401. Throwing leaves the
/// transaction queued for PowerSync to retry. Carries table/op/status for
/// logging and tests.
class RetryableUploadException implements Exception {
  final String table;
  final UpdateType op;
  final int statusCode;

  RetryableUploadException({
    required this.table,
    required this.op,
    required this.statusCode,
  });

  @override
  String toString() => 'Upload of $op on $table deferred: retryable status $statusCode';
}

/// What the transaction loop does with one upload response.
enum _UploadOutcome {
  /// Accepted: complete the transaction once all ops are ok.
  ok,

  /// Permanently refused: surface it but still complete, so one bad op can't
  /// block the queue.
  reject,

  /// Retryable: throw so PowerSync retries the queued transaction later.
  retry,
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

  /// Uploads every op in [transaction] and decides its fate: all accepted
  /// completes it; a permanent refusal is surfaced but still completes (so one
  /// bad op can't block the queue); a transient status (5xx, 408, 429, 401) or
  /// an unreachable backend throws, leaving it queued for PowerSync to retry.
  ///
  /// A retry re-sends the whole transaction (at-least-once), so backend handlers
  /// must be idempotent.
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

        switch (_classifyResponse(response)) {
          case _UploadOutcome.ok:
            break;
          case _UploadOutcome.reject:
            _reportRejection(op, response);
            break;
          case _UploadOutcome.retry:
            throw RetryableUploadException(
              table: op.table,
              op: op.op,
              statusCode: response.statusCode,
            );
        }
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
    } on RetryableUploadException catch (e) {
      // Stays queued for PowerSync to retry. Below severe: a brief server blip
      // is expected to clear on its own.
      logger.warning('Upload deferred: $e');
      rethrow;
    } on Exception catch (e) {
      logger.severe('Error uploading data', e);
      // Error may be retryable, e.g. a temporary server error. Throwing here
      // causes PowerSync to retry this transaction after a delay.
      rethrow;
    }
  }

  /// Classifies a single upload [response] into a [_UploadOutcome].
  _UploadOutcome _classifyResponse(http.Response response) {
    final status = response.statusCode;

    // 2xx is success, unless the backend encoded a permanent rejection as
    // 200 + `{error}` (its anti-retry-storm contract).
    if (status >= 200 && status < 300) {
      return _isErrorBody(response) ? _UploadOutcome.reject : _UploadOutcome.ok;
    }

    // Transient or retryable. 401 lands here because AuthHttpClient already
    // tried to refresh; a 401 still reaching us means the session is gone, so
    // queue the op for re-auth rather than dropping it.
    if (status >= 500 || status == 408 || status == 429 || status == 401) {
      return _UploadOutcome.retry;
    }

    // Any other 4xx is permanent (retry won't help). Expected refusals come as
    // 200 + `{error}`, so a non-200 4xx is genuinely unexpected.
    return _UploadOutcome.reject;
  }

  /// Surfaces a permanently refused op via the global error dialog, once per op
  /// per session (a re-driven transaction would otherwise re-pop it each tick).
  void _reportRejection(CrudEntry op, http.Response response) {
    if (!_reportedFailedOps.add(op.id)) {
      // Already shown for this operation in the current session.
      return;
    }

    final exception = WgerHttpException(
      response,
      source: ExceptionSource.powersync,
      context: {'table': op.table, 'op': op.op.name},
    );
    final ctx = '${op.op.name} ${op.table}';
    // 200 + {error} is the expected contract (warning); other statuses are
    // unexpected (severe).
    if (response.statusCode == 200) {
      logger.warning('Backend rejected $ctx', exception);
    } else {
      logger.severe('Unexpected permanent upload failure: $ctx', exception);
    }
    // Route through the app's central error handler (same entry point as the
    // global FlutterError/PlatformDispatcher handlers).
    handleError(exception, StackTrace.current);
  }

  /// Whether [response]'s body is a JSON object carrying an `{error}` key, the
  /// backend's contract for a permanent rejection on a 200.
  bool _isErrorBody(http.Response response) {
    if (response.body.isEmpty) {
      return false;
    }
    try {
      final decoded = json.decode(response.body);
      return decoded is Map<String, dynamic> && decoded.containsKey('error');
    } on FormatException {
      // Non-JSON body, not a structured rejection.
      return false;
    }
  }
}
