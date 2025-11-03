/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020,  wger Team
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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:logging/logging.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wger/exceptions/http_exception.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/main.dart';
import 'package:wger/models/workouts/log.dart';
import 'package:wger/providers/workout_logs.dart';

import 'consts.dart';
import 'logs.dart';

void showHttpExceptionErrorDialog(WgerHttpException exception, {BuildContext? context}) {
  final logger = Logger('showHttpExceptionErrorDialog');

  // Attempt to get the BuildContext from our global navigatorKey.
  // This allows us to show a dialog even if the error occurs outside
  // of a widget's build method.
  final BuildContext? dialogContext = context ?? navigatorKey.currentContext;

  if (dialogContext == null) {
    if (kDebugMode) {
      logger.warning('Error: Could not error show http error dialog because the context is null.');
    }
    return;
  }

  final errorList = formatApiErrors(extractErrors(exception.errors));

  showDialog(
    context: dialogContext,
    builder: (ctx) => AlertDialog(
      title: Text(AppLocalizations.of(ctx).anErrorOccurred),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [...errorList],
      ),
      actions: [
        TextButton(
          child: Text(MaterialLocalizations.of(ctx).closeButtonLabel),
          onPressed: () {
            Navigator.of(ctx).pop();
          },
        ),
      ],
    ),
  );
}

