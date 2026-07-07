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

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:wger/helpers/shared_preferences.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/log.dart';
import 'package:wger/models/workouts/repetition_unit.dart';
import 'package:wger/models/workouts/session.dart';
import 'package:wger/models/workouts/weight_unit.dart';
import 'package:wger/providers/exercise_repository.dart';
import 'package:wger/providers/exercises_notifier.dart';
import 'package:wger/providers/gym_state.dart';
import 'package:wger/providers/gym_state_notifier.dart';
import 'package:wger/providers/network_provider.dart';
import 'package:wger/providers/rest_timer_notifier.dart';
import 'package:wger/providers/routines_notifier.dart';
import 'package:wger/providers/routines_repository.dart';
import 'package:wger/providers/workout_logs_notifier.dart';
import 'package:wger/providers/workout_session_repository.dart';
import 'package:wger/screens/gym_mode.dart';
import 'package:wger/screens/routine_screen.dart';
import 'package:wger/theme/theme.dart';
import 'package:wger/widgets/core/error.dart';
import 'package:wger/widgets/routines/gym_mode/exercise_overview.dart';
import 'package:wger/widgets/routines/gym_mode/log_page.dart';
import 'package:wger/widgets/routines/gym_mode/session_page.dart';
import 'package:wger/widgets/routines/gym_mode/start_page.dart';

import '../../../test_data/exercises.dart';
import '../../../test_data/routines.dart';
import '../../fake_connectivity.dart';
import 'gym_mode_test.mocks.dart';

/// Captures logged sets instead of writing them to the local drift database.
class _FakeLogMutations implements WorkoutLogMutations {
  final List<Log> added = [];

  @override
  Future<void> addEntry(Log log) async => added.add(log);

  @override
  Future<void> updateEntry(Log log) async {}

  @override
  Future<void> deleteEntry(String id) async {}
}

