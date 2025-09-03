/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
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
import 'package:json_annotation/json_annotation.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wger/exceptions/http_exception.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/main.dart';
import 'package:wger/models/workouts/log.dart';
import 'package:wger/providers/routines.dart';

import 'consts.dart';

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

  // If possible, determine the error title and message based on the error type.
  bool isNetworkError = false;
  String errorTitle = 'An error occurred';
  String errorMessage = error.toString();

  if (error is TimeoutException) {
    errorTitle = 'Network Timeout';
    errorMessage =
        'The connection to the server timed out. Please check your internet connection and try again.';
  } else if (error is FlutterErrorDetails) {
    errorTitle = 'Application Error';
    errorMessage = error.exceptionAsString();
  } else if (error is MissingRequiredKeysException) {
    errorTitle = 'Missing Required Key';
  } else if (error is SocketException) {
    isNetworkError = true;
  }
  /*
  else if (error is PlatformException) {
    errorTitle = 'Problem with media';
    errorMessage =
        'There was a problem loading the media. This can be a e.g. problem with the codec that'
        'is not supported by your device. Original error message: ${error.message}';
  }

   */

  final String fullStackTrace = stackTrace?.toString() ?? 'No stack trace available.';

  final i18n = AppLocalizations.of(dialogContext);

  showDialog(
    context: dialogContext,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isNetworkError ? Icons.signal_wifi_connected_no_internet_4_outlined : Icons.error,
              color: Theme.of(context).colorScheme.error,
            ),
            Expanded(
              child: Text(
                isNetworkError ? i18n.errorCouldNotConnectToServer : i18n.anErrorOccurred,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text(
                isNetworkError
                    ? i18n.errorCouldNotConnectToServerDetails
                    : i18n.errorInfoDescription,
              ),
              const SizedBox(height: 8),
              Text(i18n.errorInfoDescription2),
              const SizedBox(height: 10),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(i18n.errorViewDetails),
                children: [
                  Text(
                    errorMessage,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
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
                  const SizedBox(height: 8),
                  TextButton.icon(
                    icon: const Icon(Icons.copy_all_outlined, size: 18),
                    label: Text(i18n.copyToClipboard),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      final String clipboardText =
                          'Error Title: $errorTitle\nError Message: $errorMessage\n\nStack Trace:\n$fullStackTrace';
                      Clipboard.setData(ClipboardData(text: clipboardText)).then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Error details copied to clipboard!')),
                        );
                      }).catchError((copyError) {
                        if (kDebugMode) logger.fine('Error copying to clipboard: $copyError');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Could not copy details.')),
                        );
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          if (!isNetworkError)
            TextButton(
              child: const Text('Report issue'),
              onPressed: () async {
                final description = Uri.encodeComponent(
                  '## Description\n\n'
                  '[Please describe what you were doing when the error occurred.]\n\n'
                  '## Error details\n\n'
                  'Error title: $errorTitle\n'
                  'Error message: $errorMessage\n'
                  'Stack trace:\n'
                  '```\n$stackTrace\n```',
                );
                final githubIssueUrl = '$GITHUB_ISSUES_BUG_URL'
                    '&title=$errorTitle'
                    '&description=$description';
                final Uri reportUri = Uri.parse(githubIssueUrl);

                try {
                  await launchUrl(reportUri, mode: LaunchMode.externalApplication);
                } catch (e) {
                  if (kDebugMode) logger.warning('Error launching URL: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error opening issue tracker: $e')),
                  );
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

void showDeleteDialog(BuildContext context, String confirmDeleteName, Log log) async {
  final res = await showDialog(
    context: context,
    builder: (BuildContext contextDialog) {
      return AlertDialog(
        content: Text(
          AppLocalizations.of(context).confirmDelete(confirmDeleteName),
        ),
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
            onPressed: () {
              context.read<RoutinesProvider>().deleteLog(log.id!, log.routineId);

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

/// Extracts error messages from the server response
List<ApiError> extractErrors(Map<String, dynamic> errors) {
  final List<ApiError> errorList = [];

  for (final key in errors.keys) {
    // Header
    var header = key[0].toUpperCase() + key.substring(1, key.length);
    header = header.replaceAll('_', ' ');
    final error = ApiError(key: header);

    final messages = errors[key];

    // Messages
    if (messages is String) {
      error.errorMessages = List.of(error.errorMessages)..add(messages);
    } else {
      error.errorMessages = [...error.errorMessages, ...messages];
    }

    errorList.add(error);
  }

  return errorList;
}

/// Processes the error messages from the server and returns a list of widgets
List<Widget> formatApiErrors(List<ApiError> errors, {Color? color}) {
  final textColor = color ?? Colors.black;

  final List<Widget> errorList = [];

  for (final error in errors) {
    errorList.add(
      Text(error.key, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
    );

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
      Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
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
    return Column(
      children: [
        Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
        ...formatApiErrors(
          extractErrors(exception.errors),
          color: Theme.of(context).colorScheme.error,
        ),
      ],
    );
  }
}

class GeneralErrorsWidget extends StatelessWidget {
  final String? title;
  final List<String> widgets;

  const GeneralErrorsWidget(this.widgets, {this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
        ...formatTextErrors(
          widgets,
          title: title,
          color: Theme.of(context).colorScheme.error,
        ),
      ],
    );
  }
}
