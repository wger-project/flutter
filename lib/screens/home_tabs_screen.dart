/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020,  wger Team
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/auth.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/providers/exercise_state_notifier.dart';
import 'package:wger/providers/gallery.dart';
import 'package:wger/providers/measurement.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/providers/user.dart';
import 'package:wger/providers/workout_session.dart';
import 'package:wger/screens/dashboard.dart';
import 'package:wger/screens/gallery_screen.dart';
import 'package:wger/screens/nutritional_plans_screen.dart';
import 'package:wger/screens/routine_list_screen.dart';
import 'package:wger/screens/weight_screen.dart';

class EagerInitialization extends riverpod.ConsumerWidget {
  const EagerInitialization();

  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    // TODO: do we need all of these here?
    ref.watch(exerciseStateProvider);
    ref.watch(workoutSessionProvider);
    ref.watch(routinesChangeProvider);
    return HomeTabsScreen();
  }
}

class HomeTabsScreen extends riverpod.ConsumerStatefulWidget {
  final _logger = Logger('HomeTabsScreen');

  HomeTabsScreen();

  static const routeName = '/dashboard2';

  @override
  _HomeTabsScreenState createState() => _HomeTabsScreenState();
}

class _HomeTabsScreenState extends riverpod.ConsumerState<HomeTabsScreen>
    with SingleTickerProviderStateMixin {
  late Future<void> _initialData;
  bool _errorHandled = false;
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

  final _screenList = [
    const DashboardScreen(),
    const RoutineListScreen(),
    const NutritionalPlansScreen(),
    const WeightScreen(),
    const GalleryScreen(),
  ];

  /// Load initial data from the server
  Future<void> _loadEntries() async {
    final authProvider = context.read<AuthProvider>();

    if (!authProvider.dataInit) {
      final routinesProvider = ref.read(routinesChangeProvider);
      final nutritionPlansProvider = context.read<NutritionPlansProvider>();
      final galleryProvider = context.read<GalleryProvider>();
      final measurementProvider = context.read<MeasurementProvider>();
      final userProvider = context.read<UserProvider>();

      //
      // Base data
      widget._logger.info('Loading base data');
      await Future.wait([
        authProvider.setServerVersion(),
        userProvider.fetchAndSetProfile(),
        nutritionPlansProvider.fetchIngredientsFromCache(),
      ]);
      // await ref.read(routineWeightUnitProvider.future);
      await ref.read(exerciseStateReadyProvider.future);
      await ref.read(sessionStateReadyProvider.future);
      ref.read(weightEntryProvider());

      //
      // Plans, weight and gallery
      widget._logger.info('Loading routines, weight, measurements and gallery');
      await Future.wait([
        galleryProvider.fetchAndSetGallery(),
        nutritionPlansProvider.fetchAndSetAllPlansSparse(),
        routinesProvider.fetchAndSetAllRoutinesSparse(),
        // routinesProvider.fetchAndSetAllRoutinesFull(),
        measurementProvider.fetchAndSetAllCategoriesAndEntries(),
      ]);

      //
      // Current nutritional plan
      widget._logger.info('Loading current nutritional plan');
      if (nutritionPlansProvider.currentPlan != null) {
        final plan = nutritionPlansProvider.currentPlan!;
        await nutritionPlansProvider.fetchAndSetPlanFull(plan.id!);
      }

      //
      // Current routine
      widget._logger.info('Loading current routine');
      if (routinesProvider.currentRoutine != null) {
        final routineId = routinesProvider.currentRoutine!.id!;
        widget._logger.finer('Current routine ID: $routineId');
        await routinesProvider.fetchAndSetRoutineFull(routinesProvider.currentRoutine!.id!);
      }
    }

    authProvider.dataInit = true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initialData,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          // Throw the original error with the original stack trace, otherwise
          // the error will only point to these lines here
          if (!_errorHandled) {
            _errorHandled = true;
            final error = snapshot.error;
            final stackTrace = snapshot.stackTrace;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                if (error != null && stackTrace != null) {
                  throw Error.throwWithStackTrace(error, stackTrace);
                }
                throw error!;
              }
            });
          }

          // Note that we continue to show the app, even if there was an error.
          // return const Scaffold(body: LoadingWidget());
        }

        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: LoadingWidget(),
          );
        }

        return Scaffold(
          body: _screenList.elementAt(_selectedIndex),
          bottomNavigationBar: NavigationBar(
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home),
                label: AppLocalizations.of(context).labelDashboard,
              ),
              NavigationDestination(
                icon: const Icon(Icons.fitness_center),
                label: AppLocalizations.of(context).labelBottomNavWorkout,
              ),
              NavigationDestination(
                icon: const Icon(Icons.restaurant),
                label: AppLocalizations.of(context).labelBottomNavNutrition,
              ),
              NavigationDestination(
                icon: const FaIcon(FontAwesomeIcons.weightScale, size: 20),
                label: AppLocalizations.of(context).weight,
              ),
              NavigationDestination(
                icon: const Icon(Icons.photo_library),
                label: AppLocalizations.of(context).gallery,
              ),
            ],
            onDestinationSelected: _onItemTapped,
            selectedIndex: _selectedIndex,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          ),
        );
      },
    );
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(
            child: SizedBox(
              height: 70,
              child: RiveAnimation.asset(
                'assets/animations/wger_logo.riv',
                animations: ['idle_loop2'],
              ),
            ),
          ),
          Text(
            AppLocalizations.of(context).loadingText,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ),
    );
  }
}
