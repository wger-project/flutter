/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:wger/core/exceptions/http_exception.dart';
import 'package:wger/helpers/errors.dart';
import 'package:wger/helpers/shared_preferences.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/app_settings_notifier.dart';
import 'package:wger/providers/auth_notifier.dart';
import 'package:wger/providers/auth_state.dart';
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
import 'package:wger/screens/routine_edit_screen.dart';
import 'package:wger/screens/routine_list_screen.dart';
import 'package:wger/screens/routine_logs_screen.dart';
import 'package:wger/screens/routine_screen.dart';
import 'package:wger/screens/settings_dashboard_widgets_screen.dart';
import 'package:wger/screens/settings_plates_screen.dart';
import 'package:wger/screens/splash_screen.dart';
import 'package:wger/screens/trophy_screen.dart';
import 'package:wger/screens/update_app_screen.dart';
import 'package:wger/screens/update_server_screen.dart';
import 'package:wger/screens/weight_screen.dart';
import 'package:wger/theme/theme.dart';
import 'package:wger/widgets/core/about.dart';
import 'package:wger/widgets/core/log_overview.dart';
import 'package:wger/widgets/core/settings.dart';

import 'helpers/logs.dart';

void _setupLogging() {
  Logger.root.level = kDebugMode ? Level.ALL : Level.INFO;
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
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
    // Skip the StackFrame assertion error from the stack_trace package.
    // This is a known Flutter framework issue where async gap markers in stack
    // traces cause an assertion failure in StackFrame.fromStackTraceLine.
    if (error is AssertionError && error.toString().contains('asynchronous gap')) {
      logger.warning('Suppressed StackFrame assertion error (known Flutter issue)');
      return true;
    }

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
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp();

  Widget _getHomeScreen(AuthState auth) {
    switch (auth.status) {
      case AuthStatus.loggedIn:
        return const EagerInitialization();
      case AuthStatus.updateRequired:
        return const UpdateAppScreen();
      case AuthStatus.serverUpdateRequired:
        return const UpdateServerScreen();
      case AuthStatus.loggedOut:
        return const AuthScreen();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authProvider);

    return authAsync.when(
      loading: () => const MaterialApp(home: SplashScreen()),
      error: (error, stack) => MaterialApp(
        home: Scaffold(body: Center(child: Text('$error'))),
      ),
      data: (authState) {
        final themeMode = ref.watch(
          appSettingsProvider.select((s) => s.value?.themeMode ?? ThemeMode.system),
        );

        return MaterialApp(
          title: 'wger',
          navigatorKey: navigatorKey,
          theme: wgerLightTheme,
          darkTheme: wgerDarkTheme,
          highContrastTheme: wgerLightThemeHc,
          highContrastDarkTheme: wgerDarkThemeHc,
          themeMode: themeMode,
          home: _getHomeScreen(authState),
          routes: {
            DashboardScreen.routeName: (ctx) => const DashboardScreen(),
            FormScreen.routeName: (ctx) => const FormScreen(),
            GalleryScreen.routeName: (ctx) => const GalleryScreen(),
            GymModeScreen.routeName: (ctx) => const GymModeScreen(),
            HomeTabsScreen.routeName: (ctx) => HomeTabsScreen(),
            MeasurementCategoriesScreen.routeName: (ctx) => const MeasurementCategoriesScreen(),
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
            ConfigureDashboardWidgetsScreen.routeName: (ctx) =>
                const ConfigureDashboardWidgetsScreen(),
            TrophyScreen.routeName: (ctx) => const TrophyScreen(),
          },
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        );
      },
    );
  }
}
