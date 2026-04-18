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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/measurements/measurement_category.dart';
import 'package:wger/providers/auth_notifier.dart';
import 'package:wger/providers/auth_state.dart';
import 'package:wger/providers/body_weight_repository.dart';
import 'package:wger/providers/gallery_repository.dart';
import 'package:wger/providers/ingredient_repository.dart';
import 'package:wger/providers/measurement_repository.dart';
import 'package:wger/providers/nutrition_notifier.dart';
import 'package:wger/providers/nutrition_repository.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/providers/user_profile_repository.dart';
import 'package:wger/screens/home_tabs_screen.dart';
import 'package:wger/theme/theme.dart';

import '../test/gallery/gallery_form_test.mocks.dart';
import '../test/measurements/measurement_categories_screen_test.mocks.dart';
import '../test/nutrition/nutritional_plan_screen_test.mocks.dart';
import '../test/weight/weight_screen_test.mocks.dart' as weight;
import '../test_data/body_weight.dart';
import '../test_data/exercises.dart';
import '../test_data/gallery.dart';
import '../test_data/measurements.dart';
import '../test_data/nutritional_plans.dart';
import '../test_data/profile.dart';
import '../test_data/routines.dart';

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(this._state);

  final AuthState _state;

  @override
  Future<AuthState> build() async => _state;
}

Widget createDashboardScreen({Locale? locale}) {
  locale ??= const Locale('en');

  final mockGalleryRepo = MockGalleryRepository();
  when(mockGalleryRepo.fetchAll()).thenAnswer((_) async => getTestImages());

  final mockNutritionRepo = weight.MockNutritionRepository();
  final mockIngredientRepo = weight.MockIngredientRepository();
  when(mockIngredientRepo.getById(any)).thenAnswer((_) async => null);

  final mockBodyWeightRepository = MockBodyWeightRepository();
  when(
    mockBodyWeightRepository.watchAllDrift(),
  ).thenAnswer((_) => Stream.value(getWeightEntries()));

  final mockMeasurementRepo = MockMeasurementRepository();
  when(
    mockMeasurementRepo.watchAll(),
  ).thenAnswer((_) => Stream<List<MeasurementCategory>>.value(getMeasurementCategories()));

  final mockUserProfileRepo = weight.MockUserProfileRepository();
  when(mockUserProfileRepo.fetchProfile()).thenAnswer((_) async => tProfile1);

  final loggedInAuth = const AuthState(
    status: AuthStatus.loggedIn,
    token: 'test-token',
    serverUrl: 'http://localhost',
  );
  final container = ProviderContainer.test(
    overrides: [
      bodyWeightRepositoryProvider.overrideWithValue(mockBodyWeightRepository),
      measurementRepositoryProvider.overrideWithValue(mockMeasurementRepo),
      authProvider.overrideWith(() => _FakeAuthNotifier(loggedInAuth)),
      userProfileRepositoryProvider.overrideWithValue(mockUserProfileRepo),
      nutritionRepositoryProvider.overrideWithValue(mockNutritionRepo),
      ingredientRepositoryProvider.overrideWithValue(mockIngredientRepo),
      galleryRepositoryProvider.overrideWithValue(mockGalleryRepo),
    ],
  );
  container.read(routinesRiverpodProvider.notifier).state = AsyncData(
    RoutinesState(
      routines: [getTestRoutine(exercises: getScreenshotExercises())],
    ),
  );

  // Seed the nutrition notifier with the screenshot plan so the dashboard can
  // show it without going through the server.
  container.read(nutritionProvider.notifier).state = AsyncData([
    getNutritionalPlanScreenshot(),
  ]);

  return MediaQuery(
    data: MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.first).copyWith(
      padding: EdgeInsets.zero,
      viewPadding: EdgeInsets.zero,
      viewInsets: EdgeInsets.zero,
    ),
    child: UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: locale,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: wgerLightTheme,
        home: HomeTabsScreen(),
      ),
    ),
  );
}
