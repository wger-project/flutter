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
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/app_settings_notifier.dart';
import 'package:wger/widgets/core/settings/dashboard_visibility.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
  });

  Widget createWidget({ProviderContainer? container}) {
    final scope = container == null
        ? ProviderScope(
            overrides: [
              appSettingsPrefsProvider.overrideWithValue(SharedPreferencesAsync()),
            ],
            child: _buildApp(),
          )
        : UncontrolledProviderScope(container: container, child: _buildApp());
    return scope;
  }

  testWidgets('renders list of dashboard widgets', (tester) async {
    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsNWidgets(DashboardWidget.values.length));
    expect(find.text('Routines'), findsOneWidget);
  });

  testWidgets('toggle visibility updates state', (tester) async {
    final container = ProviderContainer(
      overrides: [
        appSettingsPrefsProvider.overrideWithValue(SharedPreferencesAsync()),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(createWidget(container: container));
    await tester.pumpAndSettle();

    expect(
      container
          .read(appSettingsProvider)
          .value!
          .dashboardItems
          .isWidgetVisible(DashboardWidget.routines),
      true,
    );

    final routineTile = find.byKey(const ValueKey(DashboardWidget.routines));
    final iconBtn = find.descendant(of: routineTile, matching: find.byType(IconButton));
    expect(find.descendant(of: iconBtn, matching: find.byIcon(Icons.visibility)), findsOneWidget);

    await tester.tap(iconBtn);
    await tester.pumpAndSettle();

    expect(
      container
          .read(appSettingsProvider)
          .value!
          .dashboardItems
          .isWidgetVisible(DashboardWidget.routines),
      false,
    );
    expect(
      find.descendant(of: iconBtn, matching: find.byIcon(Icons.visibility_off)),
      findsOneWidget,
    );
  });

  testWidgets('dragging reorders items', (tester) async {
    final container = ProviderContainer(
      overrides: [
        appSettingsPrefsProvider.overrideWithValue(SharedPreferencesAsync()),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(createWidget(container: container));
    await tester.pumpAndSettle();

    final initial = container.read(appSettingsProvider).value!.dashboardItems.visibleWidgets;
    expect(initial[0], DashboardWidget.networkInfo);
    expect(initial[1], DashboardWidget.trophies);
    expect(initial[2], DashboardWidget.routines);
    expect(initial[3], DashboardWidget.nutrition);

    final handleFinder = find.byIcon(Icons.drag_handle);
    final firstHandle = handleFinder.at(0);

    await tester.drag(firstHandle, const Offset(0, 100));
    await tester.pumpAndSettle();

    final updated = container.read(appSettingsProvider).value!.dashboardItems.visibleWidgets;
    expect(updated[0], DashboardWidget.trophies);
    expect(updated[1], DashboardWidget.routines);
    expect(updated[2], DashboardWidget.networkInfo);
  });
}

Widget _buildApp() {
  return const MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: SettingsDashboardVisibility()),
  );
}
