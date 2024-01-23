// ignore_for_file: type_annotate_public_apis

import 'dart:developer';
import 'package:flutter/foundation.dart' as foundation;
import 'package:logging/logging.dart';
import 'package:wger/exceptions/logger.abs.dart';

class LogInfo {
  final String log;
  final StackTrace? trace;

  LogInfo(this.log, this.trace);
}

class LoggingAdaptor extends Logging {
  late Logger _logger;

  LoggingAdaptor(String name) {
    Logger.root.level = _level(Logging.level);
    _logger = Logger(name);
  }

  /// Listen for logs being added to the logging stream and
  /// print them out as needed. An equivalent function can be
  /// created in other logging classes using this stream
  static void listenForLogs() {
    Logger.root.onRecord.listen((record) {
      if (Logging.level != LogLevel.off) {
        final parsedLog = _parse(
          message: record.message,
          level: record.level,
          loggerName: record.loggerName,
        );

        log(parsedLog);
      }
    });
  }

  static String _parse({
    required message,
    required Level level,
    required String loggerName,
    Object? error,
  }) {
    String? callerInfo;
    try {
      if (level >= Level.WARNING) {
        final lines = StackTrace.current.toString().split('\n');
        final currentTrace = lines[2];
        final indexOfWhiteSpace = currentTrace.indexOf(' ');

        callerInfo = currentTrace.substring(indexOfWhiteSpace).trim();
      }
    } catch (_) {}

    final traceInfo = callerInfo != null ? '| $callerInfo ' : '';
    final logger = loggerName != '' ? loggerName : 'Default';

    return '[$logger] ${level.name}: $message ${error ?? ''} $traceInfo';
  }

  @override
  void fine(message, [Object? error, StackTrace? stackTrace]) {
    if (LogLevel.fine >= Logging.level) {
      _logger.fine(message, error, stackTrace);
    }
  }

  @override
  void finer(message, [Object? error, StackTrace? stackTrace]) {
    if (LogLevel.fine >= Logging.level) {
      _logger.finer(message, error, stackTrace);
    }
  }

  @override
  void finest(message, [Object? error, StackTrace? stackTrace]) {
    if (LogLevel.fine >= Logging.level) {
      _logger.finest(message, error, stackTrace);
    }
  }

  @override
  void info(message, [Object? error, StackTrace? stackTrace]) {
    if (LogLevel.fine >= Logging.level) {
      _logger.info(message, error, stackTrace);
    }
  }

  @override
  void severe(message, [Object? error, StackTrace? stackTrace]) {
    if (LogLevel.fine >= Logging.level) {
      _logger.severe(message, error, stackTrace);
    }
  }

  @override
  void warning(message, [Object? error, StackTrace? stackTrace]) {
    if (LogLevel.warning >= Logging.level) {
      _logger.warning(message, error, stackTrace);
    }
  }

  static Level _level(LogLevel logLevel) {
    // Disable local log output if app is in release mode
    if (foundation.kReleaseMode) {
      return Level.OFF;
    }

    switch (logLevel) {
      case LogLevel.all:
        return Level.ALL;

      case LogLevel.fine:
        return Level.FINE;

      case LogLevel.finer:
        return Level.FINER;

      case LogLevel.finest:
        return Level.FINEST;

      case LogLevel.off:
        return Level.OFF;

      case LogLevel.info:
        return Level.INFO;

      case LogLevel.warning:
        return Level.WARNING;

      case LogLevel.severe:
        return Level.SEVERE;

      default:
        return Level.OFF;
    }
  }
}
