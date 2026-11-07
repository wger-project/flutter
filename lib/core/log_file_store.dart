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

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:wger/core/logs.dart';

final _logger = Logger('logs');

/// Keeps log entries on disk so the ones from before a restart survive, they
/// are regularly the interesting ones. Also read back into the log overview.
///
/// Two files are rotated: entries go into the current one until it outgrows
/// [_maxFileBytes], at which point it replaces the older one and a new one is
/// started. Writes are batched, an app logs far too often for one write per
/// entry.
class PersistentLogStore {
  static final PersistentLogStore _instance = PersistentLogStore._internal();

  factory PersistentLogStore() => _instance;

  PersistentLogStore._internal();

  static const _maxFileBytes = 128 * 1024;
  static const _flushInterval = Duration(seconds: 5);
  static const _maxBufferedEntries = 100;
  static const _maxRestoredEntries = 500;

  File? _current;
  File? _older;
  Timer? _flushTimer;
  AppLifecycleListener? _lifecycleListener;
  bool _flushing = false;

  final List<String> _buffer = [];
  final List<String> _previousRun = [];

  /// Entries from before the current app start, oldest first. Empty until
  /// [init] has run.
  List<String> get previousRunLines => List.unmodifiable(_previousRun);

  /// Reads what earlier runs left behind, then starts a new file with
  /// [startMarker] as its first entry so the runs stay distinguishable.
  Future<void> init({required String directory, required String startMarker}) async {
    dispose();

    _current = File(join(directory, 'wger-logs.0.txt'));
    _older = File(join(directory, 'wger-logs.1.txt'));

    _previousRun
      ..clear()
      ..addAll(await _readEntries(_older!))
      ..addAll(await _readEntries(_current!));
    if (_previousRun.length > _maxRestoredEntries) {
      _previousRun.removeRange(0, _previousRun.length - _maxRestoredEntries);
    }

    // The run that just ended becomes the older file, this one starts empty
    await _rotate();

    _buffer.insert(0, startMarker);
    _flushTimer = Timer.periodic(_flushInterval, (_) => unawaited(flush()));
    // The app is usually killed from the background, so the entries leading
    // up to that have to be on disk before it gets there.
    _lifecycleListener = AppLifecycleListener(onPause: () => unawaited(flush()));

    await flush();
  }

  /// Queues [record] for the next write. Entries logged before [init] are
  /// kept, they cover the app start.
  void add(LogRecord record) {
    // One entry per line, so line breaks inside an entry are escaped and
    // restored on read. The backslash itself is deliberately not escaped, a
    // literal \n in a message just costs an extra line in the overview.
    _buffer.add(formatLogRecord(record).replaceAll(RegExp(r'\r\n?|\n'), r'\n'));

    if (_buffer.length < _maxBufferedEntries) {
      return;
    }
    if (_current == null) {
      // There is nowhere to write to before init(), so the oldest entries
      // give way instead of the buffer growing without bound.
      _buffer.removeAt(0);
      return;
    }
    unawaited(flush());
  }

  /// Writes everything queued so far. Never throws: a full disk or a
  /// read-only directory must not take the app down.
  Future<void> flush() async {
    final file = _current;
    if (file == null || _flushing || _buffer.isEmpty) {
      return;
    }

    _flushing = true;
    final batch = _buffer.join('\n');
    _buffer.clear();
    try {
      await file.writeAsString('$batch\n', mode: FileMode.append, flush: false);
      if (await file.length() > _maxFileBytes) {
        await _rotate();
      }
    } catch (e) {
      // Not logged, that would queue another entry and loop over the same
      // failing write.
      if (kDebugMode) {
        debugPrint('Could not write the log file: $e');
      }
    } finally {
      _flushing = false;
    }
  }

  /// Detaches the store from its files, nothing is written until the next
  /// [init]. Queued entries stay queued.
  void dispose() {
    _flushTimer?.cancel();
    _flushTimer = null;
    _lifecycleListener?.dispose();
    _lifecycleListener = null;
    _current = null;
    _older = null;
  }

  Future<List<String>> _readEntries(File file) async {
    try {
      if (!file.existsSync()) {
        return [];
      }
      return LineSplitter.split(
        await file.readAsString(),
      ).map((line) => line.replaceAll(r'\n', '\n')).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _rotate() async {
    final current = _current;
    final older = _older;
    if (current == null || older == null || !current.existsSync()) {
      return;
    }

    try {
      if (older.existsSync()) {
        older.deleteSync();
      }
      await current.rename(older.path);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Could not rotate the log files: $e');
      }
    }
  }
}

/// Starts the on-disk log buffer for this app run. Never throws, and does
/// nothing on the web, where there is no file system to write to.
Future<void> initPersistentLogs() async {
  if (kIsWeb) {
    return;
  }
  try {
    final info = await PackageInfo.fromPlatform();
    final directory = await getApplicationSupportDirectory();
    await PersistentLogStore().init(
      directory: directory.path,
      startMarker: '--- app start, ${info.version}+${info.buildNumber} ---',
    );
  } catch (e, s) {
    _logger.warning('Could not initialise the persistent log store', e, s);
  }
}
