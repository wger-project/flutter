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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/network_provider.dart';
import 'package:wger/providers/routines_notifier.dart';
import 'package:wger/screens/routine_screen.dart';
import 'package:wger/widgets/core/async_value_widget.dart';
import 'package:wger/widgets/core/confirm_delete_dialog.dart';
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
    final dateFormat = DateFormat.yMd(Localizations.localeOf(context).languageCode);
    final routineProvider = ref.read(routinesRiverpodProvider.notifier);
    final routinesAsync = ref.watch(routinesRiverpodProvider);
    final isOnline = ref.watch(networkStatusProvider);

    return AsyncValueWidget<RoutinesState>(
      value: routinesAsync,
      loggerName: 'RoutinesList',
      data: (state) {
        final routines = state.routines;
        if (routines.isEmpty) {
          return const TextPrompt();
        }
        return ListView.builder(
          padding: const EdgeInsets.all(10.0),
          itemCount: routines.length,
          itemBuilder: (context, index) {
            final currentRoutine = routines[index];
            final routineId = currentRoutine.id!;

            // The routine structure is fetched via REST. Offline it can only
            // be opened if it was already loaded earlier
            final canOpen = isOnline || currentRoutine.isHydrated;

            return Card(
              child: ListTile(
                enabled: canOpen,
                onTap: canOpen
                    ? () async {
                        if (isOnline) {
                          setState(() {
                            _loadingRoutine = routineId;
                          });
                          try {
                            await routineProvider.fetchAndSetRoutineFull(routineId);
                          } finally {
                            if (mounted) {
                              setState(() => _loadingRoutine = null);
                            }
                          }
                        }

                        if (context.mounted) {
                          Navigator.of(context).pushNamed(
                            RoutineScreen.routeName,
                            arguments: routineId,
                          );
                        }
                      }
                    : null,
                title: Text(currentRoutine.name),
                subtitle: Text(
                  '${dateFormat.format(currentRoutine.start)}'
                  ' - ${dateFormat.format(currentRoutine.end)}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!canOpen) const Icon(Icons.cloud_off),
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
                        onPressed: () => showConfirmDeleteDialog(
                          context,
                          itemName: currentRoutine.name,
                          onConfirm: () => routineProvider.deleteRoutine(currentRoutine.id!),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
