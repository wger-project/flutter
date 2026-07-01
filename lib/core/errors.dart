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
/// The error details are passed to GitHub as query parameters and since
/// GitHub rejects URLs longer than [GITHUB_ISSUES_MAX_URL_LENGTH], when
/// the report would exceed that limit, the oldest log entries are pruned
/// until the URL fits.
String buildGithubIssueUrl({
  required String issueTitle,
  required String issueErrorMessage,
  required String stackTrace,
  required List<String> applicationLogs,
}) {
  String composeUrl(List<String> logs) {
    final logText = logs.isEmpty ? '-- No logs available --' : logs.join('\n');
    final description =
        '## Description\n\n'
        '[Please describe what you were doing when the error occurred.]\n\n'
        '## Error details\n\n'
        'Error title: $issueTitle\n'
        'Error message: $issueErrorMessage\n'
        'Stack trace:\n```\n$stackTrace\n```\n\n'
        'App logs (last ${logs.length} entries):\n```\n$logText\n```';
    return '$GITHUB_ISSUES_BUG_URL'
        '&title=${Uri.encodeComponent(issueTitle)}'
        '&description=${Uri.encodeComponent(description)}';
  }

  // The logs come newest-first, so the oldest entry is the last one. Drop it
  // and retry until the URL fits within the limit.
  var logs = applicationLogs;
  while (true) {
    final url = composeUrl(logs);
    if (url.length <= GITHUB_ISSUES_MAX_URL_LENGTH || logs.isEmpty) {
      return url;
    }
    logs = logs.sublist(0, logs.length - 1);
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
