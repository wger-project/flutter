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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/screens/routine_logs_screen.dart';
import 'package:wger/theme/theme.dart';
import 'package:wger/widgets/routines/forms.dart';
import 'package:wger/widgets/routines/routine_detail.dart';

enum WorkoutOptions {
  edit,
  delete,
  logs,
}

class RoutineScreen extends StatelessWidget {
  const RoutineScreen();

  static const routeName = '/routine-detail';

  Future<Routine> _loadFullWorkout(BuildContext context, int routineId) {
    return Provider.of<RoutinesProvider>(context, listen: false)
        .fetchAndSetWorkoutPlanFull(routineId);
  }

  @override
  Widget build(BuildContext context) {
    const appBarForeground = Colors.white;
    final routine = ModalRoute.of(context)!.settings.arguments as Routine;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            iconTheme: const IconThemeData(color: appBarForeground),
            backgroundColor: wgerPrimaryColor,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(56, 0, 56, 16),
              title: Text(
                routine.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: appBarForeground),
              ),
            ),
            actions: [
              PopupMenuButton<WorkoutOptions>(
                icon: const Icon(Icons.more_vert, color: appBarForeground),
                onSelected: (value) {
                  switch (value) {
                    case WorkoutOptions.edit:
                      Navigator.pushNamed(
                        context,
                        FormScreen.routeName,
                        arguments: FormScreenArguments(
                          AppLocalizations.of(context).edit,
                          WorkoutForm(routine),
                        ),
                      );

                    case WorkoutOptions.logs:
                      Navigator.pushNamed(
                        context,
                        WorkoutLogsScreen.routeName,
                        arguments: routine,
                      );

                    case WorkoutOptions.delete:
                      Provider.of<RoutinesProvider>(context, listen: false)
                          .deleteWorkout(routine.id!);
                      Navigator.of(context).pop();
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem<WorkoutOptions>(
                      value: WorkoutOptions.logs,
                      child: Text(AppLocalizations.of(context).labelWorkoutLogs),
                    ),
                    PopupMenuItem<WorkoutOptions>(
                      value: WorkoutOptions.edit,
                      child: Text(AppLocalizations.of(context).edit),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem<WorkoutOptions>(
                      value: WorkoutOptions.delete,
                      child: Text(AppLocalizations.of(context).delete),
                    ),
                  ];
                },
              ),
            ],
          ),
          FutureBuilder(
            future: _loadFullWorkout(context, routine.id!),
            builder: (context, AsyncSnapshot<Routine> snapshot) => SliverList(
              delegate: SliverChildListDelegate(
                [
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    Consumer<RoutinesProvider>(
                      builder: (context, value, child) => RoutineDetail(routine),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}