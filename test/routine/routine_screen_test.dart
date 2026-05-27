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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/providers/network_provider.dart';
import 'package:wger/providers/routines_notifier.dart';
import 'package:wger/screens/routine_screen.dart';

import '../../test_data/routines.dart';

class _StubRoutinesRiverpod extends RoutinesRiverpod {
  _StubRoutinesRiverpod(this._routines);
  final List<Routine> _routines;

  @override
  Stream<RoutinesState> build() => Stream.value(RoutinesState(routines: _routines));
}

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
  });

  Widget renderWidget({locale = 'en', bool isOnline = true}) {
    final key = GlobalKey<NavigatorState>();

    final container = ProviderContainer.test(
      overrides: [
        networkStatusProvider.overrideWithValue(isOnline),
        routinesRiverpodProvider.overrideWith(
          () => _StubRoutinesRiverpod([getTestRoutine()]),
        ),
      ],
    );

    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        navigatorKey: key,
        home: TextButton(
          onPressed: () => key.currentState!.push(
            MaterialPageRoute<void>(
              settings: const RouteSettings(arguments: 1),
              builder: (_) => const RoutineScreen(),
            ),
          ),
          child: const SizedBox(),
        ),
        routes: {RoutineScreen.routeName: (ctx) => const RoutineScreen()},
      ),
    );
  }

  testWidgets(
    'Test the widgets on the routine screen',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(500, 1000);
      tester.view.devicePixelRatio = 1.0; // Ensure correct pixel ratio

      await tester.pumpWidget(renderWidget());
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      if (Platform.isLinux) {
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/routine_screen_detail.png'),
        );
      }

      expect(find.text('3 day workout'), findsOneWidget);

      expect(find.text('first day'), findsOneWidget);
      expect(find.text('chest, shoulders'), findsOneWidget);

      expect(find.text('second day'), findsOneWidget);
      expect(find.text('legs'), findsOneWidget);

      expect(find.byType(Card), findsWidgets);
      // expect(find.byType(Card), findsNWidgets(4));
    },
    tags: ['golden'],
  );

  testWidgets('App bar menu: delete works offline, edit needs online', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(500, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(renderWidget(isOnline: false));
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    // Open the routine detail app bar menu.
    await tester.tap(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byWidgetPredicate((w) => w is PopupMenuButton),
      ),
    );
    await tester.pumpAndSettle();

    // itemBuilder order: workout logs, edit, delete.
    final items = tester
        .widgetList(find.byWidgetPredicate((w) => w is PopupMenuItem))
        .cast<PopupMenuItem>()
        .toList();
    expect(items, hasLength(3));
    expect(
      items[1].enabled,
      isFalse,
      reason: 'Edit opens the structure editor (REST), needs connectivity',
    );
    expect(
      items[2].enabled,
      isTrue,
      reason: 'Delete syncs through PowerSync and works offline',
    );
  });
}
