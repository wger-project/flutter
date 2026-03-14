/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2026 wger Team
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
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/measurements/measurement_category.dart';
import 'package:wger/providers/auth.dart';
import 'package:wger/providers/body_weight_repository.dart';
import 'package:wger/providers/gallery.dart';
import 'package:wger/providers/measurement_repository.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/providers/user.dart';
import 'package:wger/screens/home_tabs_screen.dart';
import 'package:wger/theme/theme.dart';

import '../test/exercises/contribute_exercise_test.mocks.dart';
import '../test/gallery/gallery_form_test.mocks.dart';
import '../test/measurements/measurement_categories_screen_test.mocks.dart';
import '../test/nutrition/nutritional_plan_screen_test.mocks.dart';
import '../test/weight/weight_screen_test.mocks.dart' as weight;
import '../test_data/body_weight.dart';
import '../test_data/exercises.dart';
import '../test_data/measurements.dart';
import '../test_data/nutritional_plans.dart';
import '../test_data/profile.dart';
import '../test_data/routines.dart';

Widget createDashboardScreen({Locale? locale}) {
  locale ??= const Locale('en');

  final mockGalleryProvider = MockGalleryProvider();

  final mockAuthProvider = MockAuthProvider();
  when(mockAuthProvider.setServerVersion()).thenAnswer((_) async {});
  when(mockAuthProvider.dataInit).thenReturn(true);

  final mockNutritionProvider = weight.MockNutritionPlansProvider();

  when(
    mockNutritionProvider.currentPlan,
  ).thenAnswer((realInvocation) => getNutritionalPlanScreenshot());
  when(mockNutritionProvider.items).thenReturn([getNutritionalPlanScreenshot()]);

  final mockBodyWeightRepository = MockBodyWeightRepository();
  when(
    mockBodyWeightRepository.watchAllDrift(),
  ).thenAnswer((_) => Stream.value(getWeightEntries()));

  final mockMeasurementRepo = MockMeasurementRepository();
  when(
    mockMeasurementRepo.watchAll(),
  ).thenAnswer((_) => Stream<List<MeasurementCategory>>.value(getMeasurementCategories()));

  final mockUserProvider = MockUserProvider();
  when(mockUserProvider.profile).thenReturn(tProfile1);

  final container = riverpod.ProviderContainer.test(
    overrides: [
      bodyWeightRepositoryProvider.overrideWithValue(mockBodyWeightRepository),
      measurementRepositoryProvider.overrideWithValue(mockMeasurementRepo),
    ],
  );
  container.read(routinesRiverpodProvider.notifier).state = RoutinesState(
    routines: [getTestRoutine(exercises: getScreenshotExercises())],
  );

  return MediaQuery(
    data: MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.first).copyWith(
      padding: EdgeInsets.zero,
      viewPadding: EdgeInsets.zero,
      viewInsets: EdgeInsets.zero,
    ),
    child: riverpod.UncontrolledProviderScope(
      container: container,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<UserProvider>(
            create: (context) => mockUserProvider,
          ),

          ChangeNotifierProvider<GalleryProvider>(
            create: (context) => mockGalleryProvider,
          ),
          ChangeNotifierProvider<AuthProvider>(
            create: (context) => mockAuthProvider,
          ),

          ChangeNotifierProvider<NutritionPlansProvider>(
            create: (context) => mockNutritionProvider,
          ),
        ],
        child: MaterialApp(
          locale: locale,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: wgerLightTheme,
          home: HomeTabsScreen(),
        ),
      ),
    ),
  );
}
