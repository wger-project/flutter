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
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/core/home_tabs_screen.dart';
import 'package:wger/core/network/auth_notifier.dart';
import 'package:wger/core/network/auth_state.dart';
import 'package:wger/core/network/network_provider.dart';
import 'package:wger/features/account/providers/user_profile_repository.dart';
import 'package:wger/features/gallery/providers/gallery_repository.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/providers/measurement_repository.dart';
import 'package:wger/features/nutrition/providers/ingredient_repository.dart';
import 'package:wger/features/nutrition/providers/nutrition_notifier.dart';
import 'package:wger/features/nutrition/providers/nutrition_repository.dart';
import 'package:wger/features/routines/providers/routines_repository.dart';
import 'package:wger/features/trophies/providers/trophy_repository.dart';
import 'package:wger/features/weight/providers/body_weight_repository.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/theme/theme.dart';

import '../../test_data/body_weight.dart';
import '../../test_data/exercises.dart';
import '../../test_data/gallery.dart';
import '../../test_data/measurements.dart';
import '../../test_data/nutritional_plans.dart';
import '../../test_data/profile.dart';
import '../../test_data/routines.dart';
import '../../test_data/trophies.dart';
import 'screenshots_01_dashboard.mocks.dart';

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(this._state);

  final AuthState _state;

  @override
  Future<AuthState> build() async => _state;
}

@GenerateMocks([
  GalleryRepository,
  NutritionRepository,
  IngredientRepository,
  BodyWeightRepository,
  MeasurementRepository,
  UserProfileRepository,
  RoutinesRepository,
  TrophyRepository,
])
Widget createDashboardScreen({Locale? locale}) {
  locale ??= const Locale('en');

  final mockGalleryRepo = MockGalleryRepository();
  when(mockGalleryRepo.watchAllDrift()).thenAnswer((_) => Stream.value(getTestImages()));

  final mockNutritionRepo = MockNutritionRepository();
  final mockIngredientRepo = MockIngredientRepository();
  when(mockIngredientRepo.getById(any)).thenAnswer((_) async => null);

  final mockBodyWeightRepository = MockBodyWeightRepository();
  when(
    mockBodyWeightRepository.watchAllDrift(),
  ).thenAnswer((_) => Stream.value(getScreenshotWeightEntries()));

  final mockMeasurementRepo = MockMeasurementRepository();
  when(
    mockMeasurementRepo.watchAll(),
  ).thenAnswer((_) => Stream<List<MeasurementCategory>>.value(getMeasurementCategories()));

  final mockUserProfileRepo = MockUserProfileRepository();
  when(
    mockUserProfileRepo.watchDrift(),
  ).thenAnswer((_) => Stream.value(tUserProfile1));

  final mockRoutinesRepo = MockRoutinesRepository();
  when(
    mockRoutinesRepo.watchAllDrift(),
  ).thenAnswer((_) => Stream.value([getTestRoutine(exercises: getScreenshotExercises())]));

  final mockTrophyRepo = MockTrophyRepository();
  when(
    mockTrophyRepo.fetchUserTrophies(
      filterQuery: anyNamed('filterQuery'),
      language: anyNamed('language'),
    ),
  ).thenAnswer((_) async => getScreenshotUserTrophies());
  when(
    mockTrophyRepo.fetchTrophies(language: anyNamed('language')),
  ).thenAnswer((_) async => []);
  when(
    mockTrophyRepo.fetchProgression(
      filterQuery: anyNamed('filterQuery'),
      language: anyNamed('language'),
    ),
  ).thenAnswer((_) async => []);

  const loggedInAuth = AuthState(
    status: AuthStatus.loggedIn,
    credential: LegacyCredential('test-token'),
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
      // Present the app as online for the screenshots.
      networkStatusProvider.overrideWithValue(true),
      routinesRepositoryProvider.overrideWithValue(mockRoutinesRepo),
      trophyRepositoryProvider.overrideWithValue(mockTrophyRepo),
    ],
  );

  // Seed the nutrition notifier with the screenshot plan so the dashboard can
  // show it without going through the server.
  container.read(nutritionProvider.notifier).state = AsyncData(
    NutritionState(plans: [getNutritionalPlanScreenshot()]),
  );

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
        home: const HomeTabsScreen(),
      ),
    ),
  );
}
