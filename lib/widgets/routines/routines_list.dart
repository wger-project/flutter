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
  Map<String, dynamic>? _lastDeletedRoutine;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMd(Localizations.localeOf(context).languageCode);
    final routines = widget._routineProvider.items;

    return RefreshIndicator(
      onRefresh: () => widget._routineProvider.fetchAndSetAllPlansSparse(),
      child: routines.isEmpty
          ? const TextPrompt()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              itemCount: routines.length,
              itemBuilder: (context, index) {
                final currentRoutine = routines[index];

                return Dismissible(
                  key: ValueKey(currentRoutine.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(AppLocalizations.of(context).delete),
                        content: Text(
                          AppLocalizations.of(context).confirmDelete(currentRoutine.name),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: Text(
                              AppLocalizations.of(context).delete,
                              style: TextStyle(color: Theme.of(context).colorScheme.error),
                            ),
                          ),
                        ],
                      ),
                    );
                    return confirm ?? false;
                  },
                  onDismissed: (direction) {
                    _lastDeletedRoutine = {
                      'id': currentRoutine.id,
                      'name': currentRoutine.name,
                      'routine': currentRoutine,
                    };

                    Provider.of<RoutinesProvider>(context, listen: false)
                        .deleteRoutine(currentRoutine.id!);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context).successfullyDeleted),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    elevation: 3,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      onTap: () async {
                        widget._routineProvider.setCurrentPlan(currentRoutine.id!);
                        setState(() => _loadingRoutine = currentRoutine.id);

                        await widget._routineProvider.fetchAndSetRoutineFull(currentRoutine.id!);

                        if (mounted) {
                          setState(() => _loadingRoutine = null);
                          Navigator.of(context).pushNamed(
                            RoutineScreen.routeName,
                            arguments: currentRoutine.id,
                          );
                        }
                      },
                      title: Text(
                        currentRoutine.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${dateFormat.format(currentRoutine.start)} - ${dateFormat.format(currentRoutine.end)}',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_loadingRoutine == currentRoutine.id)
                            const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              tooltip: AppLocalizations.of(context).delete,
                              color: Colors.grey.shade700,
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    content: Text(AppLocalizations.of(context)
                                        .confirmDelete(currentRoutine.name)),
                                    actions: [
                                      TextButton(
                                        child: Text(
                                            MaterialLocalizations.of(context).cancelButtonLabel),
                                        onPressed: () => Navigator.of(ctx).pop(false),
                                      ),
                                      TextButton(
                                        child: Text(
                                          AppLocalizations.of(context).delete,
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.error,
                                          ),
                                        ),
                                        onPressed: () => Navigator.of(ctx).pop(true),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  _lastDeletedRoutine = {
                                    'id': currentRoutine.id,
                                    'name': currentRoutine.name,
                                    'routine': currentRoutine,
                                  };

                                  Provider.of<RoutinesProvider>(context, listen: false)
                                      .deleteRoutine(currentRoutine.id!);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        AppLocalizations.of(context).successfullyDeleted,
                                        textAlign: TextAlign.center,
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                      margin:
                                          const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
