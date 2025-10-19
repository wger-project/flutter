/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) wger Team
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

  List<String> getFormattedLogs({Level? minLevel}) {
    final level = minLevel ?? Logger.root.level;
    return _logs
        .where((log) => log.level >= level)
        .map(
          (log) =>
              '${log.time.toIso8601String()} ${log.level.name} [${log.loggerName}] ${log.message}',
        )
        .toList();
  }

  void clear() => _logs.clear();
}
