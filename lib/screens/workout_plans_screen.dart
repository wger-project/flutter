/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wger/models/workouts/workout_plan.dart';
import 'package:wger/providers/workout_plans.dart';
import 'package:wger/widgets/app_drawer.dart';
import 'package:wger/widgets/core/bottom_sheet.dart';
import 'package:wger/widgets/core/core.dart';
import 'package:wger/widgets/workouts/forms.dart';
import 'package:wger/widgets/workouts/workout_plans_list.dart';

class WorkoutPlansScreen extends StatefulWidget {
  static const routeName = '/workout-plans-list';

  @override
  _WorkoutPlansScreenState createState() => _WorkoutPlansScreenState();
}

class _WorkoutPlansScreenState extends State<WorkoutPlansScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WgerAppBar(AppLocalizations.of(context)!.labelWorkoutPlans),
      drawer: AppDrawer(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showFormBottomSheet(
            context,
            AppLocalizations.of(context)!.newWorkout,
            WorkoutForm(WorkoutPlan()),
          );
        },
      ),
      body: Consumer<WorkoutPlans>(
        builder: (context, workoutProvider, child) => WorkoutPlansList(workoutProvider),
      ),
    );
  }
}
