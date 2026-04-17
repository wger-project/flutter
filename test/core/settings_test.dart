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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/app_settings_notifier.dart';
import 'package:wger/widgets/core/settings.dart';

import 'settings_test.mocks.dart';

@GenerateMocks([
  SharedPreferencesAsync,
])
void main() {
  final mockSharedPreferences = MockSharedPreferencesAsync();

  setUp(() {
    when(mockSharedPreferences.getBool(any)).thenAnswer((_) async => null);
    when(mockSharedPreferences.getString(any)).thenAnswer((_) async => null);
    when(
      mockSharedPreferences.setBool(any, any),
    ).thenAnswer((_) async {});
    when(
      mockSharedPreferences.remove(any),
    ).thenAnswer((_) async {});
  });

  Widget createSettingsScreen({locale = 'en'}) {
    return riverpod.ProviderScope(
      overrides: [
        appSettingsPrefsProvider.overrideWithValue(mockSharedPreferences),
      ],
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const SettingsPage(),
      ),
    );
  }

  group('Theme settings (AppSettingsNotifier)', () {
    test('default theme is system', () async {
      when(
        mockSharedPreferences.getBool(PREFS_USER_DARK_THEME),
      ).thenAnswer((_) async => null);
      final container = riverpod.ProviderContainer(
        overrides: [
          appSettingsPrefsProvider.overrideWithValue(mockSharedPreferences),
        ],
      );
      addTearDown(container.dispose);

      final settings = await container.read(appSettingsProvider.future);
      expect(settings.themeMode, ThemeMode.system);
    });

    test('loads light theme from prefs', () async {
      when(
        mockSharedPreferences.getBool(PREFS_USER_DARK_THEME),
      ).thenAnswer((_) async => false);
      final container = riverpod.ProviderContainer(
        overrides: [
          appSettingsPrefsProvider.overrideWithValue(mockSharedPreferences),
        ],
      );
      addTearDown(container.dispose);

      final settings = await container.read(appSettingsProvider.future);
      expect(settings.themeMode, ThemeMode.light);
    });

    test('saves theme to prefs', () async {
      when(
        mockSharedPreferences.getBool(PREFS_USER_DARK_THEME),
      ).thenAnswer((_) async => null);
      final container = riverpod.ProviderContainer(
        overrides: [
          appSettingsPrefsProvider.overrideWithValue(mockSharedPreferences),
        ],
      );
      addTearDown(container.dispose);

      await container.read(appSettingsProvider.future);
      await container.read(appSettingsProvider.notifier).setThemeMode(ThemeMode.dark);

      expect(container.read(appSettingsProvider).value!.themeMode, ThemeMode.dark);
      verify(mockSharedPreferences.setBool(PREFS_USER_DARK_THEME, true)).called(1);
    });

    testWidgets('Test changing the theme mode in preferences', (WidgetTester tester) async {
      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('themeModeDropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Always light mode'));
      await tester.pumpAndSettle();

      verify(mockSharedPreferences.setBool(PREFS_USER_DARK_THEME, false)).called(1);
    });
  });
}
