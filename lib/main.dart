import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wger/providers/workout_plans.dart';
import 'package:wger/screens/auth_screen.dart';
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
            )
          ],
          child: MaterialApp(
            title: 'Flutter Demo',
            theme: wgerTheme,
            home: auth.isAuth
                ? HomeTabsScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, authResultSnapshot) =>
                        authResultSnapshot.connectionState ==
                                ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen(),
                  ),
            routes: {
              HomeTabsScreen.routeName: (ctx) => HomeTabsScreen(),
              WeightScreen.routeName: (ctx) => WeightScreen(),
              WorkoutPlansScreen.routeName: (ctx) => WorkoutPlansScreen(),
              WorkoutPlanScreen.routeName: (ctx) => WorkoutPlanScreen(),
              NutritionScreen.routeName: (ctx) => NutritionScreen(),
            },
          ),
        ),
      ),
    );
  }
}
