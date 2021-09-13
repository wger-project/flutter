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

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wger/providers/auth.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/providers/gallery.dart';
import 'package:wger/providers/measurement.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/providers/workout_plans.dart';
import 'package:wger/screens/dashboard.dart';
import 'package:wger/screens/exercises_screen.dart';
import 'package:wger/screens/gallery_screen.dart';
import 'package:wger/screens/weight_screen.dart';
import 'package:wger/screens/workout_plans_screen.dart';
import 'package:wger/theme/theme.dart';

class HomeTabsScreen extends StatefulWidget {
  static const routeName = '/dashboard2';

  @override
  _HomeTabsScreenState createState() => _HomeTabsScreenState();
}

class _HomeTabsScreenState extends State<HomeTabsScreen> with SingleTickerProviderStateMixin {
  late Future<void> _initialData;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Loading data here, since the build method can be called more than once
    _initialData = _loadEntries();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final _screenList = <Widget>[
    DashboardScreen(),
    WorkoutPlansScreen(),
    // Replaced [NutritionScreen] for debugging purposes
    ExercisesScreen(),
    WeightScreen(),
    GalleryScreen(),
  ];

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
      log('base data');
      await Future.wait([
        workoutPlansProvider.fetchAndSetUnits(),
        nutritionPlansProvider.fetchIngredientsFromCache(),
        exercisesProvider.fetchAndSetExercises(),
      ]);

      // Plans, weight and gallery
      log('Plans, weight, measurements and gallery');
      await Future.wait([
        galleryProvider.fetchAndSetGallery(),
        nutritionPlansProvider.fetchAndSetAllPlansSparse(),
        workoutPlansProvider.fetchAndSetAllPlansSparse(),
        weightProvider.fetchAndSetEntries(),
        measurementProvider.fetchAndSetAllCategoriesAndEntries(),
      ]);

      // Current nutritional plan
      log('Current nutritional plan');
      if (nutritionPlansProvider.currentPlan != null) {
        final plan = nutritionPlansProvider.currentPlan!;
        await nutritionPlansProvider.fetchAndSetPlanFull(plan.id!);
      }

      // Current workout plan
      log('Current workout plan');
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
    return FutureBuilder<void>(
      future: _initialData,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context).loadingText,
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  Padding(padding: EdgeInsets.symmetric(vertical: 8)),
                  LinearProgressIndicator(
                    backgroundColor: Theme.of(context).accentColor,
                  ),
                ],
              ),
            ),
          );
        } else {
          return Scaffold(
            body: _screenList.elementAt(_selectedIndex),
            bottomNavigationBar: BottomNavigationBar(
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard),
                  label: AppLocalizations.of(context).labelDashboard,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.fitness_center),
                  label: AppLocalizations.of(context).labelBottomNavWorkout,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.restaurant),
                  label: AppLocalizations.of(context).labelBottomNavNutrition,
                ),
                BottomNavigationBarItem(
                  icon: FaIcon(
                    FontAwesomeIcons.weight,
                    size: 20,
                  ),
                  label: AppLocalizations.of(context).weight,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.photo_library),
                  label: AppLocalizations.of(context).gallery,
                ),
              ],
              type: BottomNavigationBarType.fixed,
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.white,
              unselectedItemColor: wgerPrimaryColorLight,
              backgroundColor: wgerPrimaryColor,
              onTap: _onItemTapped,
              showUnselectedLabels: false,
            ),
          );
        }
      },
    );
  }
}
