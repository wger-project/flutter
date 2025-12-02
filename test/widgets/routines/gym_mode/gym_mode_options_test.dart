/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020, 2025 wger Team
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
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/gym_state.dart';
import 'package:wger/widgets/routines/gym_mode/start_page.dart';

import '../../../../test_data/routines.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    // Use in-memory shared preferences to avoid platform channels during tests
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();

    container = ProviderContainer(
      overrides: [
        gymStateProvider.overrideWith(() => GymStateNotifier()),
      ],
    );

    final routine = getTestRoutine();
    final notifier = container.read(gymStateProvider.notifier);
    notifier.state = GymModeState(
      showExercisePages: true,
      showTimerPages: true,
      useCountdownBetweenSets: true,
      defaultCountdownDuration: const Duration(seconds: DEFAULT_COUNTDOWN_DURATION),
      alertOnCountdownEnd: false,
      dayId: routine.days.first.id,
      iteration: 1,
      routine: routine,
    );

    notifier.calculatePages();
  });

  tearDown(() {
    container.dispose();
  });

  Future<void> pumpGymModeOptions(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: GymModeOptions(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Switches update the notifier state', (tester) async {
    await pumpGymModeOptions(tester);

    // Open options (tap the ListTile to toggle _showOptions)
    final optionsTile = find.byKey(const ValueKey('gym-mode-options-tile'));
    expect(optionsTile, findsOneWidget);
    await tester.tap(optionsTile);
    await tester.pumpAndSettle();

    // Toggle notify countdown first (it is only enabled while timer/countdown are active)
    final notifySwitch = find.byKey(const ValueKey('gym-mode-notify-countdown'));
    expect(notifySwitch, findsOneWidget);
    await tester.tap(notifySwitch);
    await tester.pumpAndSettle();

    // Now toggle show exercises
    final showExercisesSwitch = find.byKey(const ValueKey('gym-mode-option-show-exercises'));
    expect(showExercisesSwitch, findsOneWidget);
    await tester.tap(showExercisesSwitch);
    await tester.pumpAndSettle();

    // Toggle show timer (this will disable notify switch)
    final showTimerSwitch = find.byKey(const ValueKey('gym-mode-option-show-timer'));
    expect(showTimerSwitch, findsOneWidget);
    await tester.tap(showTimerSwitch);
    await tester.pumpAndSettle();

    final notifier = container.read(gymStateProvider.notifier);
    expect(notifier.state.showExercisePages, isFalse);
    expect(notifier.state.showTimerPages, isFalse);
    expect(notifier.state.alertOnCountdownEnd, isTrue);
  });

  testWidgets('Dropdown, text field and refresh button update notifier state', (tester) async {
    await pumpGymModeOptions(tester);

    // Open options
    final optionsTile = find.byKey(const ValueKey('gym-mode-options-tile'));
    await tester.tap(optionsTile);
    await tester.pumpAndSettle();

    final notifier = container.read(gymStateProvider.notifier);

    // Change dropdown (countdown type) -> switch to stopwatch (false)
    final dropdown = find.byKey(const ValueKey('countdown-type-dropdown'));
    expect(dropdown, findsOneWidget);

    await tester.tap(dropdown);
    await tester.pumpAndSettle();

    // Select the visible menu entry by its text label (English: 'Stopwatch') to avoid hit-test issues
    final stopwatchText = find.text('Stopwatch');
    expect(stopwatchText, findsWidgets);
    await tester.tap(stopwatchText.first);
    await tester.pumpAndSettle();

    expect(notifier.state.useCountdownBetweenSets, isFalse);

    // switch back to countdown (true)
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    final countdownText = find.text('Countdown');
    expect(countdownText, findsWidgets);
    await tester.tap(countdownText.first);
    await tester.pumpAndSettle();

    expect(notifier.state.useCountdownBetweenSets, isTrue);

    // Enter a new countdown duration in the TextFormField
    final countdownField = find.byKey(const ValueKey('gym-mode-default-countdown-time'));
    expect(countdownField, findsOneWidget);

    // The TextFormField is a descendant; find the editable TextField
    final textField = find.descendant(of: countdownField, matching: find.byType(TextFormField));
    expect(textField, findsOneWidget);

    await tester.enterText(textField, '60');
    await tester.pumpAndSettle();

    expect(notifier.state.defaultCountdownDuration.inSeconds, 60);

    // Tap refresh button (suffix icon). Find IconButton inside the input decoration
    final refreshIcon = find.descendant(of: countdownField, matching: find.byIcon(Icons.refresh));
    expect(refreshIcon, findsOneWidget);
    await tester.tap(refreshIcon);
    await tester.pumpAndSettle();

    expect(notifier.state.defaultCountdownDuration.inSeconds, DEFAULT_COUNTDOWN_DURATION);
  });
}
