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
import 'package:wger/models/routines/routine.dart';
import 'package:wger/providers/routine.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/widgets/routines/forms.dart';
import 'package:wger/widgets/routines/routine_detail.dart';
import 'package:wger/widgets/routines/workout_logs.dart';

enum RoutineScreenMode {
  routine,
  log,
}

enum RoutineOptions {
  edit,
  delete,
}

class RoutineScreen extends StatefulWidget {
  static const routeName = '/routine-detail';

  @override
  _RoutineScreenState createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  RoutineScreenMode _mode = RoutineScreenMode.routine;

  void _changeMode(RoutineScreenMode newMode) {
    setState(() {
      _mode = newMode;
    });
  }

  Future<Routine> _loadFullRoutine(BuildContext context, int planId) {
    return Provider.of<RoutineProvider>(context, listen: false).fetchAndSetRoutineFull(planId);
  }

  Widget getBody(Routine plan) {
    switch (_mode) {
      case RoutineScreenMode.routine:
        return RoutineDetail(plan, _changeMode);

      case RoutineScreenMode.log:
        return WorkoutLogs(plan, _changeMode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final workoutPlan = ModalRoute.of(context)!.settings.arguments as Routine;

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(workoutPlan.name),
              background: const Image(
                image: AssetImage('assets/images/backgrounds/workout_plans.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            actions: [
              PopupMenuButton<RoutineOptions>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  // Edit
                  if (value == RoutineOptions.edit) {
                    Navigator.pushNamed(
                      context,
                      FormScreen.routeName,
                      arguments: FormScreenArguments(
                        AppLocalizations.of(context).edit,
                        RoutineForm(workoutPlan),
                      ),
                    );

                    // Delete
                  } else if (value == RoutineOptions.delete) {
                    Provider.of<RoutineProvider>(context, listen: false)
                        .deleteRoutine(workoutPlan.id!);
                    Navigator.of(context).pop();

                    // Toggle Mode
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem<RoutineOptions>(
                      value: RoutineOptions.edit,
                      child: Text(AppLocalizations.of(context).edit),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem<RoutineOptions>(
                      value: RoutineOptions.delete,
                      child: Text(AppLocalizations.of(context).delete),
                    ),
                  ];
                },
              ),
            ],
          ),
          FutureBuilder(
            future: _loadFullRoutine(context, workoutPlan.id!),
            builder: (context, AsyncSnapshot<Routine> snapshot) => SliverList(
              delegate: SliverChildListDelegate(
                [
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const SizedBox(
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    Consumer<RoutineProvider>(
                      builder: (context, value, child) => getBody(workoutPlan),
                    ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
