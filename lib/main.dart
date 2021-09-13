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
import 'package:wger/providers/base_provider.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/providers/gallery.dart';
import 'package:wger/providers/measurement.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/providers/workout_plans.dart';
import 'package:wger/screens/auth_screen.dart';
import 'package:wger/screens/dashboard.dart';
import 'package:wger/screens/exercises_screen.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/screens/gallery_screen.dart';
import 'package:wger/screens/gym_mode.dart';
import 'package:wger/screens/home_tabs_screen.dart';
import 'package:wger/screens/measurement_categories_screen.dart';
import 'package:wger/screens/measurement_entries_screen.dart';
import 'package:wger/screens/nutritional_diary_screen.dart';
import 'package:wger/screens/nutritional_plan_screen.dart';
import 'package:wger/screens/nutritional_plans_screen.dart';
import 'package:wger/screens/splash_screen.dart';
import 'package:wger/screens/weight_screen.dart';
import 'package:wger/screens/workout_plan_screen.dart';
import 'package:wger/screens/workout_plans_screen.dart';
import 'package:wger/theme/theme.dart';

import 'providers/auth.dart';

void main() {
  // Needs to be called before runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Application
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => AuthProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ExercisesProvider>(
          create: (context) => ExercisesProvider(
              WgerBaseProvider(Provider.of<AuthProvider>(context, listen: false))),
          update: (context, base, previous) =>
              previous != null ? previous : ExercisesProvider(WgerBaseProvider(base)),
        ),
        ChangeNotifierProxyProvider2<AuthProvider, ExercisesProvider, WorkoutPlansProvider>(
          create: (context) => WorkoutPlansProvider(
            Provider.of<AuthProvider>(context, listen: false),
            Provider.of<ExercisesProvider>(context, listen: false),
            [],
          ),
          update: (context, auth, exercises, previous) =>
              previous != null ? previous : WorkoutPlansProvider(auth, exercises, []),
        ),
        ChangeNotifierProxyProvider<AuthProvider, NutritionPlansProvider>(
          create: (context) =>
              NutritionPlansProvider(Provider.of<AuthProvider>(context, listen: false), []),
          update: (context, auth, previous) =>
              previous != null ? previous : NutritionPlansProvider(auth, []),
        ),
        ChangeNotifierProxyProvider<AuthProvider, MeasurementProvider>(
          create: (context) => MeasurementProvider(
              WgerBaseProvider(Provider.of<AuthProvider>(context, listen: false))),
          update: (context, base, previous) =>
              previous != null ? previous : MeasurementProvider(WgerBaseProvider(base)),
        ),
        ChangeNotifierProxyProvider<AuthProvider, BodyWeightProvider>(
          create: (context) =>
              BodyWeightProvider(Provider.of<AuthProvider>(context, listen: false), []),
          update: (context, auth, previous) =>
              previous != null ? previous : BodyWeightProvider(auth, []),
        ),
        ChangeNotifierProxyProvider<AuthProvider, GalleryProvider>(
          create: (context) =>
              GalleryProvider(Provider.of<AuthProvider>(context, listen: false), []),
          update: (context, auth, previous) =>
              previous != null ? previous : GalleryProvider(auth, []),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'wger',
          theme: wgerTheme,
          home: auth.isAuth
              ? HomeTabsScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            DashboardScreen.routeName: (ctx) => DashboardScreen(),
            FormScreen.routeName: (ctx) => FormScreen(),
            GalleryScreen.routeName: (ctx) => GalleryScreen(),
            GymModeScreen.routeName: (ctx) => GymModeScreen(),
            HomeTabsScreen.routeName: (ctx) => HomeTabsScreen(),
            MeasurementCategoriesScreen.routeName: (ctx) => MeasurementCategoriesScreen(),
            MeasurementEntriesScreen.routeName: (ctx) => MeasurementEntriesScreen(),
            NutritionScreen.routeName: (ctx) => NutritionScreen(),
            NutritionalDiaryScreen.routeName: (ctx) => NutritionalDiaryScreen(),
            NutritionalPlanScreen.routeName: (ctx) => NutritionalPlanScreen(),
            WeightScreen.routeName: (ctx) => WeightScreen(),
            WorkoutPlanScreen.routeName: (ctx) => WorkoutPlanScreen(),
            WorkoutPlansScreen.routeName: (ctx) => WorkoutPlansScreen(),
            ExercisesScreen.routeName: (ctx) => ExercisesScreen(),
          },
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
