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
import 'package:provider/provider.dart';
import 'package:wger/locale/locales.dart';
import 'package:wger/providers/auth.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/providers/workout_plans.dart';
import 'package:wger/widgets/app_drawer.dart';
import 'package:wger/widgets/dashboard/calendar.dart';
import 'package:wger/widgets/dashboard/widgets.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = '/dashboard';

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Widget getAppBar() {
    return AppBar(
      title: Text(AppLocalizations.of(context).labelDashboard),
      actions: [],
    );
  }

  /// Load initial data from the server
  Future<void> _loadEntries(BuildContext context) async {
    if (!Provider.of<Auth>(context, listen: false).dataInit) {
      // Exercises
      await Provider.of<Exercises>(context, listen: false).fetchAndSetExercises();

      // Nutrition
      Nutrition nutritionProvider = Provider.of<Nutrition>(context, listen: false);
      await nutritionProvider.fetchIngredientsFromCache();
      await nutritionProvider.fetchAndSetPlans();
      await nutritionProvider.fetchAndSetAllLogs();

      // Workouts
      WorkoutPlans workoutProvider = Provider.of<WorkoutPlans>(context, listen: false);
      await workoutProvider.fetchAndSetWorkouts();
      await workoutProvider.setAllFullWorkouts();

      // Weight
      await Provider.of<BodyWeight>(context, listen: false).fetchAndSetEntries();
    }
    Provider.of<Auth>(context, listen: false).dataInit = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _loadEntries(context),
        builder: (ctx, authResultSnapshot) =>
            authResultSnapshot.connectionState == ConnectionState.waiting
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context).loadingText,
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      Padding(padding: EdgeInsets.symmetric(vertical: 8)),
                      LinearProgressIndicator(),
                    ],
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        DashboardWorkoutWidget(context: context),
                        DashboardNutritionWidget(context: context),
                        DashboardWeightWidget(context: context),
                        Container(
                          height: 650, // TODO: refactor calendar so we can get rid of size
                          child: DashboardCalendarWidget(title: 'Calendar'),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
