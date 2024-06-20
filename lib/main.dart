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
import 'package:wger/core/locator.dart';
import 'package:wger/providers/add_exercise.dart';
import 'package:wger/providers/base_provider.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/providers/gallery.dart';
import 'package:wger/providers/measurement.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/providers/user.dart';
import 'package:wger/providers/workout_plans.dart';
import 'package:wger/screens/add_exercise_screen.dart';
import 'package:wger/screens/auth_screen.dart';
import 'package:wger/screens/dashboard.dart';
import 'package:wger/screens/exercise_screen.dart';
import 'package:wger/screens/exercises_screen.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/screens/gallery_screen.dart';
import 'package:wger/screens/gym_mode.dart';
import 'package:wger/screens/home_tabs_screen.dart';
import 'package:wger/screens/log_meal_screen.dart';
import 'package:wger/screens/log_meals_screen.dart';
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
import 'package:wger/widgets/core/about.dart';
import 'package:wger/widgets/core/settings.dart';

import 'providers/auth.dart';

void main() async {
  //zx.setLogEnabled(kDebugMode);

  // Needs to be called before runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Locator to initialize exerciseDB
  await ServiceLocator().configure();
  // Application
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp(); // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, ExercisesProvider>(
          create: (context) => ExercisesProvider(
            WgerBaseProvider(Provider.of(context, listen: false)),
          ),
          update: (context, base, previous) =>
              previous ?? ExercisesProvider(WgerBaseProvider(base)),
        ),
        ChangeNotifierProxyProvider2<AuthProvider, ExercisesProvider, WorkoutPlansProvider>(
          create: (context) => WorkoutPlansProvider(
            WgerBaseProvider(Provider.of(context, listen: false)),
            Provider.of(context, listen: false),
            [],
          ),
          update: (context, auth, exercises, previous) =>
              previous ?? WorkoutPlansProvider(WgerBaseProvider(auth), exercises, []),
        ),
        ChangeNotifierProxyProvider<AuthProvider, NutritionPlansProvider>(
          create: (context) => NutritionPlansProvider(
            WgerBaseProvider(Provider.of(context, listen: false)),
            [],
          ),
          update: (context, auth, previous) =>
              previous ?? NutritionPlansProvider(WgerBaseProvider(auth), []),
        ),
        ChangeNotifierProxyProvider<AuthProvider, MeasurementProvider>(
          create: (context) => MeasurementProvider(
            WgerBaseProvider(Provider.of(context, listen: false)),
          ),
          update: (context, base, previous) =>
              previous ?? MeasurementProvider(WgerBaseProvider(base)),
        ),
        ChangeNotifierProxyProvider<AuthProvider, UserProvider>(
          create: (context) => UserProvider(
            WgerBaseProvider(Provider.of(context, listen: false)),
          ),
          update: (context, base, previous) => previous ?? UserProvider(WgerBaseProvider(base)),
        ),
        ChangeNotifierProxyProvider<AuthProvider, BodyWeightProvider>(
          create: (context) => BodyWeightProvider(
            WgerBaseProvider(Provider.of(context, listen: false)),
          ),
          update: (context, base, previous) =>
              previous ?? BodyWeightProvider(WgerBaseProvider(base)),
        ),
        ChangeNotifierProxyProvider<AuthProvider, GalleryProvider>(
          create: (context) => GalleryProvider(
            Provider.of(context, listen: false),
            [],
          ),
          update: (context, auth, previous) => previous ?? GalleryProvider(auth, []),
        ),
        ChangeNotifierProxyProvider<AuthProvider, AddExerciseProvider>(
          create: (context) => AddExerciseProvider(
            WgerBaseProvider(Provider.of(context, listen: false)),
          ),
          update: (context, base, previous) =>
              previous ?? AddExerciseProvider(WgerBaseProvider(base)),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'wger',
          theme: wgerLightTheme,
          darkTheme: wgerDarkTheme,
          highContrastTheme: wgerLightThemeHc,
          highContrastDarkTheme: wgerDarkThemeHc,
          themeMode: ThemeMode.system,
          home: auth.isAuth
              ? const HomeTabsScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState == ConnectionState.waiting
                          ? const SplashScreen()
                          : const AuthScreen(),
                ),
          routes: {
            DashboardScreen.routeName: (ctx) => const DashboardScreen(),
            FormScreen.routeName: (ctx) => const FormScreen(),
            GalleryScreen.routeName: (ctx) => const GalleryScreen(),
            GymModeScreen.routeName: (ctx) => const GymModeScreen(),
            HomeTabsScreen.routeName: (ctx) => const HomeTabsScreen(),
            MeasurementCategoriesScreen.routeName: (ctx) => const MeasurementCategoriesScreen(),
            MeasurementEntriesScreen.routeName: (ctx) => const MeasurementEntriesScreen(),
            NutritionalPlansScreen.routeName: (ctx) => const NutritionalPlansScreen(),
            NutritionalDiaryScreen.routeName: (ctx) => const NutritionalDiaryScreen(),
            NutritionalPlanScreen.routeName: (ctx) => const NutritionalPlanScreen(),
            LogMealsScreen.routeName: (ctx) => const LogMealsScreen(),
            LogMealScreen.routeName: (ctx) => const LogMealScreen(),
            WeightScreen.routeName: (ctx) => const WeightScreen(),
            WorkoutPlanScreen.routeName: (ctx) => const WorkoutPlanScreen(),
            WorkoutPlansScreen.routeName: (ctx) => const WorkoutPlansScreen(),
            ExercisesScreen.routeName: (ctx) => const ExercisesScreen(),
            ExerciseDetailScreen.routeName: (ctx) => const ExerciseDetailScreen(),
            AddExerciseScreen.routeName: (ctx) => const AddExerciseScreen(),
            AboutPage.routeName: (ctx) => const AboutPage(),
            SettingsPage.routeName: (ctx) => const SettingsPage(),
          },
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
  }
}
