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

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/screens/add_exercise_screen.dart';
import 'package:wger/screens/exercises_screen.dart';
import 'package:wger/screens/routine_edit_screen.dart';
import 'package:wger/screens/routine_logs_screen.dart';

enum _RoutineAppBarOptions {
  list,
  contribute,
}

enum _RoutineDetailBarOptions {
  edit,
  delete,
  logs,
  reload,
}

class RoutineListAppBar extends StatelessWidget implements PreferredSizeWidget {
  const RoutineListAppBar();

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);

    return AppBar(
      title: Text(i18n.routines),
      actions: [
        PopupMenuButton(
          itemBuilder: (context) {
            return [
              PopupMenuItem<_RoutineAppBarOptions>(
                value: _RoutineAppBarOptions.list,
                child: Text(i18n.exerciseList),
              ),
              PopupMenuItem<_RoutineAppBarOptions>(
                value: _RoutineAppBarOptions.contribute,
                child: Text(i18n.contributeExercise),
              ),
            ];
          },
          onSelected: (value) {
            switch (value) {
              case _RoutineAppBarOptions.contribute:
                Navigator.of(context).pushNamed(AddExerciseScreen.routeName);
                break;
              case _RoutineAppBarOptions.list:
                Navigator.of(context).pushNamed(ExercisesScreen.routeName);
                break;
            }
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class RoutineDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Routine routine;

  const RoutineDetailAppBar(this.routine);

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final provider = context.read<RoutinesProvider>();

    return AppBar(
      title: Text(routine.name),
      actions: [
        PopupMenuButton(
          itemBuilder: (context) {
            return [
              const PopupMenuItem<_RoutineDetailBarOptions>(
                value: _RoutineDetailBarOptions.reload,
                child: Text('debug / reload'),
              ),
              PopupMenuItem<_RoutineDetailBarOptions>(
                value: _RoutineDetailBarOptions.logs,
                child: Text(i18n.labelWorkoutLogs),
              ),
              PopupMenuItem<_RoutineDetailBarOptions>(
                value: _RoutineDetailBarOptions.edit,
                child: Text(i18n.edit),
              ),
              PopupMenuItem<_RoutineDetailBarOptions>(
                value: _RoutineDetailBarOptions.delete,
                child: Text(i18n.delete),
              ),
            ];
          },
          onSelected: (value) async {
            switch (value) {
              case _RoutineDetailBarOptions.edit:
                Navigator.pushNamed(
                  context,
                  RoutineEditScreen.routeName,
                  arguments: routine.id,
                );

              case _RoutineDetailBarOptions.logs:
                Navigator.pushNamed(
                  context,
                  WorkoutLogsScreen.routeName,
                  arguments: routine,
                );

              case _RoutineDetailBarOptions.delete:
                provider.deleteRoutine(routine.id!);
                Navigator.of(context).pop();

              case _RoutineDetailBarOptions.reload:
                await provider.fetchAndSetRoutineFull(routine.id!);
            }
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
