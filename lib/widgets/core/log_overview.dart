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
import 'package:wger/helpers/logs.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

class LogOverviewPage extends StatelessWidget {
  static String routeName = '/LogOverviewPage';

  const LogOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final logs = InMemoryLogStore().logs.reversed.toList();

    return Scaffold(
      appBar: AppBar(title: Text(i18n.applicationLogs)),
      body: logs.isEmpty
          ? const Center(child: Text('No logs available.'))
          : ListView.builder(
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                return ListTile(
                  dense: true,
                  leading: Icon(_iconForLevel(log.level)),
                  title: Text('[${log.level.name}] ${log.message}'),
                  subtitle: Text('${log.loggerName}\n${log.time.toIso8601String()}'),
                  isThreeLine: true,
                );
              },
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