@GenerateMocks([WorkoutSessionRepository, ExerciseRepository, RoutinesRepository])
void main() {
  installFakeConnectivity();

  final fakeLogs = _FakeLogMutations();

  final key = GlobalKey<NavigatorState>();

  final testRoutine = getTestRoutine();
  final testExercises = getTestExercises();

  final mockSessionRepo = MockWorkoutSessionRepository();
  final mockExerciseRepo = MockExerciseRepository();
  final mockRoutinesRepo = MockRoutinesRepository();

  setUp(() {
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
    when(mockSessionRepo.watchAllDrift()).thenAnswer(
      (_) => Stream<List<WorkoutSession>>.multi((controller) {
        controller.add(testRoutine.sessions);
      }),
    );
    when(
      mockExerciseRepo.watchAllDrift(),
    ).thenAnswer((_) => Stream.value(ExerciseState(testExercises)));

    // Drift the test routine in via the routines repository, the real
    // [RoutinesRiverpod] picks it up and exposes it through state.
    when(
      mockRoutinesRepo.watchAllDrift(),
    ).thenAnswer((_) => Stream.value([testRoutine]));
    // [fetchAndSetRoutineFull] (called by [GymMode._loadGymState] before the
    // page tree is built) goes back to the server in production; here we
    // just hand back the same test routine.
    when(
      mockRoutinesRepo.fetchAndSetRoutineFullServer(any),
    ).thenAnswer((_) async => testRoutine);
  });

  Widget renderGymMode({locale = 'en', bool isOnline = true}) {
    return riverpod.ProviderScope(
      overrides: [
        networkStatusProvider.overrideWithValue(isOnline),
        workoutLogProvider.overrideWithValue(fakeLogs),
        routinesRepositoryProvider.overrideWithValue(mockRoutinesRepo),
        exerciseRepositoryProvider.overrideWithValue(mockExerciseRepo),
        workoutSessionRepositoryProvider.overrideWithValue(mockSessionRepo),
        // The repetition + weight unit catalogues are tiny direct-Drift
        // stream providers, overriding them inline is the established
        // pattern (see also [exerciseCategoriesProvider] etc.).
        routineRepetitionUnitProvider.overrideWith(
          (ref) => Stream<List<RepetitionUnit>>.value(testRepetitionUnits),
        ),
        routineWeightUnitProvider.overrideWith(
          (ref) => Stream<List<WeightUnit>>.value(testWeightUnits),
        ),
      ],
      child: MaterialApp(
        locale: Locale(locale),
        theme: wgerLightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        navigatorKey: key,
        home: TextButton(
          onPressed: () => key.currentState!.push(
            MaterialPageRoute<void>(
              settings: const RouteSettings(arguments: GymModeArguments(1, 1, 1)),
              builder: (_) => const GymModeScreen(),
            ),
          ),
          child: const SizedBox(),
        ),
        routes: {RoutineScreen.routeName: (ctx) => const RoutineScreen()},
      ),
    );
  }

  testWidgets(
    'swipe journey: start -> log page -> jump via queue -> finish',
    (WidgetTester tester) async {
      // The redesigned gym mode is a swipe PageView (start, one log page per
      // exercise, session, summary) with persistent chrome (header + exercise
      // queue) on the log pages. Navigation is swipe + queue chips + Finish,
      // not the old per-set/per-timer chevron pages.
      await tester.pumpWidget(renderGymMode());
      await tester.pumpAndSettle();
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      // Start page lists the day's exercises.
      expect(find.byType(StartPage), findsOneWidget);
      expect(find.text('Bench press'), findsWidgets);
      expect(find.text('Side raises'), findsWidgets);

      // Swipe off the start page; the first swipe lands on the first exercise's
      // log page (FR3: the exercise name is shown).
      await tester.drag(find.byType(StartPage), const Offset(-500.0, 0.0));
      await tester.pumpAndSettle();

      expect(find.byType(LogPage), findsOneWidget);
      expect(find.text('Bench press'), findsWidgets);

      // FR11: the total-workout-time chrome is visible and does not block
      // navigation. The rest timer badge stays hidden until the first set is
      // logged (it tracks rest *between* sets, so there is nothing to show yet).
      expect(find.byKey(const ValueKey('gym-total-time')), findsOneWidget);
      expect(find.byKey(const ValueKey('gym-rest-timer')), findsNothing);

      // The exercise (set) pages, used to target queue chips by uuid.
      final container = riverpod.ProviderScope.containerOf(
        tester.element(find.byType(LogPage)),
      );
      final setPages = container
          .read(gymStateProvider)
          .pages
          .where((p) => p.type == PageType.set)
          .toList();
      expect(setPages.length, greaterThanOrEqualTo(2));

      // FR10: jump straight to the second exercise via its queue chip.
      await tester.tap(find.byKey(ValueKey('gym-queue-chip-${setPages[1].uuid}')));
      await tester.pumpAndSettle();
      expect(find.text('Side raises'), findsWidgets);

      // FR12: the Finish button jumps to the session page.
      await tester.tap(find.byKey(const ValueKey('gym-finish-button')));
      await tester.pumpAndSettle();
      expect(find.byType(SessionPage), findsOneWidget);
    },
    semanticsEnabled: false,
  );

  testWidgets(
    'jumping back to a finished exercise still shows its comment/data, and an '
    'added set keeps it',
    (WidgetTester tester) async {
      // Repro for the "hydration" bug: finish the last set of an exercise (which
      // auto-advances to the next page and disposes this log page), then jump
      // back to it. The exercise comment/target must still render, and adding a
      // set must not blank them out.
      await tester.pumpWidget(renderGymMode());
      await tester.pumpAndSettle();
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      // Swipe onto the first exercise (Bench press).
      await tester.drag(find.byType(StartPage), const Offset(-500.0, 0.0));
      await tester.pumpAndSettle();
      expect(find.text('Bench press'), findsWidgets);

      final container = riverpod.ProviderScope.containerOf(
        tester.element(find.byType(LogPage)),
      );

      // The test routine ships empty comments; give the first exercise's sets a
      // comment so we can assert the hero note survives.
      final setPages = container
          .read(gymStateProvider)
          .pages
          .where((p) => p.type == PageType.set)
          .toList();
      for (final sp in setPages.first.slotPages) {
        sp.setConfigData?.comment = 'Keep your back straight';
      }

      // Finish every set of Bench press. Logging the last one auto-advances to
      // the next exercise, disposing the Bench press log page.
      final benchUuid = setPages.first.uuid;
      final logCount = container
          .read(gymStateProvider)
          .pages
          .firstWhere((p) => p.uuid == benchUuid)
          .slotPages
          .where((sp) => sp.type == SlotPageType.log)
          .length;
      for (var i = 0; i < logCount; i++) {
        await tester.tap(find.byKey(const ValueKey('gym-log-set-button')));
        await tester.pump();
        // Logging rebuilds the hero; the comment we set above is now rendered.
        // (Asserting here proves the comment is genuinely shown before the jump,
        // so a later miss is the bug and not a test artifact.)
        if (i == 0) {
          expect(find.text('Keep your back straight'), findsOneWidget);
        }
        // Logging starts the periodic rest timer; stop it so pumpAndSettle does
        // not spin on it.
        container.read(restTimerProvider.notifier).cancel();
        await tester.pumpAndSettle();
      }

      // Move two pages away (onto the session page) so the PageView actually
      // disposes the Bench press log page, then come back: this is the round
      // trip that used to drop the exercise's data.
      await tester.tap(find.byKey(const ValueKey('gym-finish-button')));
      await tester.pumpAndSettle();
      expect(find.byType(SessionPage), findsOneWidget);

      // Swipe back to the finished Bench press, which is rebuilt from scratch.
      await tester.drag(find.byType(SessionPage), const Offset(500.0, 0.0), warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ValueKey('gym-queue-chip-$benchUuid')));
      await tester.pumpAndSettle();

      // The comment and exercise name must still be there after the round trip.
      expect(find.text('Bench press'), findsWidgets);
      expect(find.text('Keep your back straight'), findsOneWidget);

      // Add another set; the comment/data must persist.
      await tester.tap(find.byKey(const ValueKey('gym-add-set-button')));
      await tester.pumpAndSettle();
      expect(find.text('Bench press'), findsWidgets);
      expect(find.text('Keep your back straight'), findsOneWidget);

      container.read(restTimerProvider.notifier).cancel();
    },
    semanticsEnabled: false,
  );

  testWidgets('loads offline from the cached routine', (WidgetTester tester) async {
    // Offline, gym mode uses the already-downloaded (hydrated) routine.
    when(mockRoutinesRepo.watchAllDrift()).thenAnswer(
      (_) => Stream.value([testRoutine]),
    );

    await withClock(Clock.fixed(DateTime(2025, 3, 29, 14, 33)), () async {
      await tester.pumpWidget(renderGymMode(isOnline: false));
      await tester.pumpAndSettle();

      // Gym mode is always reached from a screen that has already populated
      // data, build and settle it here too. A keepAlive stream notifier needs
      // an explicit listener to emit its first value, a bare read leaves it
      // stuck in loading.
      final container = riverpod.ProviderScope.containerOf(
        tester.element(find.byType(TextButton)),
      );
      container.listen(routinesRiverpodProvider, (_, _) {});
      await tester.pumpAndSettle();

      // The mock is shared across tests; only the gym-mode open below must
      // stay clear of server calls.
      clearInteractions(mockRoutinesRepo);

      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      expect(find.byType(StreamErrorIndicator), findsNothing);
      expect(find.byType(StartPage), findsOneWidget);
      verifyNever(mockRoutinesRepo.fetchAndSetRoutineFullServer(any));
    });
  });

  testWidgets(
    'fresh session with exercise pages off: first swipe to a log page does not crash',
    (WidgetTester tester) async {
      // Test having a null page, which can happen on the first swipe of a fresh session
      await PreferenceHelper.asyncPref.setBool(PREFS_SHOW_EXERCISES, false);

      await withClock(Clock.fixed(DateTime(2025, 3, 29, 14, 33)), () async {
        await tester.pumpWidget(renderGymMode());
        await tester.pumpAndSettle();
        await tester.tap(find.byType(TextButton));
        await tester.pumpAndSettle();

        expect(find.byType(StartPage), findsOneWidget);
        expect(find.byType(ExerciseOverview), findsNothing);

        // First swipe off the start page lands directly on a log page.
        await tester.drag(find.byType(StartPage), const Offset(-500.0, 0.0));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(LogPage), findsOneWidget);
        // The exercise name now appears in both the queue chip and the hero.
        expect(find.text('Bench press'), findsWidgets);
      });
    },
    semanticsEnabled: false,
  );
}
