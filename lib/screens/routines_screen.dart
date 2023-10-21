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
import 'package:wger/widgets/routines/app_bar.dart';
import 'package:wger/widgets/routines/forms.dart';
import 'package:wger/widgets/routines/routines_list.dart';

class RoutinesScreen extends StatelessWidget {
  static const routeName = '/routine-list';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WorkoutOverviewAppBar(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(
            context,
            FormScreen.routeName,
            arguments: FormScreenArguments(
              AppLocalizations.of(context).newWorkout,
              RoutineForm(Routine.empty()),
            ),
          );
        },
      ),
      body: Consumer<RoutineProvider>(
        builder: (context, workoutProvider, child) => RoutinesList(workoutProvider),
      ),
    );
  }
}
