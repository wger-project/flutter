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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:wger/core/locator.dart';
import 'package:wger/exceptions/http_exception.dart';
import 'package:wger/helpers/errors.dart';
import 'package:wger/helpers/shared_preferences.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/add_exercise.dart';
import 'package:wger/providers/base_provider.dart';
import 'package:wger/providers/exercise_state_notifier.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/providers/gallery.dart';
import 'package:wger/providers/measurement.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/providers/user.dart';
import 'package:wger/providers/wger_base_riverpod.dart';
import 'package:wger/screens/add_exercise_screen.dart';
import 'package:wger/screens/auth_screen.dart';
import 'package:wger/screens/configure_plates_screen.dart';
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
import 'package:wger/screens/routine_edit_screen.dart';
import 'package:wger/screens/routine_list_screen.dart';
import 'package:wger/screens/routine_logs_screen.dart';
import 'package:wger/screens/routine_screen.dart';
import 'package:wger/screens/splash_screen.dart';
import 'package:wger/screens/update_app_screen.dart';
import 'package:wger/screens/weight_screen.dart';
import 'package:wger/theme/theme.dart';
import 'package:wger/widgets/core/about.dart';
import 'package:wger/widgets/core/log_overview.dart';
import 'package:wger/widgets/core/settings.dart';

import 'helpers/logs.dart';
import 'models/workouts/repetition_unit.dart';
import 'models/workouts/weight_unit.dart';
import 'providers/auth.dart';

