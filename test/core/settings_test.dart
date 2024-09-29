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

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/widgets/core/settings.dart';

import 'settings_test.mocks.dart';

@GenerateMocks([ExercisesProvider, NutritionPlansProvider])
void main() {
  final mockExerciseProvider = MockExercisesProvider();
  final mockNutritionProvider = MockNutritionPlansProvider();

  Widget createSettingsScreen({locale = 'en'}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<NutritionPlansProvider>(create: (context) => mockNutritionProvider),
        ChangeNotifierProvider<ExercisesProvider>(create: (context) => mockExerciseProvider),
      ],
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const SettingsPage(),
      ),
    );
  }

  group('Cache', () {
    testWidgets('Test resetting the exercise cache', (WidgetTester tester) async {
      await tester.pumpWidget(createSettingsScreen());
      await tester.tap(find.byKey(const ValueKey('cacheIconExercises')));
      await tester.pumpAndSettle();

      verify(mockExerciseProvider.clearAllCachesAndPrefs());
    });

    testWidgets('Test resetting the ingredient cache', (WidgetTester tester) async {
      await tester.pumpWidget(createSettingsScreen());
      await tester.tap(find.byKey(const ValueKey('cacheIconIngredients')));
      await tester.pumpAndSettle();

      verify(mockNutritionProvider.clearIngredientCache());
    });
  });
}
