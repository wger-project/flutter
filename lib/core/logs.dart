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

import 'package:logging/logging.dart';

/// Characters of the error text kept per formatted entry. Some exceptions
/// embed whole response bodies and the logs also go into a bug report URL.
const _maxErrorChars = 500;

/// Stack trace frames kept per formatted entry.
const _maxStackFrames = 8;

/// Message of [record] together with its error and a shortened stack trace.
///
/// The message on its own is often only a category ("Sync service error"),
/// the exception with the actual cause sits in the record's error field.
String formatLogDetails(LogRecord record) {
  final buffer = StringBuffer(record.message);

  if (record.error != null) {
    final error = record.error.toString();
    buffer.write(
      ' | ${error.length <= _maxErrorChars ? error : '${error.substring(0, _maxErrorChars)}…'}',
    );
  }

  if (record.stackTrace != null) {
    final frames = record.stackTrace.toString().trimRight().split('\n');
    for (final frame in frames.take(_maxStackFrames)) {
      buffer.write('\n    ${frame.trim()}');
    }
    if (frames.length > _maxStackFrames) {
      buffer.write('\n    … ${frames.length - _maxStackFrames} more frames');
    }
  }

  return buffer.toString();
}

/// Renders [record] as one entry for the log overview and the log export.
///
/// The timestamp is in UTC so it can be compared with server logs without
/// having to guess the timezone of the device.
String formatLogRecord(LogRecord record) =>
    '${record.time.toUtc().toIso8601String()} ${record.level.name} '
    '[${record.loggerName}] ${formatLogDetails(record)}';

/// Stores log entries in memory.
///
/// This means nothing is stored permanently anywhere and we loose everything
/// when the application closes, but that's ok for our use case and can be
/// changed in the future if the need arises.
class InMemoryLogStore {
  static final InMemoryLogStore _instance = InMemoryLogStore._internal();
  final List<LogRecord> _logs = [];

  factory InMemoryLogStore() => _instance;

  InMemoryLogStore._internal();

  // Adds a new log entry, but keeps the total number of entries limited
  void add(LogRecord record) {
    if (_logs.length >= 500) {
      _logs.removeAt(0);
    }
    _logs.add(record);
  }

  List<LogRecord> get logs => List.unmodifiable(_logs);

  /// Returns formatted log entries
  List<String> getFormattedLogs({Level? minLevel, int maxEntries = 50}) {
    final level = minLevel ?? Logger.root.level;
    final filtered = _logs.where((log) => log.level >= level).toList();

    final start = filtered.length - maxEntries;
    final slice = start > 0 ? filtered.sublist(start) : filtered;

    // Return newest entries first (reverse order)
    return slice.reversed.map(formatLogRecord).toList();
  }

  void clear() => _logs.clear();
}
