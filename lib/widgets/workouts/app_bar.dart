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
import 'package:wger/screens/add_exercise_screen.dart';
import 'package:wger/screens/exercises_screen.dart';

enum _WorkoutAppBarOptions {
  list,
  contribute,
}

class WorkoutOverviewAppBar extends StatelessWidget implements PreferredSizeWidget {
  const WorkoutOverviewAppBar();
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(AppLocalizations.of(context).labelWorkoutPlans),
      actions: [
        PopupMenuButton(
          itemBuilder: (context) {
            return [
              PopupMenuItem<_WorkoutAppBarOptions>(
                value: _WorkoutAppBarOptions.list,
                child: Text(AppLocalizations.of(context).exerciseList),
              ),
              PopupMenuItem<_WorkoutAppBarOptions>(
                value: _WorkoutAppBarOptions.contribute,
                child: Text(AppLocalizations.of(context).contributeExercise),
              ),
            ];
          },
          onSelected: (value) {
            switch (value) {
              case _WorkoutAppBarOptions.contribute:
                Navigator.of(context).pushNamed(AddExerciseScreen.routeName);
                break;
              case _WorkoutAppBarOptions.list:
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
