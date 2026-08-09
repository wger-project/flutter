/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:wger/core/error_dialogs.dart' show CopyToClipboardButton;
import 'package:wger/core/errors.dart' show buildGithubIssueUrl;
import 'package:wger/core/logs.dart';
import 'package:wger/core/misc.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/powersync/sync_diagnostics.dart' show collectSyncDiagnostics;

class LogOverviewPage extends StatefulWidget {
  static String routeName = '/LogOverviewPage';

  const LogOverviewPage({super.key});

  @override
  State<LogOverviewPage> createState() => _LogOverviewPageState();
}

class _LogOverviewPageState extends State<LogOverviewPage> {
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    // Filtering on the formatted entry, so the query matches exactly what
    // is on screen, error text included
    final query = _filter.toLowerCase();
    final logs = InMemoryLogStore().logs.reversed
        .where((log) => formatLogRecord(log).toLowerCase().contains(query))
        .toList();
    final copyText = logs.map(formatLogRecord).join('\n');

    return Scaffold(
      appBar: AppBar(
        title: Text(i18n.applicationLogs),
        actions: [
          // Copies everything the filter currently lets through, so a report
          // isn't limited to what fits on a screenshot
          CopyToClipboardButton(text: copyText, iconOnly: true),
          // Opens a pre-filled GitHub issue with these logs and the current
          // sync snapshot
          IconButton(
            icon: const Icon(Icons.bug_report),
            tooltip: 'Report issue',
            onPressed: () async {
              final url = buildGithubIssueUrl(
                applicationLogs: InMemoryLogStore().getFormattedLogs(),
                syncDiagnostics: await collectSyncDiagnostics(),
              );
              if (context.mounted) {
                launchURL(url, context);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              key: const ValueKey('logFilterField'),
              decoration: InputDecoration(
                isDense: true,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
                labelText: i18n.filter,
              ),
              onChanged: (value) => setState(() => _filter = value),
            ),
          ),
          Expanded(
            child: logs.isEmpty
                ? const Center(child: Text('No logs available.'))
                : ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      return ListTile(
                        dense: true,
                        leading: Icon(_iconForLevel(log.level)),
                        title: Text('[${log.level.name}] ${formatLogDetails(log)}'),
                        subtitle: Text('${log.loggerName}\n${log.time.toUtc().toIso8601String()}'),
                        trailing: CopyToClipboardButton(
                          text: formatLogRecord(log),
                          iconOnly: true,
                        ),
                        isThreeLine: true,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

IconData _iconForLevel(Level level) {
  if (level >= Level.SEVERE) {
    return Icons.priority_high;
  }
  if (level >= Level.WARNING) {
    return Icons.warning;
  }
  if (level >= Level.INFO) {
    return Icons.info;
  }
  return Icons.bug_report;
}
