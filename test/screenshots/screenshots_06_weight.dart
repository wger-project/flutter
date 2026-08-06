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
import 'package:wger/core/form_screen.dart';
import 'package:wger/features/account/providers/user_profile_repository.dart';
import 'package:wger/features/measurements/providers/measurement_repository.dart';
import 'package:wger/features/measurements/screens/weight_screen.dart';
import 'package:wger/features/nutrition/providers/ingredient_repository.dart';
import 'package:wger/features/nutrition/providers/nutrition_notifier.dart';
import 'package:wger/features/nutrition/providers/nutrition_repository.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/theme/theme.dart';

import '../../test_data/body_weight.dart';
import '../../test_data/profile.dart';
import '../../test_data/screenshots/weight.dart';
import '../helpers/measurement_repository_stubs.dart';
import 'screenshots_06_weight.mocks.dart';

@GenerateMocks([
  MeasurementRepository,
  UserProfileRepository,
  NutritionRepository,
  IngredientRepository,
])
Widget createWeightScreen({Locale? locale}) {
  locale ??= const Locale('en');
  final mockMeasurementRepository = MockMeasurementRepository();
  stubMeasurementReads(
    mockMeasurementRepository,
    [getBodyWeightCategory()],
    getScreenshotBodyWeightEntries(),
  );

  final mockUserProfileRepository = MockUserProfileRepository();
  when(
    mockUserProfileRepository.watchDrift(),
  ).thenAnswer((_) => Stream.value(tUserProfile1));

  final mockNutritionRepo = MockNutritionRepository();
  final mockIngredientRepo = MockIngredientRepository();
  when(mockIngredientRepo.getById(any)).thenAnswer((_) async => null);

  final container = ProviderContainer(
    overrides: [
      measurementRepositoryProvider.overrideWithValue(mockMeasurementRepository),
      userProfileRepositoryProvider.overrideWithValue(mockUserProfileRepository),
      nutritionRepositoryProvider.overrideWithValue(mockNutritionRepo),
      ingredientRepositoryProvider.overrideWithValue(mockIngredientRepo),
    ],
  );
  // Seed the nutrition notifier with the plans behind the weight phases, so
  // the chart shows their periods as bands.
  container.read(nutritionProvider.notifier).state = AsyncData(
    NutritionState(plans: getScreenshotWeightPlans()),
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
        home: const WeightScreen(),
        routes: {FormScreen.routeName: (ctx) => const FormScreen()},
      ),
    ),
  );
}
