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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/network_provider.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/screens/routine_screen.dart';
import 'package:wger/widgets/core/text_prompt.dart';

class RoutinesList extends ConsumerStatefulWidget {
  const RoutinesList();

  @override
  ConsumerState<RoutinesList> createState() => _RoutinesListState();
}

class _RoutinesListState extends ConsumerState<RoutinesList> {
  int? _loadingRoutine;

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(networkStatusProvider);
    final dateFormat = DateFormat.yMd(Localizations.localeOf(context).languageCode);
    final routineProvider = ref.read(routinesChangeProvider);

    return RefreshIndicator(
      onRefresh: isOnline ? () => routineProvider.fetchAndSetAllRoutinesSparse() : () async {},
      child: routineProvider.items.isEmpty
          ? const TextPrompt()
          : ListView.builder(
              padding: const EdgeInsets.all(10.0),
              itemCount: routineProvider.items.length,
              itemBuilder: (context, index) {
                final currentRoutine = routineProvider.items[index];

                return Card(
                  child: ListTile(
                    onTap: () async {
                      setState(() {
                        _loadingRoutine = currentRoutine.id;
                      });
                      try {
                        await routineProvider.fetchAndSetRoutineFull(currentRoutine.id!);
                      } finally {
                        if (mounted) {
                          setState(() => _loadingRoutine = null);
                        }
                      }

                      if (context.mounted) {
                        Navigator.of(context).pushNamed(
                          RoutineScreen.routeName,
                          arguments: currentRoutine.id,
                        );
                      }
                    },
                    title: Text(currentRoutine.name),
                    subtitle: Text(
                      '${dateFormat.format(currentRoutine.start)}'
                      ' - ${dateFormat.format(currentRoutine.end)}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const VerticalDivider(),
                        if (_loadingRoutine == currentRoutine.id)
                          const IconButton(
                            icon: CircularProgressIndicator(),
                            onPressed: null,
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.delete),
                            tooltip: AppLocalizations.of(context).delete,
                            onPressed: isOnline
                                ? () async {
                                    // Delete workout from DB
                                    await showDialog(
                                      context: context,
                                      builder: (BuildContext contextDialog) {
                                        return AlertDialog(
                                          content: Text(
                                            AppLocalizations.of(
                                              context,
                                            ).confirmDelete(currentRoutine.name),
                                          ),
                                          actions: [
                                            TextButton(
                                              child: Text(
                                                MaterialLocalizations.of(context).cancelButtonLabel,
                                              ),
                                              onPressed: () => Navigator.of(contextDialog).pop(),
                                            ),
                                            TextButton(
                                              child: Text(
                                                AppLocalizations.of(context).delete,
                                                style: TextStyle(
                                                  color: Theme.of(context).colorScheme.error,
                                                ),
                                              ),
                                              onPressed: () {
                                                // Confirmed, delete the workout
                                                routineProvider.deleteRoutine(currentRoutine.id!);

                                                // Close the popup
                                                Navigator.of(contextDialog).pop();

                                                // and inform the user
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      AppLocalizations.of(
                                                        context,
                                                      ).successfullyDeleted,
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
                                  }
                                : null,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
