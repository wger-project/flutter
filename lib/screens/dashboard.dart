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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wger/providers/auth.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/providers/gallery.dart';
import 'package:wger/providers/measurement.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/providers/workout_plans.dart';
import 'package:wger/widgets/core/app_bar.dart';
import 'package:wger/widgets/dashboard/calendar.dart';
import 'package:wger/widgets/dashboard/widgets.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = '/dashboard';

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Future<void>? _initialData;

  @override
  void initState() {
    super.initState();

    // Loading data here, since the build method can be called more than once
    _initialData = _loadEntries();
  }

  /// Load initial data from the server
  Future<void> _loadEntries() async {
    if (!Provider.of<AuthProvider>(context, listen: false).dataInit) {
      Provider.of<AuthProvider>(context, listen: false).setServerVersion();

      final workoutPlansProvider = Provider.of<WorkoutPlansProvider>(context, listen: false);
      final nutritionPlansProvider = Provider.of<NutritionPlansProvider>(context, listen: false);
      final exercisesProvider = Provider.of<ExercisesProvider>(context, listen: false);
      final galleryProvider = Provider.of<GalleryProvider>(context, listen: false);
      final weightProvider = Provider.of<BodyWeightProvider>(context, listen: false);
      final measurementProvider = Provider.of<MeasurementProvider>(context, listen: false);

      // Base data
      await Future.wait([
        workoutPlansProvider.fetchAndSetUnits(),
        nutritionPlansProvider.fetchIngredientsFromCache(),
        exercisesProvider.fetchAndSetExercises(),
      ]);

      // Plans, weight and gallery
      await Future.wait([
        galleryProvider.fetchAndSetGallery(),
        nutritionPlansProvider.fetchAndSetAllPlansSparse(),
        workoutPlansProvider.fetchAndSetAllPlansSparse(),
        weightProvider.fetchAndSetEntries(),
        measurementProvider.fetchAndSetAllCategoriesAndEntries(),
      ]);

      // Current nutritional plan
      if (nutritionPlansProvider.currentPlan != null) {
        final plan = nutritionPlansProvider.currentPlan!;
        await nutritionPlansProvider.fetchAndSetPlanFull(plan.id!);
      }

      // Current workout plan
      if (workoutPlansProvider.activePlan != null) {
        final planId = workoutPlansProvider.activePlan!.id!;
        await workoutPlansProvider.fetchAndSetWorkoutPlanFull(planId);
        workoutPlansProvider.setCurrentPlan(planId);
      }
    }

    Provider.of<AuthProvider>(context, listen: false).dataInit = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WgerAppBar(AppLocalizations.of(context).labelDashboard),
      body: FutureBuilder(
        future: _initialData,
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
                        DashboardWorkoutWidget(),
                        DashboardNutritionWidget(),
                        DashboardWeightWidget(),
                        DashboardCalendarWidget(),
                      ],
                    ),
                  ),
      ),
    );
  }
}
