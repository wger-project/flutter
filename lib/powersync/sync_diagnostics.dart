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

import 'package:powersync/powersync.dart'
    show CredentialsException, PowerSyncProtocolException, SyncResponseException, SyncStatus;
import 'package:wger/core/consts.dart';
import 'package:wger/database/powersync/powersync.dart' show builtPowerSyncInstance;
import 'package:wger/powersync/connector.dart' show RetryableUploadException;

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

/// Renders a compact sync-state summary for bug reports.
String formatSyncDiagnostics(
  SyncStatus status, {
  required int pendingUploads,
  String? server,
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

/// Snapshot of the current sync state for bug reports, or null when the
/// PowerSync database has not been initialised.
Future<String?> collectSyncDiagnostics({String? serverUrl}) async {
  final db = builtPowerSyncInstance;
  if (db == null) {
    return null;
  }
  final queue = await db.getUploadQueueStats();
  return formatSyncDiagnostics(
    db.currentStatus,
    pendingUploads: queue.count,
    server: serverCategory(serverUrl),
  );
}
