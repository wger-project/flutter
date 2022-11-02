import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:user_profile_ii_example/page/profile_page.dart';
import 'package:user_profile_ii_example/themes.dart';
import 'package:user_profile_ii_example/utils/user_preferences.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
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

import 'providers/auth.dart';


Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static final String title = 'User Profile';

  @override
  Widget build(BuildContext context) {

    final user = UserPreferences.myUser;

    return ThemeProvider(
      initTheme: user.isDarkMode ? MyThemes.darkTheme : MyThemes.lightTheme,
      child: Builder(
        builder: (context) => MaterialApp(

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => AuthProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ExercisesProvider>(
          create: (context) => ExercisesProvider(
              WgerBaseProvider(Provider.of<AuthProvider>(context, listen: false))),
          update: (context, base, previous) =>
              previous ?? ExercisesProvider(WgerBaseProvider(base)),
        ),
        ChangeNotifierProxyProvider2<AuthProvider, ExercisesProvider, WorkoutPlansProvider>(
          create: (context) => WorkoutPlansProvider(
            Provider.of<AuthProvider>(context, listen: false),
            Provider.of<ExercisesProvider>(context, listen: false),
            [],
          ),
          update: (context, auth, exercises, previous) =>
              previous ?? WorkoutPlansProvider(auth, exercises, []),
        ),
        ChangeNotifierProxyProvider<AuthProvider, NutritionPlansProvider>(
          create: (context) =>
              NutritionPlansProvider(Provider.of<AuthProvider>(context, listen: false), []),
          update: (context, auth, previous) => previous ?? NutritionPlansProvider(auth, []),
        ),
        ChangeNotifierProxyProvider<AuthProvider, MeasurementProvider>(
          create: (context) => MeasurementProvider(
            WgerBaseProvider(Provider.of<AuthProvider>(context, listen: false)),
          ),
          update: (context, base, previous) =>
              previous ?? MeasurementProvider(WgerBaseProvider(base)),
        ),
        ChangeNotifierProxyProvider<AuthProvider, UserProvider>(
          create: (context) => UserProvider(
            WgerBaseProvider(Provider.of<AuthProvider>(context, listen: false)),
          ),
          update: (context, base, previous) => previous ?? UserProvider(WgerBaseProvider(base)),
        ),
        ChangeNotifierProxyProvider<AuthProvider, BodyWeightProvider>(
          create: (context) =>
              BodyWeightProvider(Provider.of<AuthProvider>(context, listen: false), []),
          update: (context, auth, previous) => previous ?? BodyWeightProvider(auth, []),
        ),
        ChangeNotifierProxyProvider<AuthProvider, GalleryProvider>(
          create: (context) =>
              GalleryProvider(Provider.of<AuthProvider>(context, listen: false), []),
          update: (context, auth, previous) => previous ?? GalleryProvider(auth, []),
        ),
        ChangeNotifierProxyProvider<AuthProvider, AddExerciseProvider>(
          create: (context) => AddExerciseProvider(
            WgerBaseProvider(Provider.of<AuthProvider>(context, listen: false)),
          ),
          update: (context, base, previous) =>
              previous ?? AddExerciseProvider(WgerBaseProvider(base)),
        )
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
            GalleryScreen.routeName: (ctx) => const GalleryScreen(),
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
            ExercisesScreen.routeName: (ctx) => const ExercisesScreen(),
            ExerciseDetailScreen.routeName: (ctx) => const ExerciseDetailScreen(),
            AddExerciseScreen.routeName: (ctx) => const AddExerciseScreen(),
            AboutPage.routeName: (ctx) => const AboutPage(),
          },
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,

          debugShowCheckedModeBanner: false,
          theme: ThemeModelInheritedNotifier.of(context).theme,
          title: title,
          home: ProfilePage(),
        ),
      ),
    );
  }
}
