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
import 'package:wger/core/app_settings_notifier.dart';
import 'package:wger/core/consts.dart';
import 'package:wger/features/account/widgets/settings.dart';
import 'package:wger/features/health/providers/health_repository.dart';
import 'package:wger/features/health/providers/health_sync.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/theme/dynamic_color.dart';

import 'settings_test.mocks.dart';

/// Keeps the health sync tile inert (reports the platform as unavailable) so
/// the settings page renders without booting the real health/preferences stack.
class _FakeHealthSyncNotifier extends HealthSyncNotifier {
  @override
  HealthSyncState build() => const HealthSyncState();

  @override
  Future<HealthPlatformAvailability> availability() async => HealthPlatformAvailability.unsupported;
}

@GenerateMocks([
  SharedPreferencesAsync,
])
void main() {
  final mockSharedPreferences = MockSharedPreferencesAsync();

  setUp(() {
    when(mockSharedPreferences.getBool(any)).thenAnswer((_) async => null);
    when(mockSharedPreferences.getString(any)).thenAnswer((_) async => null);
    when(
      mockSharedPreferences.getAll(allowList: anyNamed('allowList')),
    ).thenAnswer((_) async => {});
    when(
      mockSharedPreferences.setBool(any, any),
    ).thenAnswer((_) async {});
    when(
      mockSharedPreferences.setString(any, any),
    ).thenAnswer((_) async {});
    when(
      mockSharedPreferences.remove(any),
    ).thenAnswer((_) async {});
  });

  Widget createSettingsScreen({locale = 'en', bool dynamicColorAvailable = true}) {
    return riverpod.ProviderScope(
      overrides: [
        appSettingsPrefsProvider.overrideWithValue(mockSharedPreferences),
        healthSyncProvider.overrideWith(_FakeHealthSyncNotifier.new),
        // The plugin has no test implementation and would report the toggle as
        // unsupported, which hides it.
        dynamicColorAvailableProvider.overrideWith((ref) async => dynamicColorAvailable),
      ],
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const SettingsPage(),
      ),
    );
  }

  group('Theme settings', () {
    testWidgets('Test changing the theme mode in preferences', (WidgetTester tester) async {
      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('themeModeDropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Always light mode'));
      await tester.pumpAndSettle();

      verify(mockSharedPreferences.setBool(PREFS_USER_DARK_THEME, false)).called(1);
    });

    testWidgets('toggling dynamic color persists the preference', (WidgetTester tester) async {
      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('useDynamicColorSwitch')));
      await tester.pumpAndSettle();

      verify(mockSharedPreferences.setBool(PREFS_USE_DYNAMIC_COLOR, true)).called(1);
    });

    testWidgets('dynamic color switch reflects a stored preference', (WidgetTester tester) async {
      when(
        mockSharedPreferences.getAll(allowList: anyNamed('allowList')),
      ).thenAnswer((_) async => {PREFS_USE_DYNAMIC_COLOR: true});

      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      final switchWidget = tester.widget<SwitchListTile>(
        find.byKey(const ValueKey('useDynamicColorSwitch')),
      );
      expect(switchWidget.value, true);
    });

    testWidgets('dynamic color switch is hidden where the platform has none', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createSettingsScreen(dynamicColorAvailable: false));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('useDynamicColorSwitch')), findsNothing);
      expect(find.byKey(const ValueKey('themeModeDropdown')), findsOneWidget);
    });
  });

  group('Language switcher', () {
    testWidgets('shows system option when no override set', (WidgetTester tester) async {
      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      // The dropdown is built; tap to open it.
      final dropdown = find.byKey(const ValueKey('appLanguageDropdown'));
      expect(dropdown, findsOneWidget);

      await tester.ensureVisible(dropdown);
      await tester.pumpAndSettle();
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      // "System language" option exists in the open menu.
      expect(find.text('System default'), findsWidgets);
    });

    testWidgets('selecting a language persists the override', (WidgetTester tester) async {
      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      final dropdown = find.byKey(const ValueKey('appLanguageDropdown'));
      await tester.ensureVisible(dropdown);
      await tester.pumpAndSettle();
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      // German is rendered in its native name ("Deutsch") in the menu.
      await tester.tap(find.text('Deutsch').last);
      await tester.pumpAndSettle();

      verify(mockSharedPreferences.setString(PREFS_USER_LOCALE, 'de')).called(1);
    });

    testWidgets('selecting "System language" clears the override', (WidgetTester tester) async {
      // Start with a stored override so the dropdown opens on German.
      when(
        mockSharedPreferences.getString(PREFS_USER_LOCALE),
      ).thenAnswer((_) async => 'de');

      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      final dropdown = find.byKey(const ValueKey('appLanguageDropdown'));
      await tester.ensureVisible(dropdown);
      await tester.pumpAndSettle();
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      await tester.tap(find.text('System default').last);
      await tester.pumpAndSettle();

      verify(mockSharedPreferences.remove(PREFS_USER_LOCALE)).called(1);
    });

    testWidgets('renders supported locales in native script', (WidgetTester tester) async {
      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      final dropdown = find.byKey(const ValueKey('appLanguageDropdown'));
      await tester.ensureVisible(dropdown);
      await tester.pumpAndSettle();
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      // Spot-check native names that sort near the top of the menu and are
      // therefore visible without scrolling the (large) dropdown overlay.
      expect(find.text('Deutsch'), findsWidgets);
      expect(find.text('English'), findsWidgets);
      expect(find.text('Català'), findsWidgets);
    });
  });
}