void _setupLogging() {
  Logger.root.level = kDebugMode ? Level.ALL : Level.INFO;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time} [${record.loggerName}] ${record.message}');
    InMemoryLogStore().add(record);
  });
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // Needs to be called before runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Logger
  _setupLogging();

  final logger = Logger('main');

  // Locator to initialize exerciseDB
  await ServiceLocator().configure();

  // SharedPreferences to SharedPreferencesAsync migration function
  await PreferenceHelper.instance.migrationSupportFunctionForSharedPreferences();

  // Catch errors from Flutter itself (widget build, layout, paint, etc.)
  //
  // NOTE: it seems this sometimes makes problems and even freezes the flutter
  //       process when widgets overflow, so it is disabled in dev mode.
  if (!kDebugMode) {
    FlutterError.onError = (FlutterErrorDetails details) {
      final stack = details.stack ?? StackTrace.empty;
      logger.severe('Error caught by FlutterError.onError: ${details.exception}');

      FlutterError.dumpErrorToConsole(details);

      // Don't show the full error dialog for network image loading errors.
      if (details.exception is NetworkImageLoadException) {
        return;
      }

      showGeneralErrorDialog(details.exception, stack);
      // throw details.exception;
    };
  }

  // Catch errors that happen outside of the Flutter framework (e.g., in async operations)
  PlatformDispatcher.instance.onError = (error, stack) {
    logger.severe('Error caught by PlatformDispatcher.instance.onError: $error');
    logger.severe('Stack trace: $stack');

    if (error is WgerHttpException) {
      showHttpExceptionErrorDialog(error);
    } else {
      showGeneralErrorDialog(error, stack);
    }

    // Return true to indicate that the error has been handled.
    return true;
  };

  // Application
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp();

  Widget _getHomeScreen(AuthProvider auth) {
    switch (auth.state) {
      case AuthState.loggedIn:
        return HomeTabsScreen();
      case AuthState.updateRequired:
        return const UpdateAppScreen();
      default:
        return FutureBuilder(
          future: auth.tryAutoLogin(),
          builder: (ctx, authResultSnapshot) =>
              authResultSnapshot.connectionState == ConnectionState.waiting
              ? const SplashScreen()
              : const AuthScreen(),
        );
    }
  }

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
        ChangeNotifierProxyProvider<AuthProvider, RoutinesProvider>(
          create: (context) => RoutinesProvider(
            WgerBaseProvider(Provider.of(context, listen: false)),
            exercises: [],
          ),
          update: (context, auth, previous) =>
              previous ??
              RoutinesProvider(
                WgerBaseProvider(auth),
                exercises: [],
              ),
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
        builder: (ctx, auth, _) {
          final baseInstance = WgerBaseProvider(Provider.of(ctx, listen: false));

          return Consumer<UserProvider>(
            builder: (ctx, user, _) => riverpod.ProviderScope(
              overrides: [
                wgerBaseProvider.overrideWithValue(baseInstance),
              ],
              child: riverpod.Consumer(
                builder: (rpCtx, ref, _) {
                  final exerciseState = ref.watch(exerciseStateProvider);
                  final exercises = exerciseState.exercises;

                  final repetitionUnitsAsync = ref.watch(routineRepetitionUnitProvider);
                  final repetitionUnits = repetitionUnitsAsync.value ?? <RepetitionUnit>[];

                  final weightUnitsAsync = ref.watch(routineWeightUnitProvider);
                  final weightUnits = weightUnitsAsync.value ?? <WeightUnit>[];

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Provider.of<RoutinesProvider>(ctx, listen: false).exercises = exercises;
                    Provider.of<RoutinesProvider>(ctx, listen: false).repetitionUnits =
                        repetitionUnits;
                    Provider.of<RoutinesProvider>(ctx, listen: false).weightUnits = weightUnits;
                  });
                  return MaterialApp(
                    title: 'wger',
                    navigatorKey: navigatorKey,
                    theme: wgerLightTheme,
                    darkTheme: wgerDarkTheme,
                    highContrastTheme: wgerLightThemeHc,
                    highContrastDarkTheme: wgerDarkThemeHc,
                    themeMode: user.themeMode,
                    home: _getHomeScreen(auth),
                    routes: {
                      DashboardScreen.routeName: (ctx) => const DashboardScreen(),
                      FormScreen.routeName: (ctx) => const FormScreen(),
                      GalleryScreen.routeName: (ctx) => const GalleryScreen(),
                      GymModeScreen.routeName: (ctx) => const GymModeScreen(),
                      HomeTabsScreen.routeName: (ctx) => HomeTabsScreen(),
                      MeasurementCategoriesScreen.routeName: (ctx) =>
                          const MeasurementCategoriesScreen(),
                      MeasurementEntriesScreen.routeName: (ctx) => const MeasurementEntriesScreen(),
                      NutritionalPlansScreen.routeName: (ctx) => const NutritionalPlansScreen(),
                      NutritionalDiaryScreen.routeName: (ctx) => const NutritionalDiaryScreen(),
                      NutritionalPlanScreen.routeName: (ctx) => const NutritionalPlanScreen(),
                      LogMealsScreen.routeName: (ctx) => const LogMealsScreen(),
                      LogMealScreen.routeName: (ctx) => const LogMealScreen(),
                      WeightScreen.routeName: (ctx) => const WeightScreen(),
                      RoutineScreen.routeName: (ctx) => const RoutineScreen(),
                      RoutineEditScreen.routeName: (ctx) => const RoutineEditScreen(),
                      WorkoutLogsScreen.routeName: (ctx) => const WorkoutLogsScreen(),
                      RoutineListScreen.routeName: (ctx) => const RoutineListScreen(),
                      ExercisesScreen.routeName: (ctx) => const ExercisesScreen(),
                      ExerciseDetailScreen.routeName: (ctx) => const ExerciseDetailScreen(),
                      AddExerciseScreen.routeName: (ctx) => const AddExerciseScreen(),
                      AboutPage.routeName: (ctx) => const AboutPage(),
                      SettingsPage.routeName: (ctx) => const SettingsPage(),
                      LogOverviewPage.routeName: (ctx) => const LogOverviewPage(),
                      ConfigurePlatesScreen.routeName: (ctx) => const ConfigurePlatesScreen(),
                    },
                    localizationsDelegates: AppLocalizations.localizationsDelegates,
                    supportedLocales: AppLocalizations.supportedLocales,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