void showGeneralErrorDialog(dynamic error, StackTrace? stackTrace, {BuildContext? context}) {
  // Attempt to get the BuildContext from our global navigatorKey.
  // This allows us to show a dialog even if the error occurs outside
  // of a widget's build method.
  final BuildContext? dialogContext = context ?? navigatorKey.currentContext;

  final logger = Logger('showHttpExceptionErrorDialog');

  if (dialogContext == null) {
    if (kDebugMode) {
      logger.warning('Error: Could not error show dialog because the context is null.');
    }
    return;
  }

  final i18n = AppLocalizations.of(dialogContext);

  // If possible, determine the error title and message based on the error type.
  // (Note that issue titles and error messages are not localized)
  bool allowReportIssue = true;
  String issueTitle = 'An error occurred';
  String issueErrorMessage = error.toString();
  String errorTitle = i18n.anErrorOccurred;
  String errorDescription = i18n.errorInfoDescription;
  var icon = Icons.error;

  if (error is TimeoutException) {
    issueTitle = 'Network Timeout';
    issueErrorMessage =
        'The connection to the server timed out. Please check your '
        'internet connection and try again.';
  } else if (error is FlutterErrorDetails) {
    issueTitle = 'Application Error';
    issueErrorMessage = error.exceptionAsString();
  } else if (error is MissingRequiredKeysException) {
    issueTitle = 'Missing Required Key';
  } else if (error is SocketException) {
    allowReportIssue = false;
    icon = Icons.signal_wifi_connected_no_internet_4_outlined;
    errorTitle = i18n.errorCouldNotConnectToServer;
    errorDescription = i18n.errorCouldNotConnectToServerDetails;
  }

  final String fullStackTrace = stackTrace?.toString() ?? 'No stack trace available.';
  final applicationLogs = InMemoryLogStore().getFormattedLogs();

  showDialog(
    context: dialogContext,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.error),
            Expanded(
              child: Text(errorTitle, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text(errorDescription),
              const SizedBox(height: 8),
              Text(i18n.errorInfoDescription2),
              const SizedBox(height: 10),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(i18n.errorViewDetails),
                children: [
                  Text(issueErrorMessage, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: SingleChildScrollView(
                      child: Text(
                        fullStackTrace,
                        style: TextStyle(fontSize: 12.0, color: Colors.grey[700]),
                      ),
                    ),
                  ),
                  CopyToClipboardButton(
                    text:
                        'Error Title: $issueTitle\n'
                        'Error Message: $issueErrorMessage\n\n'
                        'Stack Trace:\n$fullStackTrace',
                  ),
                  const SizedBox(height: 8),
                  Text(i18n.applicationLogs, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ...applicationLogs.map(
                            (entry) => Text(
                              entry,
                              style: TextStyle(fontSize: 12.0, color: Colors.grey[700]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  CopyToClipboardButton(text: applicationLogs.join('\n')),
                ],
              ),
            ],
          ),
        ),
        actions: [
          if (allowReportIssue)
            TextButton(
              child: const Text('Report issue'),
              onPressed: () async {
                final logText = applicationLogs.isEmpty
                    ? '-- No logs available --'
                    : applicationLogs.join('\n');
                final description = Uri.encodeComponent(
                  '## Description\n\n'
                  '[Please describe what you were doing when the error occurred.]\n\n'
                  '## Error details\n\n'
                  'Error title: $issueTitle\n'
                  'Error message: $issueErrorMessage\n'
                  'Stack trace:\n'
                  '```\n$stackTrace\n```\n\n'
                  'App logs (last ${applicationLogs.length} entries):\n'
                  '```\n$logText\n```',
                );
                final githubIssueUrl =
                    '$GITHUB_ISSUES_BUG_URL'
                    '&title=$issueTitle'
                    '&description=$description';
                final Uri reportUri = Uri.parse(githubIssueUrl);

                try {
                  await launchUrl(reportUri, mode: LaunchMode.externalApplication);
                } catch (e) {
                  if (kDebugMode) {
                    logger.warning('Error launching URL: $e');
                  }
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error opening issue tracker: $e')));
                }
              },
            ),
          FilledButton(
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

class CopyToClipboardButton extends StatelessWidget {
  final logger = Logger('CopyToClipboardButton');
  final String text;

  CopyToClipboardButton({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);

    return TextButton.icon(
      icon: const Icon(Icons.copy_all_outlined, size: 18),
      label: Text(i18n.copyToClipboard),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: () {
        Clipboard.setData(ClipboardData(text: text))
            .then((_) {
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Details copied to clipboard!')));
              }
            })
            .catchError((copyError) {
              logger.warning('Error copying to clipboard: $copyError');

              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Could not copy details.')));
              }
            });
      },
    );
  }
}

void showDeleteLogDialog(BuildContext context, String confirmDeleteName, Log log) async {
  final res = await showDialog(
    context: context,
    builder: (BuildContext contextDialog) {
      return AlertDialog(
        content: Text(AppLocalizations.of(context).confirmDelete(confirmDeleteName)),
        actions: [
          TextButton(
            key: const ValueKey('cancel-button'),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            onPressed: () => Navigator.of(contextDialog).pop(),
          ),
          TextButton(
            key: const ValueKey('delete-button'),
            child: Text(
              AppLocalizations.of(context).delete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onPressed: () async {
              await ProviderScope.containerOf(
                context,
              ).read(workoutLogProvider.notifier).deleteEntry(log.id.toString());

              Navigator.of(contextDialog).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context).successfullyDeleted,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
        ],
      );
    },
  );
  return res;
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

/// Processes the error messages from the server and returns a list of widgets
List<Widget> formatApiErrors(List<ApiError> errors, {Color? color}) {
  final textColor = color ?? Colors.black;

  final List<Widget> errorList = [];

  for (final error in errors) {
    errorList.add(
      Text(
        error.key,
        style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
      ),
    );

    print(error.errorMessages);
    for (final message in error.errorMessages) {
      errorList.add(Text(message, style: TextStyle(color: textColor)));
    }
    errorList.add(const SizedBox(height: 8));
  }

  return errorList;
}

/// Processes the error messages from the server and returns a list of widgets
List<Widget> formatTextErrors(List<String> errors, {String? title, Color? color}) {
  final textColor = color ?? Colors.black;

  final List<Widget> errorList = [];

  if (title != null) {
    errorList.add(
      Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }

  for (final message in errors) {
    errorList.add(Text(message, style: TextStyle(color: textColor)));
  }
  errorList.add(const SizedBox(height: 8));

  return errorList;
}

class FormHttpErrorsWidget extends StatelessWidget {
  final WgerHttpException exception;

  const FormHttpErrorsWidget(this.exception, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 250),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
            ...formatApiErrors(
              extractErrors(exception.errors),
              color: Theme.of(context).colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }
}

class GeneralErrorsWidget extends StatelessWidget {
  final String? title;
  final List<String> widgets;

  const GeneralErrorsWidget(this.widgets, {this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 250),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
            ...formatTextErrors(widgets, title: title, color: Theme.of(context).colorScheme.error),
          ],
        ),
      ),
    );
  }
}
