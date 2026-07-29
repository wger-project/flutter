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

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:http/http.dart' as http;

import 'consts.dart';

/// How an error should be surfaced to the user.
enum ErrorSeverity {
  /// Logged only; not worth interrupting the user (e.g. layout overflows).
  cosmetic,

  /// A brief, non-blocking snackbar (e.g. transient connectivity problems).
  transient,

  /// A blocking error dialog.
  fatal,
}

/// Classifies [error] to decide how it should be surfaced.
ErrorSeverity classifyError(Object? error) {
  // Flutter reports layout overflows as a plain FlutterError without a
  // dedicated type, so matching the message is the only option.
  final isLayoutOverflow = error is FlutterError && error.toString().contains('overflowed');

  // A failed network image load as a plain StateError
  final isImageLoadFailure = error is StateError && error.toString().contains('Failed to load');

  if (error is NetworkImageLoadException || isLayoutOverflow || isImageLoadFailure) {
    return ErrorSeverity.cosmetic;
  }
  if (error is SocketException || error is http.ClientException || error is TimeoutException) {
    return ErrorSeverity.transient;
  }
  return ErrorSeverity.fatal;
}

/// True if [e] means "the server can't be reached right now", as opposed to
/// an HTTP response we got but didn't like (e.g. a 401, which means the token
/// is invalid)
bool isNetworkError(Object e) {
  return e is http.ClientException ||
      e is SocketException ||
      e is HandshakeException ||
      e is TimeoutException;
}

/// Builds the URL that opens a pre-filled GitHub bug report.
///
/// All error-related parameters are optional so user-initiated reports (no
/// crash, just logs and diagnostics) render without empty error sections.
/// The details are passed to GitHub as query parameters and since GitHub
/// rejects URLs longer than [GITHUB_ISSUES_MAX_URL_LENGTH], an oversized
/// report first drops the oldest log entries and then, if still too long,
/// trims the stack trace from the bottom until the URL fits.
String buildGithubIssueUrl({
  required List<String> applicationLogs,
  String? issueTitle,
  String? issueErrorMessage,
  String? stackTrace,
  String? syncDiagnostics,
}) {
  final descriptionPrompt = issueErrorMessage != null
      ? '[Please describe what you were doing when the error occurred.]'
      : '[Please describe the problem you are seeing.]';

  String composeUrl(List<String> logs, String? trace) {
    final logText = logs.isEmpty ? '-- No logs available --' : logs.join('\n');
    final errorDetails = issueErrorMessage == null
        ? null
        : '## Error details\n\n'
              '${issueTitle != null ? 'Error title: $issueTitle\n' : ''}'
              'Error message: $issueErrorMessage'
              '${trace != null ? '\nStack trace:\n```\n$trace\n```' : ''}';
    final sections = [
      '## Description\n\n$descriptionPrompt',
      ?errorDetails,
      if (syncDiagnostics != null) 'Sync status:\n```\n$syncDiagnostics\n```',
      'App logs (last ${logs.length} entries):\n```\n$logText\n```',
    ];
    final description = sections.join('\n\n');
    return '$GITHUB_ISSUES_BUG_URL'
        '${issueTitle != null ? '&title=${Uri.encodeComponent(issueTitle)}' : ''}'
        '&description=${Uri.encodeComponent(description)}';
  }

  // The logs come newest-first, so the oldest entry is the last one. Once
  // all logs are gone, drop stack frames starting from the outermost one;
  // the top of the trace is where the error actually happened.
  var logs = applicationLogs;
  var trace = stackTrace;
  while (true) {
    final url = composeUrl(logs, trace);
    if (url.length <= GITHUB_ISSUES_MAX_URL_LENGTH) {
      return url;
    }
    if (logs.isNotEmpty) {
      logs = logs.sublist(0, logs.length - 1);
    } else if (trace != null && trace.contains('\n')) {
      trace = trace.substring(0, trace.lastIndexOf('\n'));
    } else {
      // Nothing left to trim
      return url;
    }
  }
}

class ApiError {
  final String key;
  late List<String> errorMessages = [];

  ApiError({required this.key, this.errorMessages = const []});

  @override
  String toString() {
    return 'ApiError(key: $key, errorMessage: $errorMessages)';
  }
}

/// Extracts error messages from the server response,
/// including nested error structures.
List<ApiError> extractErrors(Map<String, dynamic> errors) {
  final List<ApiError> errorList = [];
  _extractErrorsRecursive(errors, errorList);
  return errorList;
}

void _extractErrorsRecursive(dynamic errors, List<ApiError> errorList, [String? parentKey]) {
  if (errors is Map<String, dynamic>) {
    for (final key in errors.keys) {
      final value = errors[key];
      final fullKey = parentKey != null ? '$parentKey | ${_formatHeader(key)}' : key;
      _extractErrorsRecursive(value, errorList, fullKey);
    }
  } else if (errors is List) {
    // List of Maps (nested errors)
    if (errors.isNotEmpty && errors.first is Map<String, dynamic>) {
      for (final item in errors) {
        _extractErrorsRecursive(item, errorList, parentKey);
      }
    } else {
      // List of Strings
      final header = _formatHeader(parentKey ?? '');
      final error = ApiError(key: header, errorMessages: errors.cast<String>());
      errorList.add(error);
    }
  } else if (errors is String) {
    final header = _formatHeader(parentKey ?? '');
    final error = ApiError(key: header, errorMessages: [errors]);
    errorList.add(error);
  }
}

String _formatHeader(String key) {
  var header = key[0].toUpperCase() + key.substring(1, key.length);
  header = header.replaceAll('_', ' ');
  return header.replaceAll('.', ' ');
}
