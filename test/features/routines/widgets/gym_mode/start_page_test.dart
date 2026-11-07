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

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:wger/features/routines/notifications/workout_notification_service.dart';
import 'package:wger/features/routines/providers/gym_state.dart';
import 'package:wger/features/routines/providers/gym_state_notifier.dart';
import 'package:wger/features/routines/widgets/gym_mode/start_page.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/l10n/localizations_delegates.dart';

import '../../../../../test_data/routines.dart';
import 'start_page_test.mocks.dart';

@GenerateMocks([WorkoutNotificationService])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late MockWorkoutNotificationService notificationService;

  setUp(() {
    // Use in-memory shared preferences to avoid platform channels during tests
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();

    notificationService = MockWorkoutNotificationService();
    when(notificationService.canScheduleExactAlarms()).thenAnswer((_) async => true);
    when(notificationService.requestExactAlarms()).thenAnswer((_) async {});

    container = ProviderContainer(
      overrides: [
        gymStateProvider.overrideWith(() => GymStateNotifier()),
        workoutNotificationServiceProvider.overrideWithValue(notificationService),
      ],
    );

    final routine = getTestRoutine();
    final notifier = container.read(gymStateProvider.notifier);
    notifier.state = GymModeState(
      showExercisePages: true,
      showTimerPages: true,
      useCountdownBetweenSets: true,
      countdownDuration: const Duration(seconds: DEFAULT_COUNTDOWN_DURATION),
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
          localizationsDelegates: appLocalizationsDelegates,
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

    // Toggle the rest end alert first (it is only enabled while timer pages are shown)
    final notifySwitch = find.byKey(const ValueKey('gym-mode-notify-countdown'));
    expect(notifySwitch, findsOneWidget);
    await tester.ensureVisible(notifySwitch);
    await tester.tap(notifySwitch);
    await tester.pump();

    final workoutNotificationSwitch = find.byKey(const ValueKey('gym-mode-workout-notification'));
    await tester.ensureVisible(workoutNotificationSwitch);
    await tester.tap(workoutNotificationSwitch);
    await tester.pump();

    // Now toggle show exercises
    final showExercisesSwitch = find.byKey(const ValueKey('gym-mode-option-show-exercises'));
    expect(showExercisesSwitch, findsOneWidget);
    await tester.ensureVisible(showExercisesSwitch);
    await tester.tap(showExercisesSwitch);
    await tester.pump();

    // Toggle show timer (this will disable notify switch)
    final showTimerSwitch = find.byKey(const ValueKey('gym-mode-option-show-timer'));
    expect(showTimerSwitch, findsOneWidget);
    await tester.ensureVisible(showTimerSwitch);
    await tester.tap(showTimerSwitch);
    await tester.pump();

    // Toggle show workout duration
    final durationSwitch = find.byKey(const ValueKey('gym-mode-option-show-workout-duration'));
    expect(durationSwitch, findsOneWidget);
    await tester.ensureVisible(durationSwitch);
    await tester.tap(durationSwitch);
    await tester.pump();

    // Toggle sticky set values
    final stickySwitch = find.byKey(const ValueKey('gym-mode-sticky-set-values'));
    expect(stickySwitch, findsOneWidget);
    await tester.ensureVisible(stickySwitch);
    await tester.tap(stickySwitch);
    await tester.pump();

    final notifier = container.read(gymStateProvider.notifier);
    expect(notifier.state.showExercisePages, isFalse);
    expect(notifier.state.showTimerPages, isFalse);
    expect(notifier.state.alertOnCountdownEnd, isFalse);
    expect(notifier.state.showWorkoutDuration, isFalse);
    expect(notifier.state.showWorkoutNotification, isFalse);
    expect(notifier.state.stickySetValues, isTrue);
  });

  testWidgets('The rest end alert works without the default countdown', (tester) async {
    // A set's own rest time is counted down regardless of the setting
    final notifier = container.read(gymStateProvider.notifier);
    notifier.setUseCountdownBetweenSets(false);
    await pumpGymModeOptions(tester);
    await tester.tap(find.byKey(const ValueKey('gym-mode-options-tile')));
    await tester.pumpAndSettle();

    final alertSwitch = find.byKey(const ValueKey('gym-mode-notify-countdown'));
    await tester.ensureVisible(alertSwitch);
    await tester.tap(alertSwitch);
    await tester.pump();

    expect(notifier.state.alertOnCountdownEnd, isFalse);
  });

  testWidgets('Switching a notification on asks for the permission, off does not', (tester) async {
    // Gym mode was opened with both off, so it did not ask then
    when(notificationService.requestPermissions(any)).thenAnswer((_) async {});
    final notifier = container.read(gymStateProvider.notifier);
    notifier.setAlertOnCountdownEnd(false);
    notifier.setShowWorkoutNotification(false);
    await pumpGymModeOptions(tester);
    await tester.tap(find.byKey(const ValueKey('gym-mode-options-tile')));
    await tester.pumpAndSettle();

    for (final key in ['gym-mode-notify-countdown', 'gym-mode-workout-notification']) {
      final toggle = find.byKey(ValueKey(key));
      await tester.ensureVisible(toggle);
      await tester.tap(toggle);
      await tester.pump();
    }
    verify(notificationService.requestPermissions(any)).called(2);

    for (final key in ['gym-mode-notify-countdown', 'gym-mode-workout-notification']) {
      final toggle = find.byKey(ValueKey(key));
      await tester.ensureVisible(toggle);
      await tester.tap(toggle);
      await tester.pump();
    }
    verifyNever(notificationService.requestPermissions(any));
    expect(notifier.state.alertOnCountdownEnd, isFalse);
    expect(notifier.state.showWorkoutNotification, isFalse);
  });

  testWidgets('The workout notification switch only shows on Android', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    await pumpGymModeOptions(tester);
    await tester.tap(find.byKey(const ValueKey('gym-mode-options-tile')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('gym-mode-notify-countdown')), findsOneWidget);
    expect(find.byKey(const ValueKey('gym-mode-workout-notification')), findsNothing);
    debugDefaultTargetPlatformOverride = null;
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
    await tester.pump();

    expect(notifier.state.countdownDuration.inSeconds, 60);

    // Tap refresh button (suffix icon). Find IconButton inside the input decoration
    final refreshIcon = find.descendant(of: countdownField, matching: find.byIcon(Icons.refresh));
    expect(refreshIcon, findsOneWidget);
    await tester.tap(refreshIcon);
    await tester.pump();

    expect(notifier.state.countdownDuration.inSeconds, DEFAULT_COUNTDOWN_DURATION);
  });

  testWidgets('Log history options update notifier state', (tester) async {
    await pumpGymModeOptions(tester);
    await tester.tap(find.byKey(const ValueKey('gym-mode-options-tile')));
    await tester.pumpAndSettle();

    final notifier = container.read(gymStateProvider.notifier);
    expect(notifier.state.logScopeWeeks, isNull, reason: 'Defaults to the current routine');
    expect(notifier.state.showDistinctLogs, isTrue);

    // The tiles sit at the bottom of the scrollable options card
    final scopeDropdown = find.byKey(const ValueKey('log-scope-dropdown'));
    await tester.ensureVisible(scopeDropdown);
    await tester.pumpAndSettle();

    // Limit the scope to the last 12 weeks
    await tester.tap(scopeDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Last 12 weeks').last);
    await tester.pumpAndSettle();

    expect(notifier.state.logScopeWeeks, 12);

    // And back to the current routine
    await tester.ensureVisible(scopeDropdown);
    await tester.pumpAndSettle();
    await tester.tap(scopeDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Current routine').last);
    await tester.pumpAndSettle();

    expect(notifier.state.logScopeWeeks, isNull);

    final distinctSwitch = find.byKey(const ValueKey('gym-mode-distinct-logs'));
    await tester.ensureVisible(distinctSwitch);
    await tester.pumpAndSettle();
    await tester.tap(distinctSwitch);
    await tester.pump();

    expect(notifier.state.showDistinctLogs, isFalse);
  });

  group('Exact alarm hint', () {
    Future<void> openOptions(WidgetTester tester) async {
      await pumpGymModeOptions(tester);
      await tester.tap(find.byKey(const ValueKey('gym-mode-options-tile')));
      await tester.pumpAndSettle();
    }

    final hint = find.byKey(const ValueKey('gym-mode-exact-alarm-hint'));

    testWidgets('Shown without the permission, the button asks for it', (tester) async {
      when(notificationService.canScheduleExactAlarms()).thenAnswer((_) async => false);
      await openOptions(tester);
      expect(hint, findsOneWidget);

      when(notificationService.canScheduleExactAlarms()).thenAnswer((_) async => true);
      await tester.ensureVisible(find.descendant(of: hint, matching: find.byType(TextButton)));
      await tester.tap(find.descendant(of: hint, matching: find.byType(TextButton)));
      await tester.pumpAndSettle();

      verify(notificationService.requestExactAlarms()).called(1);
      expect(hint, findsNothing, reason: 'rechecked after returning from the setting');
    });

    testWidgets('Rechecked when the app comes back from the system settings', (tester) async {
      when(notificationService.canScheduleExactAlarms()).thenAnswer((_) async => false);
      await openOptions(tester);
      expect(hint, findsOneWidget);

      // Granted outside the app, e.g. in the system settings
      when(notificationService.canScheduleExactAlarms()).thenAnswer((_) async => true);
      [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ].forEach(tester.binding.handleAppLifecycleStateChanged);
      await tester.pumpAndSettle();

      expect(hint, findsNothing);
    });

    testWidgets('Not shown with the permission or with the rest end alert off', (tester) async {
      await openOptions(tester);
      expect(hint, findsNothing);

      when(notificationService.canScheduleExactAlarms()).thenAnswer((_) async => false);
      container.invalidate(exactAlarmsAllowedProvider);
      container.read(gymStateProvider.notifier).setAlertOnCountdownEnd(false);
      await tester.pumpAndSettle();
      expect(hint, findsNothing);
    });
  });
  testWidgets('The opened options fit a short screen, e.g. with the keyboard up', (tester) async {
    tester.view.physicalSize = const Size(400, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: StartPage(PageController())),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('gym-mode-options-tile')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
