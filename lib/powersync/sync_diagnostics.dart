/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 wger Team
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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:powersync/powersync.dart'
    show CredentialsException, PowerSyncProtocolException, SyncResponseException, SyncStatus;
import 'package:wger/core/consts.dart';
import 'package:wger/database/powersync/powersync.dart' show builtPowerSyncInstance;
import 'package:wger/powersync/connector.dart' show RetryableUploadException;

final _logger = Logger('sync_diagnostics');

/// Maps an HTTP status code to a short English category label.
String _categoriseHttpStatus(int statusCode) {
  if (statusCode == 401 || statusCode == 403) {
    return 'Authentication error';
  }
  if (statusCode >= 500) {
    return 'Server error';
  }
  return 'HTTP $statusCode';
}

/// Classifies a sync error into a short English category label
String? categoriseSyncError(Object error) {
  if (error is CredentialsException) {
    return 'Authentication error';
  }

  if (error is PowerSyncProtocolException) {
    return 'Protocol error';
  }

  if (error is SyncResponseException) {
    return _categoriseHttpStatus(error.statusCode);
  }
  if (error is RetryableUploadException) {
    return _categoriseHttpStatus(error.statusCode);
  }

  final typeName = error.runtimeType.toString();
  if (typeName.endsWith('SocketException') ||
      typeName == 'WebSocketChannelException' ||
      typeName == 'ClientException' ||
      typeName == 'HttpException') {
    return 'Connection error';
  }

  return null;
}

/// Reduces [serverUrl] to a category for bug reports, so self-hosted URLs
/// stay private. Null when the URL is unknown.
String? serverCategory(String? serverUrl) {
  return switch (serverUrl) {
    null => null,
    DEFAULT_SERVER_PROD => 'wger.de',
    DEFAULT_SERVER_TEST => 'dev.wger.de',
    _ => 'self-hosted',
  };
}

/// Local counters that tell a blocked apply apart from data that never
/// arrives. Null fields mean the value is not in the database (yet).
class LocalSyncState {
  const LocalSyncState({
    this.targetRequestId,
    this.lastSeenRequestId,
    this.lastAppliedRequestId,
    this.maxLastOp,
    this.opsSinceCheckpoint,
    this.oplogRows,
  });

  /// While the target is greater than [lastSeenRequestId], the client waits
  /// for the service to confirm a local write and applies nothing.
  final int? targetRequestId;
  final int? lastSeenRequestId;
  final int? lastAppliedRequestId;

  /// Highest bucket position stored locally. Advances while data arrives,
  /// even when no checkpoint can be applied.
  final int? maxLastOp;

  /// Operations downloaded since the last applied checkpoint.
  final int? opsSinceCheckpoint;

  final int? oplogRows;
}

/// Reads [LocalSyncState] in a single round trip. The subqueries keep the
/// result to one row even when a table is empty.
const _localStateQuery = '''
SELECT
  (SELECT CAST(value AS INTEGER) FROM ps_kv WHERE key = 'target_checkpoint_request_id')
    AS target_request_id,
  (SELECT CAST(value AS INTEGER) FROM ps_kv WHERE key = 'last_seen_checkpoint_request_id')
    AS last_seen_request_id,
  (SELECT CAST(value AS INTEGER) FROM ps_kv WHERE key = 'last_applied_checkpoint_request_id')
    AS last_applied_request_id,
  (SELECT CAST(max(last_op) AS INTEGER) FROM ps_buckets) AS max_last_op,
  (SELECT CAST(sum(count_since_last) AS INTEGER) FROM ps_buckets) AS ops_since_checkpoint,
  (SELECT count(*) FROM ps_oplog) AS oplog_rows
''';

/// Renders a compact sync-state summary for bug reports.
String formatSyncDiagnostics(
  SyncStatus status, {
  required int pendingUploads,
  String? server,
  LocalSyncState? local,
}) {
  final buffer = StringBuffer();
  if (server != null) {
    buffer.writeln('server: $server');
  }
  buffer
    ..writeln(
      'connected: ${status.connected}, connecting: ${status.connecting}, '
      'downloading: ${status.downloading}, uploading: ${status.uploading}',
    )
    ..writeln('last successful sync: ${status.lastSyncedAt?.toUtc().toIso8601String() ?? 'never'}')
    ..writeln('pending uploads: $pendingUploads');
  if (local != null) {
    String value(int? v) => v?.toString() ?? '-';
    buffer
      ..writeln(
        'checkpoint request: target ${value(local.targetRequestId)}, '
        'seen ${value(local.lastSeenRequestId)}, applied ${value(local.lastAppliedRequestId)}',
      )
      ..writeln(
        'local buckets: last op ${value(local.maxLastOp)}, '
        'ops since checkpoint ${value(local.opsSinceCheckpoint)}, '
        'oplog rows ${value(local.oplogRows)}',
      );
  }
  if (status.downloadProgress case final progress?) {
    buffer.writeln(
      'download progress: ${progress.downloadedOperations} / ${progress.totalOperations}',
    );
  }
  if (status.anyError case final error?) {
    // Clamped: some exception toStrings embed whole response bodies, and
    // the report has to fit into a GitHub issue URL.
    final text = error.toString();
    final clamped = text.length <= 300 ? text : '${text.substring(0, 300)}…';
    buffer.writeln('error (${categoriseSyncError(error) ?? 'Uncategorised'}): $clamped');
  }
  return buffer.toString().trimRight();
}

/// Local counters for the sync status dialog, so it can offer them without
/// building a whole bug report.
final localSyncStateProvider = FutureProvider.autoDispose<LocalSyncState?>(
  (ref) => collectLocalSyncState(),
);

/// Reads the local sync counters, or null when the database is missing or
/// does not answer.
///
/// Never throws: a report must not fail over a diagnostic, and the internal
/// tables read here are not part of PowerSync's public API.
Future<LocalSyncState?> collectLocalSyncState() async {
  final db = builtPowerSyncInstance;
  if (db == null) {
    return null;
  }
  try {
    final row = await db.get(_localStateQuery);
    return LocalSyncState(
      targetRequestId: row['target_request_id'] as int?,
      lastSeenRequestId: row['last_seen_request_id'] as int?,
      lastAppliedRequestId: row['last_applied_request_id'] as int?,
      maxLastOp: row['max_last_op'] as int?,
      opsSinceCheckpoint: row['ops_since_checkpoint'] as int?,
      oplogRows: row['oplog_rows'] as int?,
    );
  } catch (e, s) {
    _logger.warning('Could not read the local sync state', e, s);
    return null;
  }
}

/// Snapshot of the current sync state for bug reports, or null when the
/// PowerSync database has not been initialised.
///
/// Never throws: this runs on report paths where the app may already be in
/// a broken state (e.g. the DB is closing down), and a missing sync section
/// must not prevent the report itself.
Future<String?> collectSyncDiagnostics({String? serverUrl}) async {
  final db = builtPowerSyncInstance;
  if (db == null) {
    return null;
  }
  try {
    final queue = await db.getUploadQueueStats();
    return formatSyncDiagnostics(
      db.currentStatus,
      pendingUploads: queue.count,
      server: serverCategory(serverUrl),
      local: await collectLocalSyncState(),
    );
  } catch (e, s) {
    _logger.warning('Could not collect sync diagnostics', e, s);
    return null;
  }
}
