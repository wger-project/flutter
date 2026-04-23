/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 - 2026 wger Team
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

import 'package:flutter/material.dart';
import 'package:wger/core/exceptions/http_exception.dart';
import 'package:wger/helpers/errors.dart' show ServerHtmlError;
import 'package:wger/l10n/generated/app_localizations.dart';

/// Maximum visible height for the inline error display. Long stack traces or
/// HTML pages scroll inside this box rather than blowing up the parent card.
const double _kMaxErrorHeight = 280;

/// Inline error indicator used by [AsyncValueWidget]
///
/// Accepts the raw error object so we can introspect it - if it's a
/// [WgerHttpException] with [ErrorType.html] (typical for Django's debug
/// pages and 500 errors served as HTML), the widget renders a Preview / Raw
/// toggle so the user can see the page as styled HTML or copy the source.
/// Anything else (plain strings, JSON, generic exceptions) renders as
/// scrollable monospace text.
class StreamErrorIndicator extends StatelessWidget {
  const StreamErrorIndicator(this.error, {this.stacktrace, super.key});

  final Object error;
  final StackTrace? stacktrace;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final i18n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: theme.colorScheme.error, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  i18n.anErrorOccurred,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: _kMaxErrorHeight),
            child: _buildBody(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final error = this.error;
    if (error is WgerHttpException && error.type == ErrorType.html) {
      return _HtmlErrorBody(html: error.htmlError);
    }
    return _PlainErrorBody(text: error.toString(), stacktrace: stacktrace);
  }
}

/// Preview / Raw toggle for HTML errors. Mirrors the pattern used by the
/// markdown editor so the UI feels familiar.
class _HtmlErrorBody extends StatelessWidget {
  const _HtmlErrorBody({required this.html});

  final String html;

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          TabBar(
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.textTheme.bodySmall?.color,
            tabs: [
              Tab(text: i18n.preview),
              Tab(text: i18n.errorRawSource),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              children: [
                SingleChildScrollView(child: ServerHtmlError(data: html)),
                SingleChildScrollView(
                  child: SelectableText(
                    html,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Plain-text error body (anything that's not HTML). Renders the message
/// and an optional stacktrace, both scrollable and selectable so the user
/// can copy them into a bug report.
class _PlainErrorBody extends StatelessWidget {
  const _PlainErrorBody({required this.text, this.stacktrace});

  final String text;
  final StackTrace? stacktrace;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SelectableText(
            text,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
          if (stacktrace != null) ...[
            const SizedBox(height: 8),
            SelectableText(
              stacktrace.toString(),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }
}
