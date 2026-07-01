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
import 'package:flutter_riverpod/misc.dart' as riverpod;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:wger/features/exercises/providers/exercise_repository.dart';
import 'package:wger/features/exercises/providers/exercises_notifier.dart';
import 'package:wger/features/routines/models/repetition_unit.dart';
import 'package:wger/features/routines/models/session.dart';
import 'package:wger/features/routines/models/weight_unit.dart';
import 'package:wger/features/routines/providers/gym_state.dart';
import 'package:wger/features/routines/providers/routines_notifier.dart';
import 'package:wger/features/routines/providers/routines_repository.dart';
import 'package:wger/features/routines/providers/workout_logs_repository.dart';
import 'package:wger/features/routines/providers/workout_session_repository.dart';
import 'package:wger/features/routines/screens/gym_mode.dart';
import 'package:wger/features/routines/screens/routine_screen.dart';
import 'package:wger/features/routines/widgets/forms/rir.dart';
import 'package:wger/features/routines/widgets/gym_mode/exercise_overview.dart';
import 'package:wger/features/routines/widgets/gym_mode/log_page.dart';
import 'package:wger/features/routines/widgets/gym_mode/session_page.dart';
import 'package:wger/features/routines/widgets/gym_mode/start_page.dart';
import 'package:wger/features/routines/widgets/gym_mode/summary.dart';
import 'package:wger/features/routines/widgets/gym_mode/timer.dart';
import 'package:wger/features/trophies/providers/trophy_repository.dart';
import 'package:wger/helpers/shared_preferences.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/network_provider.dart';
import 'package:wger/widgets/core/error.dart';

import '../../../../test_data/exercises.dart';
import '../../../../test_data/routines.dart';
import '../../../fake_connectivity.dart';
import 'gym_mode_test.mocks.dart';

