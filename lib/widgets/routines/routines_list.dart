/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
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
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/screens/routine_screen.dart';
import 'package:wger/widgets/core/text_prompt.dart';

class RoutinesList extends StatefulWidget {
  final RoutinesProvider _routineProvider;

  const RoutinesList(this._routineProvider);

  @override
  State<RoutinesList> createState() => _RoutinesListState();
}

class _RoutinesListState extends State<RoutinesList> {
  int? _loadingRoutine;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMd(Localizations.localeOf(context).languageCode);

    return RefreshIndicator(
      onRefresh: () => widget._routineProvider.fetchAndSetAllRoutinesSparse(),
      child: widget._routineProvider.items.isEmpty
          ? const TextPrompt()
          : ListView.builder(
              padding: const EdgeInsets.all(10.0),
              itemCount: widget._routineProvider.items.length,
              itemBuilder: (context, index) {
                final currentRoutine = widget._routineProvider.items[index];

                return Card(
                  child: ListTile(
                    onTap: () async {
                      widget._routineProvider.activeRoutine = currentRoutine;

                      setState(() {
                        _loadingRoutine = currentRoutine.id;
                      });
                      await widget._routineProvider.fetchAndSetRoutineFull(currentRoutine.id!);

                      if (mounted) {
                        setState(() {
                          _loadingRoutine = null;
                        });

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
                            onPressed: () async {
                              // Delete workout from DB
                              await showDialog(
                                context: context,
                                builder: (BuildContext contextDialog) {
                                  return AlertDialog(
                                    content: Text(
                                      AppLocalizations.of(context)
                                          .confirmDelete(currentRoutine.name),
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
                                          Provider.of<RoutinesProvider>(
                                            context,
                                            listen: false,
                                          ).deleteRoutine(currentRoutine.id!);

                                          // Close the popup
                                          Navigator.of(contextDialog).pop();

                                          // and inform the user
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
                            },
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
