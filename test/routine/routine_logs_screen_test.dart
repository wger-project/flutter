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

import 'dart:io';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/log.dart';
import 'package:wger/models/workouts/repetition_unit.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/models/workouts/weight_unit.dart';
import 'package:wger/providers/network_provider.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/providers/trophies.dart';
import 'package:wger/providers/workout_logs_repository.dart';
import 'package:wger/screens/routine_logs_screen.dart';
import 'package:wger/screens/routine_screen.dart';
import 'package:wger/widgets/routines/logs/log_overview_routine.dart';

import '../../test_data/routines.dart';
import '../test_data/trophies.dart';
import 'routine_logs_screen_test.mocks.dart';

class _StubRoutinesRiverpod extends RoutinesRiverpod {
  _StubRoutinesRiverpod(this._routines);
  final List<Routine> _routines;

  @override
  Stream<RoutinesState> build() => Stream.value(RoutinesState(routines: _routines));
}

@GenerateMocks([TrophyRepository, WorkoutLogRepository])
void main() {
  late Routine routine;
  final mockWorkoutLogRepository = MockWorkoutLogRepository();

  setUp(() {
    routine = getTestRoutine();
    routine.sessions[0].date = DateTime(2025, 3, 29);
    // Pin every log to a known session id so we can verify the edit
    // dialog round-trips the value through the model.
    for (final log in routine.sessions[0].logs) {
      log.sessionId = 'session-fixture-1';
    }

    when(mockWorkoutLogRepository.deleteLocalDrift(any)).thenAnswer((_) async => Future.value());
    when(mockWorkoutLogRepository.updateLocalDrift(any)).thenAnswer((_) async => Future.value());
  });

  Widget renderWidget({locale = 'en', isOnline = true}) {
    final key = GlobalKey<NavigatorState>();

    final mockRepository = MockTrophyRepository();
    when(
      mockRepository.fetchUserTrophies(
        filterQuery: anyNamed('filterQuery'),
        language: anyNamed('language'),
      ),
    ).thenAnswer((_) async => getUserTrophies());

    final container = ProviderContainer.test(
      overrides: [
        networkStatusProvider.overrideWithValue(isOnline),
        workoutLogRepositoryProvider.overrideWithValue(mockWorkoutLogRepository),
        trophyRepositoryProvider.overrideWithValue(mockRepository),
        routinesRiverpodProvider.overrideWith(
          () => _StubRoutinesRiverpod([routine]),
        ),
        routineRepetitionUnitProvider.overrideWith(
          (ref) => Stream<List<RepetitionUnit>>.value(testRepetitionUnits),
        ),
        routineWeightUnitProvider.overrideWith(
          (ref) => Stream<List<WeightUnit>>.value(testWeightUnits),
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
              settings: RouteSettings(arguments: routine.id),
              builder: (_) => const WorkoutLogsScreen(),
            ),
          ),
          child: const SizedBox(),
        ),
        routes: {
          RoutineScreen.routeName: (ctx) => const WorkoutLogsScreen(),
        },
      ),
    );
  }

  testWidgets(
    'Smoke test the widgets on the routine logs screen',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(500, 1000);
      tester.view.devicePixelRatio = 1.0; // Ensure correct pixel ratio

      await withClock(Clock.fixed(DateTime(2025, 3, 29)), () async {
        await tester.pumpWidget(renderWidget());
        await tester.tap(find.byType(TextButton));
        await tester.pumpAndSettle();

        if (Platform.isLinux) {
          await expectLater(
            find.byType(WorkoutLogsScreen),
            matchesGoldenFile('goldens/routine_logs_screen_detail.png'),
          );
        }

        expect(find.text('Training logs'), findsOneWidget);
        expect(find.byType(WorkoutLogCalendar), findsOneWidget);
        expect(find.text('Bench press'), findsOneWidget);
        expect(find.byKey(const ValueKey('delete-log-1')), findsOneWidget);
        expect(find.byKey(const ValueKey('delete-log-2')), findsOneWidget);
        expect(find.byKey(const ValueKey('delete-log-3')), findsNothing);
      });
    },
    tags: ['golden'],
  );

  testWidgets('Test deleting log entries', (WidgetTester tester) async {
    await withClock(Clock.fixed(DateTime(2025, 3, 29)), () async {
      await tester.pumpWidget(renderWidget());
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('delete-log-1')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('delete-button')), findsOneWidget);
      expect(find.byKey(const ValueKey('cancel-button')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('delete-button')));
      verify(mockWorkoutLogRepository.deleteLocalDrift('1')).called(1);
    });
  });

  testWidgets('Edit dialog opens, edits a value and saves through the repo', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(500, 1200);
    tester.view.devicePixelRatio = 1.0;

    await withClock(Clock.fixed(DateTime(2025, 3, 29)), () async {
      await tester.pumpWidget(renderWidget());
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Open the edit dialog for log id=1
      expect(find.byKey(const ValueKey('edit-log-1')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('edit-log-1')));
      await tester.pumpAndSettle();

      // The dialog renders the form and the save/cancel buttons
      expect(find.byKey(const ValueKey('edit-reps-widget')), findsOneWidget);
      expect(find.byKey(const ValueKey('edit-weight-widget')), findsOneWidget);
      expect(find.byKey(const ValueKey('edit-save-button')), findsOneWidget);
      expect(find.byKey(const ValueKey('edit-cancel-button')), findsOneWidget);

      // Type a new repetitions value and save
      final repsField = find.descendant(
        of: find.byKey(const ValueKey('edit-reps-widget')),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(repsField, '15');
      await tester.tap(find.byKey(const ValueKey('edit-save-button')));
      await tester.pumpAndSettle();

      // The repository was called with the edited log; the id and
      // sessionId are preserved while repetitions reflect the new
      // value.
      final captured = verify(mockWorkoutLogRepository.updateLocalDrift(captureAny)).captured;
      expect(captured, hasLength(1));
      final updated = captured.single as Log;
      expect(updated.id, '1');
      expect(updated.repetitions, 15);
      expect(updated.sessionId, 'session-fixture-1');
    });
  });

  testWidgets('Edit dialog quick-plus updates the controller without rebuild error', (
    WidgetTester tester,
  ) async {
    // Regression test: tapping the "+" or "-" quick-buttons triggers a
    // parent setState which propagates a new `value` prop into the
    // controlled input; if `didUpdateWidget` writes to the
    // TextEditingController synchronously, the controller's listeners
    // call `setState` on the Form mid-build, which throws.

    tester.view.physicalSize = const Size(500, 1200);
    tester.view.devicePixelRatio = 1.0;

    await withClock(Clock.fixed(DateTime(2025, 3, 29)), () async {
      await tester.pumpWidget(renderWidget());
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('edit-log-1')));
      await tester.pumpAndSettle();

      // Original log has 10 reps. Tap quick-plus once.
      final plusButton = find
          .descendant(
            of: find.byKey(const ValueKey('edit-reps-widget')),
            matching: find.widgetWithIcon(IconButton, Icons.add),
          )
          .first;
      await tester.tap(plusButton);
      await tester.pumpAndSettle();

      // No exception was thrown; the field reflects the new value.
      expect(tester.takeException(), isNull);
      final repsField = find.descendant(
        of: find.byKey(const ValueKey('edit-reps-widget')),
        matching: find.byType(TextFormField),
      );
      final controller = (tester.widget(repsField) as TextFormField).controller;
      expect(controller?.text, '11');
    });
  });

  testWidgets('Edit dialog shows all input fields by default', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(500, 1200);
    tester.view.devicePixelRatio = 1.0;

    await withClock(Clock.fixed(DateTime(2025, 3, 29)), () async {
      await tester.pumpWidget(renderWidget());
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('edit-log-1')));
      await tester.pumpAndSettle();

      // The dialog renders all the editable fields without any
      // hide-behind-toggle: reps (with embedded unit dropdown), weight
      // (with embedded unit dropdown), and RiR.
      expect(find.byKey(const ValueKey('edit-reps-widget')), findsOneWidget);
      expect(find.byKey(const ValueKey('edit-weight-widget')), findsOneWidget);
      expect(find.byKey(const ValueKey('edit-rir-widget')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('edit-reps-widget')),
          matching: find.byType(PopupMenuButton<int>),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('edit-weight-widget')),
          matching: find.byType(PopupMenuButton<int>),
        ),
        findsOneWidget,
      );
    });
  });

  testWidgets('Edit dialog cancel does not call the repository', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(500, 1200);
    tester.view.devicePixelRatio = 1.0;

    await withClock(Clock.fixed(DateTime(2025, 3, 29)), () async {
      await tester.pumpWidget(renderWidget());
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('edit-log-1')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('edit-cancel-button')));
      await tester.pumpAndSettle();

      verifyNever(mockWorkoutLogRepository.updateLocalDrift(any));
    });
  });

  testWidgets('Log deletion is available offline (PowerSync queues writes)', (
    WidgetTester tester,
  ) async {
    // Log deletion is backed by PowerSync, so it must work even when offline:
    // the delete is queued locally and synced once the network is back.

    await withClock(Clock.fixed(DateTime(2025, 3, 29)), () async {
      await tester.pumpWidget(renderWidget(isOnline: false));
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('delete-log-1')));
      await tester.pumpAndSettle();

      // The confirmation dialog opens regardless of network status …
      expect(find.byKey(const ValueKey('delete-button')), findsOneWidget);
      expect(find.byKey(const ValueKey('cancel-button')), findsOneWidget);

      // … and confirming triggers the local delete.
      await tester.tap(find.byKey(const ValueKey('delete-button')));
      await tester.pumpAndSettle();
      verify(mockWorkoutLogRepository.deleteLocalDrift(any)).called(1);
    });
  });
}
