/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) wger Team
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
import 'package:wger/providers/routines.dart';
import 'package:wger/widgets/routines/gym_mode/session_page.dart';

import '../../test_data/routines.dart';
import 'gym_mode_session_screen_test.mocks.dart';

@GenerateMocks([RoutinesProvider])
void main() {
  final mockRoutinesProvider = MockRoutinesProvider();
  late Routine testRoutine;

  setUp(() {
    testRoutine = getTestRoutine();

    when(mockRoutinesProvider.editSession(any)).thenAnswer(
      (_) => Future.value(testRoutine.sessions[0]),
    );
  });

  Widget renderSessionPage({locale = 'en'}) {
    return ProviderScope(
      overrides: [
        routinesChangeProvider.overrideWithValue(mockRoutinesProvider),
      ],
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SessionPage(
            testRoutine,
            PageController(),
            const TimeOfDay(hour: 13, minute: 35),
            const {},
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
    testRoutine.sessions = [];
    final timeNow = timeToString(TimeOfDay.now())!;

    await tester.pumpWidget(renderSessionPage());
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
          verify(mockRoutinesProvider.editSession(captureAny)).captured.single as WorkoutSession;

      expect(captured.id, '1');
      expect(captured.impression, 3);
      expect(captured.notes, equals('This is a note'));
      expect(captured.timeStart, equals(const TimeOfDay(hour: 10, minute: 0)));
      expect(captured.timeEnd, equals(const TimeOfDay(hour: 12, minute: 34)));
    });
  });
}
