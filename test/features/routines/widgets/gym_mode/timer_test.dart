/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 wger Team
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

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:wger/features/routines/providers/gym_state.dart';
import 'package:wger/features/routines/providers/gym_state_notifier.dart';
import 'package:wger/features/routines/widgets/gym_mode/timer.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

import '../../../../../test_data/routines.dart' as testdata;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Timer up-next', () {
    late ProviderContainer container;

    // Page structure of the test routine (exercise + timer pages enabled):
    //   start(0)
    //   slot 1 (bench press): overview(1), log(2), timer(3), log(4), timer(5), log(6), timer(7)
    //   slot 2 (side raises): overview(8), log(9), timer(10), log(11), timer(12), log(13), timer(14)
    //   session(15), summary(16)
    setUp(() {
      SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
      container = ProviderContainer.test();
      final notifier = container.read(gymStateProvider.notifier);
      final routine = testdata.getTestRoutine();
      notifier.initData(routine, routine.days.first.id!, 1);
    });

    Future<void> pumpTimer(WidgetTester tester, int timerPageIndex) async {
      final slotPage = container.read(gymStateProvider).getSlotEntryPageByIndex(timerPageIndex)!;
      expect(slotPage.type, SlotPageType.timer);

      // No pumpAndSettle: the widgets keep a periodic UI timer alive, which
      // would never settle.
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  final controller = PageController();
                  return PageView(
                    controller: controller,
                    children: [TimerCountdownWidget(controller, 90, slotPage.uuid)],
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('shows the next set of the same exercise for a rest between sets', (tester) async {
      await pumpTimer(tester, 3);

      expect(find.text('Up next'), findsOneWidget);
      expect(find.text('Bench press'), findsOneWidget);
      expect(find.text('3x100kg'), findsOneWidget);
      expect(find.text('2 / 3'), findsOneWidget);
    });

    testWidgets('shows the next exercise after the final rest of an exercise', (tester) async {
      await pumpTimer(tester, 7);

      expect(find.text('Up next'), findsOneWidget);
      expect(find.text('Side raises'), findsOneWidget);
      expect(find.text('12x10kg'), findsOneWidget);
      expect(find.text('1 / 3'), findsOneWidget);
    });

    testWidgets('shows nothing after the last set of the day', (tester) async {
      await pumpTimer(tester, 14);

      expect(find.text('Up next'), findsNothing);
    });

    testWidgets('countdown continues when the page is disposed and re-created', (tester) async {
      final t0 = DateTime(2024, 5, 2, 12);

      await withClock(Clock.fixed(t0), () async {
        await pumpTimer(tester, 3);
        expect(find.text('1:30'), findsOneWidget);
      });

      // 30s later the countdown kept running (re-pumping forces a rebuild,
      // in the app the periodic UI timer does this every second)
      await withClock(Clock.fixed(t0.add(const Duration(seconds: 30))), () async {
        await pumpTimer(tester, 3);
        expect(find.text('1:00'), findsOneWidget);
      });

      // Leaving the page disposes the widget ...
      await withClock(Clock.fixed(t0.add(const Duration(seconds: 45))), () async {
        await tester.pumpWidget(const SizedBox());
        await tester.pump();

        // ... and coming back must not restart the countdown
        await pumpTimer(tester, 3);
        expect(find.text('0:45'), findsOneWidget);
      });
    });
  });
}
