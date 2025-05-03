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

void showHttpExceptionErrorDialog(
  WgerHttpException exception,
  BuildContext context,
) {
  final logger = Logger('showHttpExceptionErrorDialog');

  logger.fine(exception.toString());

  final List<Widget> errorList = [];

  for (final key in exception.errors!.keys) {
    // Error headers
    // Ensure that the error heading first letter is capitalized.
    final String errorHeaderMsg = key[0].toUpperCase() + key.substring(1, key.length);

    errorList.add(
      Text(
        errorHeaderMsg.replaceAll('_', ' '),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );

    // Error messages
    if (exception.errors![key] is String) {
      errorList.add(Text(exception.errors![key]));
    } else {
      for (final value in exception.errors![key]) {
        errorList.add(Text(value));
      }
    }
    errorList.add(const SizedBox(height: 8));
  }

  showDialog(
    context: context,
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

  // This call serves no purpose The dialog above doesn't seem to show
  // unless this dummy call is present
  //showDialog(context: context, builder: (context) => Container());
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
      logger.warning('Original error: $error');
      logger.warning('Original stackTrace: $stackTrace');
    }
    return;
  }

  // Determine the error title and message based on the error type.
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
    errorTitle = 'Missing Required Key ';
  }

  final String fullStackTrace = stackTrace?.toString() ?? 'No stack trace available.';

  final i18n = AppLocalizations.of(dialogContext);

  showDialog(
    context: dialogContext,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Theme.of(context).colorScheme.error),
            const SizedBox(width: 8),
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
          TextButton(
            child: const Text('Report issue'),
            onPressed: () async {
              const githubRepoUrl = 'https://github.com/wger-project/flutter';
              final description = Uri.encodeComponent(
                '## Description\n\n'
                '[Please describe what you were doing when the error occurred.]\n\n'
                '## Error details\n\n'
                'Error title: $errorTitle\n'
                'Error message: $errorMessage\n'
                'Stack trace:\n'
                '```\n$stackTrace\n```',
              );
              final githubIssueUrl = '$githubRepoUrl/issues/new?template=1_bug.yml'
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
            child: const Text('OK'),
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