@GenerateMocks([
  WorkoutSessionRepository,
  ExerciseRepository,
  RoutinesRepository,
  TrophyRepository,
  WorkoutLogRepository,
])
void main() {
  installFakeConnectivity();

  final key = GlobalKey<NavigatorState>();

  final testRoutine = getTestRoutine();
  final testExercises = getTestExercises();

  final mockSessionRepo = MockWorkoutSessionRepository();
  final mockExerciseRepo = MockExerciseRepository();
  final mockRoutinesRepo = MockRoutinesRepository();
  final mockLogRepo = MockWorkoutLogRepository();

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

    // Past logs on the log page come from this stream (per exercise). Reuse the
    // test routine's logs so the assertions on previous entries keep working.
    when(
      mockLogRepo.watchLogsByExerciseDrift(
        routineId: anyNamed('routineId'),
        exerciseId: anyNamed('exerciseId'),
      ),
    ).thenAnswer((invocation) {
      final exerciseId = invocation.namedArguments[#exerciseId] as int;
      return Stream.value(testRoutine.filterLogsByExercise(exerciseId));
    });
  });

  Widget renderGymMode({
    locale = 'en',
    bool isOnline = true,
    List<riverpod.Override> extraOverrides = const [],
  }) {
    return riverpod.ProviderScope(
      overrides: [
        networkStatusProvider.overrideWithValue(isOnline),
        routinesRepositoryProvider.overrideWithValue(mockRoutinesRepo),
        exerciseRepositoryProvider.overrideWithValue(mockExerciseRepo),
        workoutSessionRepositoryProvider.overrideWithValue(mockSessionRepo),
        workoutLogRepositoryProvider.overrideWithValue(mockLogRepo),
        ...extraOverrides,
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
    'Test the widgets on the gym mode screen',
    (WidgetTester tester) async {
      await withClock(Clock.fixed(DateTime(2025, 3, 29, 14, 33)), () async {
        await tester.pumpWidget(renderGymMode());
        await tester.pumpAndSettle();
        await tester.tap(find.byType(TextButton));
        await tester.pumpAndSettle();

        //
        // Start page
        //
        expect(find.byType(StartPage), findsOneWidget);
        expect(find.text('Your workout today'), findsOneWidget);
        expect(find.text('Bench press'), findsOneWidget);
        expect(find.text('Side raises'), findsOneWidget);
        expect(find.byIcon(Icons.close), findsOneWidget);
        expect(find.byIcon(Icons.menu), findsOneWidget);
        expect(find.byIcon(Icons.chevron_left), findsNothing);
        expect(find.byIcon(Icons.chevron_right), findsOneWidget);
        await tester.tap(find.byIcon(Icons.chevron_right));
        await tester.pumpAndSettle();

        //
        // Bench press - exercise overview page
        //
        expect(find.text('Bench press'), findsOneWidget);
        expect(find.byType(ExerciseOverview), findsOneWidget);
        expect(find.byIcon(Icons.close), findsOneWidget);
        expect(find.byIcon(Icons.menu), findsOneWidget);
        expect(find.byIcon(Icons.chevron_left), findsOneWidget);
        expect(find.byIcon(Icons.chevron_right), findsOneWidget);
        await tester.drag(find.byType(ExerciseOverview), const Offset(-500.0, 0.0));
        await tester.pumpAndSettle();

        //
        // Bench press - Log
        //
        expect(find.text('Bench press'), findsOneWidget);
        expect(find.byType(LogPage), findsOneWidget);
        expect(find.byType(Form), findsOneWidget);
        expect(find.text('10 × 10 kg (1.5 RiR)'), findsOneWidget);
        expect(find.text('12 × 10 kg (2 RiR)'), findsOneWidget);

        // TODO: commented out for now
        // expect(find.text('Make sure to warm up'), findsOneWidget, reason: 'Set comment');
        expect(find.byIcon(Icons.close), findsOneWidget);
        expect(find.byIcon(Icons.menu), findsOneWidget);
        expect(find.byIcon(Icons.chevron_left), findsOneWidget);
        expect(find.byIcon(Icons.chevron_right), findsOneWidget);

        // The form shows reps and weight, each with its own unit
        // picker (PopupMenuButton<int>), plus the RiR slider, all at
        // once. Scope the popup-menu lookup to the LogPage so other
        // popup menus elsewhere in the app shell don't interfere.
        expect(find.byType(TextFormField), findsNWidgets(2));
        expect(
          find.descendant(
            of: find.byType(LogPage),
            matching: find.byType(PopupMenuButton<int>),
          ),
          findsNWidgets(2),
        );
        expect(find.byType(RiRInputWidget), findsOneWidget);
        // Advance to the next page via the chevron, the RiR slider
        // would otherwise eat a horizontal-drag gesture started over
        // its track.
        await tester.tap(find.byIcon(Icons.chevron_right));
        await tester.pumpAndSettle();

        //
        // Bench press - pause
        //
        expect(find.text('Pause'), findsOneWidget);
        expect(find.byType(TimerCountdownWidget), findsOneWidget);
        expect(find.byIcon(Icons.close), findsOneWidget);
        expect(find.byIcon(Icons.menu), findsOneWidget);
        expect(find.byIcon(Icons.chevron_left), findsOneWidget);
        expect(find.byIcon(Icons.chevron_right), findsOneWidget);
        await tester.tap(find.byIcon(Icons.chevron_right));
        await tester.pumpAndSettle();

        //
        // Bench press - log
        //
        expect(find.text('Bench press'), findsOneWidget);
        expect(find.byType(LogPage), findsOneWidget);
        expect(find.byType(Form), findsOneWidget);
        await tester.drag(find.byType(LogPage), const Offset(-500.0, 0.0));
        await tester.pumpAndSettle();

        //
        // Pause
        //
        expect(find.text('Pause'), findsOneWidget);
        expect(find.byType(TimerCountdownWidget), findsOneWidget);
        expect(find.byIcon(Icons.chevron_left), findsOneWidget);
        expect(find.byIcon(Icons.close), findsOneWidget);
        expect(find.byIcon(Icons.chevron_right), findsOneWidget);
        await tester.tap(find.byIcon(Icons.chevron_right));
        await tester.pumpAndSettle();

        //
        // Bench press - log
        //
        expect(find.text('Bench press'), findsOneWidget);
        expect(find.byType(LogPage), findsOneWidget);
        expect(find.byType(Form), findsOneWidget);
        await tester.tap(find.byIcon(Icons.chevron_right));
        await tester.pumpAndSettle();

        //
        // Pause
        //
        expect(find.text('Pause'), findsOneWidget);
        expect(find.byType(TimerCountdownWidget), findsOneWidget);
        await tester.tap(find.byIcon(Icons.chevron_right));
        await tester.pumpAndSettle();

        //
        // Side raises - overview
        //
        expect(find.text('Side raises'), findsOneWidget);
        expect(find.byType(ExerciseOverview), findsOneWidget);
        await tester.tap(find.byIcon(Icons.chevron_right));
        await tester.pumpAndSettle();

        //
        // Side raises - log
        //
        expect(find.text('Side raises'), findsOneWidget);
        expect(find.byType(LogPage), findsOneWidget);
        await tester.tap(find.byIcon(Icons.chevron_right));
        await tester.pumpAndSettle();

        //
        // Side raises - timer
        //
        expect(find.byType(TimerWidget), findsOneWidget);
        await tester.tap(find.byIcon(Icons.chevron_right));
        await tester.pumpAndSettle();

        //
        // Side raises - log
        //
        expect(find.text('Side raises'), findsOneWidget);
        expect(find.byType(LogPage), findsOneWidget);
        await tester.tap(find.byIcon(Icons.chevron_right));
        await tester.pumpAndSettle();

        //
        // Side raises - timer
        //
        expect(find.byType(TimerWidget), findsOneWidget);
        await tester.tap(find.byIcon(Icons.chevron_right));
        await tester.pumpAndSettle();

        //
        // Side raises - log
        //
        expect(find.text('Side raises'), findsOneWidget);
        expect(find.byType(LogPage), findsOneWidget);
        await tester.tap(find.byIcon(Icons.chevron_right));
        await tester.pumpAndSettle();

        //
        // Side raises - timer
        //
        expect(find.byType(TimerWidget), findsOneWidget);
        await tester.tap(find.byIcon(Icons.chevron_right));
        await tester.pumpAndSettle();

        //
        // Session
        //
        expect(find.text('Workout session'), findsOneWidget);
        expect(find.byType(SessionPage), findsOneWidget);
        expect(find.byType(Form), findsOneWidget);
        expect(find.byIcon(Icons.sentiment_very_dissatisfied), findsOneWidget);
        expect(find.byIcon(Icons.sentiment_neutral), findsOneWidget);
        expect(find.byIcon(Icons.sentiment_very_satisfied), findsOneWidget);
        expect(
          find.text('2:33 PM'),
          findsNWidgets(2),
          reason: 'start and end time are the same',
        );
        final toggleButtons = tester.widget<ToggleButtons>(find.byType(ToggleButtons));
        expect(toggleButtons.isSelected[1], isTrue);
        expect(find.byIcon(Icons.chevron_left), findsOneWidget);
        expect(find.byIcon(Icons.close), findsOneWidget);
        expect(find.byIcon(Icons.chevron_right), findsOneWidget);
        await tester.tap(find.byIcon(Icons.chevron_right));
        await tester.pumpAndSettle();

        //
        // Workout summary
        //
        expect(find.byType(WorkoutSummary), findsOneWidget);
        expect(find.byIcon(Icons.chevron_left), findsOneWidget);
        expect(find.byIcon(Icons.close), findsOneWidget);
        expect(find.byIcon(Icons.chevron_right), findsNothing);
      });
    },
    tags: ['golden'],
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

  testWidgets('offline summary shows the local session stats', (WidgetTester tester) async {
    // The trophy fetch is REST-only; offline it is skipped so the locally
    // stored session stats (duration, volume) render right away instead of
    // waiting behind a doomed network request. The clock matches a session in
    // the test routine so there is data to show.
    await withClock(Clock.fixed(DateTime(2021, 5, 1, 14, 33)), () async {
      await tester.pumpWidget(renderGymMode(isOnline: false));
      await tester.pumpAndSettle();

      // Prime the keepAlive routines stream (see the offline test above).
      final container = riverpod.ProviderScope.containerOf(
        tester.element(find.byType(TextButton)),
      );
      container.listen(routinesRiverpodProvider, (_, _) {});
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      // Jump straight to the summary via the menu's "End workout" shortcut.
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('End workout'));
      await tester.pumpAndSettle();

      expect(find.byType(WorkoutSummary), findsOneWidget);
      expect(find.byType(StreamErrorIndicator), findsNothing);
      expect(find.text('Duration'), findsOneWidget);
      expect(find.text('Volume'), findsOneWidget);
    });
  });

  testWidgets('summary surfaces an unexpected trophy-fetch error', (WidgetTester tester) async {
    // Network/server errors are swallowed by the repository, so an error that
    // does reach the summary is a genuine exception and must be shown, not
    // hidden behind the stats.
    final mockTrophyRepo = MockTrophyRepository();
    when(mockTrophyRepo.fetchTrophies(language: anyNamed('language'))).thenAnswer((_) async => []);
    when(
      mockTrophyRepo.fetchProgression(
        filterQuery: anyNamed('filterQuery'),
        language: anyNamed('language'),
      ),
    ).thenAnswer((_) async => []);
    when(
      mockTrophyRepo.fetchUserTrophies(
        filterQuery: anyNamed('filterQuery'),
        language: anyNamed('language'),
      ),
    ).thenThrow(Exception('unexpected'));

    await withClock(Clock.fixed(DateTime(2021, 5, 1, 14, 33)), () async {
      await tester.pumpWidget(
        renderGymMode(
          extraOverrides: [trophyRepositoryProvider.overrideWithValue(mockTrophyRepo)],
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      // Jump straight to the summary via the menu's "End workout" shortcut.
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('End workout'));
      await tester.pumpAndSettle();

      expect(find.byType(WorkoutSummary), findsOneWidget);
      expect(find.byType(StreamErrorIndicator), findsOneWidget);
      expect(find.text('Duration'), findsNothing);
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
        expect(find.text('Bench press'), findsOneWidget);
      });
    },
    semanticsEnabled: false,
  );
}
