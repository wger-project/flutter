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
import 'package:provider/provider.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/widgets/routines/app_bar.dart';
import 'package:wger/widgets/routines/forms/routine.dart';
import 'package:wger/widgets/routines/routines_list.dart';

class RoutineListScreen extends StatelessWidget {
  const RoutineListScreen();

  static const routeName = '/workout-plans-list';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const RoutineListAppBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            FormScreen.routeName,
            arguments: FormScreenArguments(
              AppLocalizations.of(context).newRoutine,
              RoutineForm(Routine.empty(), useListView: true),
              hasListView: true,
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<RoutinesProvider>(
        builder: (context, workoutProvider, child) => RoutinesList(workoutProvider),
      ),
    );
  }
}
