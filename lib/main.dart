import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wger/locale/locales.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/providers/nutritional_plans.dart';
import 'package:wger/providers/workout_plans.dart';
import 'package:wger/screens/auth_screen.dart';
import 'package:wger/screens/dashboard.dart';
import 'package:wger/screens/home_tabs_screen.dart';
import 'package:wger/screens/nutrition_screen.dart';
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
    return ChangeNotifierProvider(
      create: (_) => Auth(),
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (ctx) => Auth(),
            ),
            ChangeNotifierProxyProvider<Auth, WorkoutPlans>(
              create: null, // TODO: Create is required but it can be null??
              update: (context, value, previous) => WorkoutPlans(
                auth,
                previous == null ? [] : previous.items,
              ),
            ),
            ChangeNotifierProxyProvider<Auth, Exercises>(
              create: null, // TODO: Create is required but it can be null??
              update: (context, value, previous) => Exercises(
                auth,
                previous == null ? [] : previous.items,
              ),
            ),
            ChangeNotifierProxyProvider<Auth, NutritionalPlans>(
              create: null, // TODO: Create is required but it can be null??
              update: (context, value, previous) => NutritionalPlans(
                auth,
                previous == null ? [] : previous.items,
              ),
            ),
            ChangeNotifierProxyProvider<Auth, BodyWeight>(
              create: null, // TODO: Create is required but it can be null??
              update: (context, value, previous) => BodyWeight(
                auth,
                previous == null ? [] : previous.items,
              ),
            )
          ],
          child: MaterialApp(
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
      ),
    );
  }
}
