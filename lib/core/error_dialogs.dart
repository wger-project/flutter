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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:logging/logging.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wger/core/exceptions/http_exception.dart';
import 'package:wger/helpers/errors.dart';
import 'package:wger/helpers/logs.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/main.dart';
import 'package:wger/models/workouts/log.dart';
import 'package:wger/providers/workout_logs_notifier.dart';

/// Whether an error dialog is currently on screen.
///
/// Errors can fire in quick succession; this guards against stacking several
/// modal dialogs on top of each other.
bool _errorDialogVisible = false;

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

  if (_errorDialogVisible) {
    logger.info('Suppressing error dialog, one is already visible: $exception');
    return;
  }
  _errorDialogVisible = true;

  showDialog(
    context: dialogContext,
    builder: (ctx) => AlertDialog(
      title: Text(AppLocalizations.of(ctx).anErrorOccurred),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (exception.type == ErrorType.html)
              ServerHtmlError(data: exception.htmlError)
            else
              ...formatApiErrors(extractErrors(exception.errors)),
          ],
        ),
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
  ).whenComplete(() => _errorDialogVisible = false);
}

/// Flattens a [WgerHttpException]'s context and error map into a readable
/// multi-line string for the diagnostic dialog and bug report.
String _formatHttpExceptionDetail(WgerHttpException error) {
  String lines(Map<String, dynamic> m) => m.entries.map((e) => '${e.key}: ${e.value}').join('\n');
  final ctx = error.context == null || error.context!.isEmpty ? '' : '${lines(error.context!)}\n\n';
  return '$ctx${lines(error.errors)}';
}

void showGeneralErrorDialog(dynamic error, StackTrace? stackTrace, {BuildContext? context}) {
  // Attempt to get the BuildContext from our global navigatorKey.
  // This allows us to show a dialog even if the error occurs outside
  // of a widget's build method.
  final BuildContext? dialogContext = context ?? navigatorKey.currentContext;

  final logger = Logger('showGeneralErrorDialog');

  if (dialogContext == null) {
    if (kDebugMode) {
      logger.warning('Error: Could not error show dialog because the context is null.');
    }
    return;
  }

  if (_errorDialogVisible) {
    logger.info('Suppressing error dialog, one is already visible: $error');
    return;
  }
  _errorDialogVisible = true;

  final i18n = AppLocalizations.of(dialogContext);

  // If possible, determine the issue title and message based on the error type.
  // (Note that issue titles and error messages are not localized)
  String issueTitle = 'An error occurred';
  String issueErrorMessage = error.toString();

  if (error is FlutterErrorDetails) {
    issueTitle = 'Application Error';
    issueErrorMessage = error.exceptionAsString();
  } else if (error is MissingRequiredKeysException) {
    issueTitle = 'Missing Required Key';
  } else if (error is WgerHttpException) {
    final status = error.statusCode == null ? '' : ' (HTTP ${error.statusCode})';
    issueTitle = switch (error.source) {
      ExceptionSource.powersync => 'Sync upload rejected$status',
      ExceptionSource.flutter => 'Application error$status',
      ExceptionSource.api => 'Server error$status',
    };
    issueErrorMessage = _formatHttpExceptionDetail(error);
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
            Icon(Icons.error, color: Theme.of(context).colorScheme.error),
            Expanded(
              child: Text(
                i18n.anErrorOccurred,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text(i18n.errorInfoDescription),
              const SizedBox(height: 8),
              Text(i18n.errorInfoDescription2),
              const SizedBox(height: 10),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(i18n.errorViewDetails),
                children: [
                  Text(
                    issueErrorMessage,
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
          TextButton(
            child: const Text('Report issue'),
            onPressed: () async {
              final githubIssueUrl = buildGithubIssueUrl(
                issueTitle: issueTitle,
                issueErrorMessage: issueErrorMessage,
                stackTrace: fullStackTrace,
                applicationLogs: applicationLogs,
              );
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
  ).whenComplete(() => _errorDialogVisible = false);
}

/// Routes [error] to the appropriate UI based on its [ErrorSeverity].
///
/// The caller is responsible for logging the error beforehand.
void handleError(Object? error, StackTrace? stackTrace) {
  switch (classifyError(error)) {
    case ErrorSeverity.cosmetic:
      break;
    case ErrorSeverity.transient:
      showTransientErrorSnackbar();
    case ErrorSeverity.fatal:
      // API errors are the form-validation fallback (clean field errors);
      // other sources are diagnostic and get the dialog with logs and report.
      if (error is WgerHttpException && error.source == ExceptionSource.api) {
        showHttpExceptionErrorDialog(error);
      } else {
        showGeneralErrorDialog(error, stackTrace);
      }
  }
}

/// Shows a brief, non-blocking snackbar telling the user about a (hopefully)
/// transient error such as network problems, etc.
void showTransientErrorSnackbar() {
  final messenger = scaffoldMessengerKey.currentState;
  final context = navigatorKey.currentContext;

  if (messenger == null || context == null) {
    if (kDebugMode) {
      Logger(
        'showNetworkErrorSnackbar',
      ).warning('Could not show snackbar: no messenger or context available.');
    }
    return;
  }

  messenger
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).errorCouldNotConnectToServer)),
    );
}

/// Shows a brief, non-blocking snackbar telling the user their session is no
/// longer valid and they need to log in again.
void showSessionExpiredSnackbar() {
  final messenger = scaffoldMessengerKey.currentState;
  final context = navigatorKey.currentContext;

  if (messenger == null || context == null) {
    return;
  }

  messenger
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).sessionExpired)),
    );
}

/// A widget to render HTML errors returned by the server
///
/// This is a simple wrapper around the `Html` Widget, with some light changes
/// to the style.
class ServerHtmlError extends StatelessWidget {
  final logger = Logger('ServerHtml');
  final String data;

  ServerHtmlError({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Html(
      data: data,
      style: {
        'h1': Style(fontSize: FontSize(theme.textTheme.bodyLarge?.fontSize ?? 15)),
        'h2': Style(fontSize: FontSize(theme.textTheme.bodyMedium?.fontSize ?? 15)),
      },
      doNotRenderTheseTags: const {'a'},
    );
  }
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
              ).read(workoutLogProvider).deleteEntry(log.id.toString());

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

/// Processes the error messages from the server and returns a list of widgets
List<Widget> formatApiErrors(List<ApiError> errors, {Color? color}) {
  final logger = Logger('formatApiErrors');
  final textColor = color ?? Colors.black;

  final List<Widget> errorList = [];

  for (final error in errors) {
    errorList.add(
      Text(
        error.key,
        style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
      ),
    );

    logger.warning(error.errorMessages);
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
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(maxHeight: 250),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.error, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error),
            if (exception.type == ErrorType.html)
              ServerHtmlError(data: exception.htmlError)
            else
              ...formatApiErrors(
                extractErrors(exception.errors),
                color: theme.colorScheme.error,
              ),
          ],
        ),
      ),
    );
  }
}
