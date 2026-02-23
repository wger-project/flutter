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
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/base_provider.dart';
import 'package:wger/providers/user.dart';
import 'package:wger/widgets/core/settings/dashboard_visibility.dart';

import 'settings_dashboard_visibility_test.mocks.dart';

@GenerateMocks([WgerBaseProvider])
void main() {
  late UserProvider userProvider;
  late MockWgerBaseProvider mockBaseProvider;

  setUp(() {
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
    mockBaseProvider = MockWgerBaseProvider();
    userProvider = UserProvider(mockBaseProvider, prefs: SharedPreferencesAsync());
  });

  Widget createWidget() {
    return ChangeNotifierProvider<UserProvider>.value(
      value: userProvider,
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SettingsDashboardVisibility(),
        ),
      ),
    );
  }

  testWidgets('renders list of dashboard widgets', (tester) async {
    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    // Verify all items are present
    expect(find.byType(ListTile), findsNWidgets(DashboardWidget.values.length));
    expect(find.text('Routines'), findsOneWidget);
  });

  testWidgets('toggle visibility updates provider', (tester) async {
    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    // Routines should be visible initally (default is true)
    expect(userProvider.isDashboardWidgetVisible(DashboardWidget.routines), true);

    // Find the visibility icon for Routines
    final routineTile = find.byKey(const ValueKey(DashboardWidget.routines));
    final iconBtn = find.descendant(of: routineTile, matching: find.byType(IconButton));

    // Check icon is 'visibility'
    expect(find.descendant(of: iconBtn, matching: find.byIcon(Icons.visibility)), findsOneWidget);

    // Tap to toggle
    await tester.tap(iconBtn);
    await tester.pump();

    // Check provider state
    expect(userProvider.isDashboardWidgetVisible(DashboardWidget.routines), false);

    // Check icon is 'visibility_off'
    expect(
      find.descendant(of: iconBtn, matching: find.byIcon(Icons.visibility_off)),
      findsOneWidget,
    );
  });

  // Reordering test is a bit flaky without full drag setup, but we can try
  testWidgets('dragging reorders items', (tester) async {
    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    // Initial order: trophies, routines, nutrition, weight...
    expect(userProvider.dashboardWidgets[0], DashboardWidget.trophies);
    expect(userProvider.dashboardWidgets[1], DashboardWidget.routines);
    expect(userProvider.dashboardWidgets[2], DashboardWidget.nutrition);

    // Find drag handle for Trophies (index 0)
    final handleFinder = find.byIcon(Icons.drag_handle);
    final firstHandle = handleFinder.at(0);

    // Drag first item down
    await tester.drag(firstHandle, const Offset(0, 100)); // Drag down enough to swap
    await tester.pumpAndSettle();

    // Verify order changed
    // 100px drag seems to skip 2 items (trophies moves to index 2)
    // [routines, nutrition, trophies, ...]
    expect(userProvider.dashboardWidgets[0], DashboardWidget.routines);
    expect(userProvider.dashboardWidgets[1], DashboardWidget.nutrition);
    expect(userProvider.dashboardWidgets[2], DashboardWidget.trophies);
  });
}
