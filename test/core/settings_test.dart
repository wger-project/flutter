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
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/shared_preferences.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/base_provider.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/providers/user.dart';
import 'package:wger/widgets/core/settings.dart';

import 'settings_test.mocks.dart';

@GenerateMocks([
  ExercisesProvider,
  NutritionPlansProvider,
  UserProvider,
  WgerBaseProvider,
  SharedPreferencesAsync,
])
void main() async {  
  final mockExerciseProvider = MockExercisesProvider();
  final mockNutritionProvider = MockNutritionPlansProvider();
  final mockSharedPreferences = MockSharedPreferencesAsync();
  final mockUserProvider = MockUserProvider();

  setUp(() {
    when(mockUserProvider.themeMode).thenReturn(ThemeMode.system);
  });

  Widget createSettingsScreen({locale = 'en'}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<NutritionPlansProvider>(create: (context) => mockNutritionProvider),
        ChangeNotifierProvider<ExercisesProvider>(create: (context) => mockExerciseProvider),
        ChangeNotifierProvider<UserProvider>(create: (context) => mockUserProvider),
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

  group('Theme settings', () {
    test('Default theme is system', () async {
      when(mockSharedPreferences.getBool(PREFS_USER_DARK_THEME)).thenAnswer((_) async => null);
      final userProvider = await UserProvider(MockWgerBaseProvider(), prefs: mockSharedPreferences);
      expect(userProvider.themeMode, ThemeMode.system);
    });

    test('Loads light theme', () async {
      when(mockSharedPreferences.getBool(PREFS_USER_DARK_THEME)).thenAnswer((_) async => false);
      final userProvider = await UserProvider(MockWgerBaseProvider(), prefs: mockSharedPreferences);
      expect(userProvider.themeMode, ThemeMode.light);
    });

    test('Saves theme to prefs', () {
      when(mockSharedPreferences.getBool(any)).thenAnswer((_) async => null);
      final userProvider = UserProvider(MockWgerBaseProvider(), prefs: mockSharedPreferences);
      userProvider.setThemeMode(ThemeMode.dark);
      verify(mockSharedPreferences.setBool(PREFS_USER_DARK_THEME, true)).called(1);
      expect(userProvider.themeMode, ThemeMode.dark);
    });

    testWidgets('Test changing the theme mode in preferences', (WidgetTester tester) async {
      await tester.pumpWidget(createSettingsScreen());
      await tester.tap(find.byKey(const ValueKey('themeModeDropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Always light mode'));

      verify(mockUserProvider.setThemeMode(ThemeMode.light)).called(1);
    });
  });
}
