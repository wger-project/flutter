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

import 'package:clock/clock.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:wger/features/routines/providers/gym_state.dart';
import 'package:wger/features/routines/providers/gym_state_notifier.dart';
import 'package:wger/features/routines/widgets/gym_mode/timer.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/l10n/localizations_delegates.dart';

import '../../../../../test_data/routines.dart';

void main() {
  final now = DateTime.utc(2025, 3, 29, 14, 33);
  late ProviderContainer container;
  late GymStateNotifier notifier;

  setUp(() {
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
    container = ProviderContainer.test();
    notifier = container.read(gymStateProvider.notifier);
    final routine = getTestRoutine();
    notifier.initData(routine, routine.days.first.id!, 1);
  });

  // In the fixture the first slot rests 120 s, the second has no rest time
  SlotPageEntry timerPage({required bool withRestTime}) => notifier.state.pages
      .expand((p) => p.slotPages)
      .firstWhere(
        (p) => p.type == SlotPageType.timer && (p.setConfigData!.restTime != null) == withRestTime,
      );

  Future<void> pumpTimer(WidgetTester tester, Widget timer) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final controller = PageController();
                return PageView(controller: controller, children: [timer]);
              },
            ),
          ),
        ),
      ),
    );
  }

  group('TimerCountdownWidget', () {
    testWidgets('counts down to the rest end of the gym state', (tester) async {
      final page = timerPage(withRestTime: true);
      notifier.state = notifier.state.copyWith(
        currentPage: page.pageIndex,
        restStartedAt: now.subtract(const Duration(seconds: 75)),
        restEndsAt: now.add(const Duration(seconds: 45)),
      );

      await withClock(Clock.fixed(now), () async {
        await pumpTimer(tester, TimerCountdownWidget(PageController(), page.uuid));
      });

      expect(find.text('0:45'), findsOneWidget);
    });

    testWidgets('a timer page that is not current shows its full rest', (tester) async {
      // The rest end in the state belongs to the current page only
      final page = timerPage(withRestTime: true);
      notifier.state = notifier.state.copyWith(
        currentPage: page.pageIndex + 1,
        restEndsAt: now.add(const Duration(seconds: 45)),
      );

      await withClock(Clock.fixed(now), () async {
        await pumpTimer(tester, TimerCountdownWidget(PageController(), page.uuid));
      });

      expect(find.text('2:00'), findsOneWidget);
    });

    testWidgets('alerts once when the rest is over', (tester) async {
      final calls = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          calls.add(call.method);
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      final page = timerPage(withRestTime: true);
      notifier.state = notifier.state.copyWith(currentPage: page.pageIndex, restEndsAt: now);

      await withClock(Clock.fixed(now), () async {
        await pumpTimer(tester, TimerCountdownWidget(PageController(), page.uuid));
        // The widget repaints every second and keeps seeing the end
        await tester.pump(const Duration(seconds: 3));
      });

      expect(calls.where((m) => m == 'HapticFeedback.vibrate'), hasLength(1));
    });
  });

  group('TimerWidget', () {
    testWidgets('counts up from the rest start of the gym state', (tester) async {
      final page = timerPage(withRestTime: false);
      notifier.state = notifier.state.copyWith(
        currentPage: page.pageIndex,
        restStartedAt: now.subtract(const Duration(seconds: 30)),
      );

      await withClock(Clock.fixed(now), () async {
        await pumpTimer(tester, TimerWidget(PageController(), page.uuid));
      });

      expect(find.text('0:30'), findsOneWidget);
    });
  });
}
