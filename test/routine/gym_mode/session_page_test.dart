/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020, 2025 wger Team
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
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/helpers/json.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/models/workouts/session.dart';
import 'package:wger/providers/gym_state.dart';
import 'package:wger/providers/workout_session_repository.dart';
import 'package:wger/widgets/routines/gym_mode/session_page.dart';

import '../../../test_data/routines.dart';
import 'session_page_test.mocks.dart';

@GenerateMocks([WorkoutSessionRepository])
void main() {
  late MockWorkoutSessionRepository mockRepository;
  late Routine testRoutine;
  late GymStateNotifier notifier;
  late ProviderContainer container;

  setUp(() {
    testRoutine = getTestRoutine();
    mockRepository = MockWorkoutSessionRepository();

    container = ProviderContainer.test();
    notifier = container.read(gymStateProvider.notifier);
    notifier.state = notifier.state.copyWith(
      showExercisePages: true,
      showTimerPages: true,
      dayId: 1,
      iteration: 1,
      routine: getTestRoutine(),
    );
    notifier.calculatePages();
    when(mockRoutinesProvider.editSession(any)).thenAnswer(
      (_) => Future.value(testRoutine.sessions[0]),
    );
  });

  Widget renderSessionPage({locale = 'en'}) {
    //final controller = PageController(initialPage: 0);

    return UncontrolledProviderScope(
      overrides: [
        workoutSessionRepositoryProvider.overrideWithValue(mockRepository),
      ],
      container: container,
      child: ChangeNotifierProvider<RoutinesProvider>(
        create: (context) => mockRoutinesProvider,
        child: MaterialApp(
          locale: Locale(locale),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: PageView(
              controller: controller,
              children: [
                SessionPage(controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('Test that data from  session is loaded', (WidgetTester tester) async {
    withClock(Clock.fixed(DateTime(2021, 5, 1)), () async {
      await tester.pumpWidget(renderSessionPage());
      expect(find.text('10:00'), findsOneWidget);
      expect(find.text('12:34'), findsOneWidget);
      expect(find.text('This is a note'), findsOneWidget);
      final toggleButtons = tester.widget<ToggleButtons>(find.byType(ToggleButtons));
      expect(toggleButtons.isSelected[2], isTrue);
    });
  });

  testWidgets('Test that data from  session is loaded - null times', (WidgetTester tester) async {
    testRoutine.sessions[0].timeStart = null;
    testRoutine.sessions[0].timeEnd = null;

    notifier.state = notifier.state.copyWith(routine: testRoutine);
    notifier.calculatePages();

    withClock(Clock.fixed(DateTime(2021, 5, 1)), () async {
      await tester.pumpWidget(renderSessionPage());

      final startTimeField = find.byKey(const ValueKey('time-start'));
      expect(startTimeField, findsOneWidget);
      expect(tester.widget<TextFormField>(startTimeField).controller!.text, '');

      final endTimeField = find.byKey(const ValueKey('time-end'));
      expect(endTimeField, findsOneWidget);
      expect(tester.widget<TextFormField>(endTimeField).controller!.text, '');
    });
  });

  testWidgets('Test correct default data (no existing session)', (WidgetTester tester) async {
    // Arrange
    testRoutine.sessions = [];
    final timeNow = timeToString(TimeOfDay.now())!;
    notifier.state = notifier.state.copyWith(
      startTime: const TimeOfDay(hour: 13, minute: 35),
    );

    // Act
    await tester.pumpWidget(renderSessionPage());

    // Assert
    expect(find.text('13:35'), findsOneWidget);
    expect(find.text(timeNow), findsOneWidget);
    final toggleButtons = tester.widget<ToggleButtons>(find.byType(ToggleButtons));
    expect(toggleButtons.isSelected[1], isTrue);
  });

  testWidgets('Test that correct data is send to server', (WidgetTester tester) async {
    withClock(Clock.fixed(DateTime(2021, 5, 1)), () async {
      await tester.pumpWidget(renderSessionPage());
      await tester.tap(find.byKey(const ValueKey('save-button')));
      final captured =
          verify(mockRepository.editLocalDrift(captureAny as dynamic)).captured.single
              as WorkoutSession;

      expect(captured.id, '1');
      expect(captured.impression, 3);
      expect(captured.notes, equals('This is a note'));
      expect(captured.timeStart, equals(const TimeOfDay(hour: 10, minute: 0)));
      expect(captured.timeEnd, equals(const TimeOfDay(hour: 12, minute: 34)));
    });
  });
}
