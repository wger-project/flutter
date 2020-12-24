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

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wger/locale/locales.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/providers/workout_plans.dart';
import 'package:wger/screens/auth_screen.dart';
import 'package:wger/screens/dashboard.dart';
import 'package:wger/screens/home_tabs_screen.dart';
import 'package:wger/screens/nutritional_plans_screen.dart';
import 'package:wger/screens/nutritrional_plan_screen.dart';
import 'package:wger/screens/splash_screen.dart';
import 'package:wger/screens/weight_screen.dart';
import 'package:wger/screens/workout_plan_screen.dart';
import 'package:wger/screens/workout_plans_screen.dart';
import 'package:wger/theme/theme.dart';

import 'providers/auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, WorkoutPlans>(
          create: null, // TODO: Create is required but it can be null??
          update: (context, auth, previous) => WorkoutPlans(
            auth,
            previous == null ? [] : previous.items,
          ),
        ),
        ChangeNotifierProxyProvider<Auth, Exercises>(
          create: null, // TODO: Create is required but it can be null??
          update: (context, auth, previous) => Exercises(
            auth,
            previous == null ? [] : previous.items,
          ),
        ),
        ChangeNotifierProxyProvider<Auth, Nutrition>(
          create: null, // TODO: Create is required but it can be null??
          update: (context, auth, previous) => Nutrition(
            auth,
            previous == null ? [] : previous.items,
          ),
        ),
        ChangeNotifierProxyProvider<Auth, BodyWeight>(
          create: null, // TODO: Create is required but it can be null??
          update: (context, auth, previous) => BodyWeight(
            auth,
            previous == null ? [] : previous.items,
          ),
        )
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'wger',
          theme: wgerTheme,
          home: auth.isAuth
              ? DashboardScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            DashboardScreen.routeName: (ctx) => DashboardScreen(),
            HomeTabsScreen.routeName: (ctx) => HomeTabsScreen(),
            WeightScreen.routeName: (ctx) => WeightScreen(),
            WorkoutPlansScreen.routeName: (ctx) => WorkoutPlansScreen(),
            WorkoutPlanScreen.routeName: (ctx) => WorkoutPlanScreen(),
            NutritionScreen.routeName: (ctx) => NutritionScreen(),
            NutritrionalPlanScreen.routeName: (ctx) => NutritrionalPlanScreen(),
          },
          localizationsDelegates: [
            // ... app-specific localization delegate[s] here
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            const Locale('en', ''), // English
            const Locale('de', ''), // German
          ],
        ),
      ),
    );
  }
}
