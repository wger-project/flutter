/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
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

import 'dart:io';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/providers/network_provider.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/providers/workout_log_repository.dart';
import 'package:wger/screens/routine_logs_screen.dart';
import 'package:wger/screens/routine_screen.dart';
import 'package:wger/widgets/routines/workout_logs.dart';

import '../../test_data/routines.dart';
import 'routine_logs_screen_test.mocks.dart';

@GenerateMocks([RoutinesProvider, WorkoutLogRepository])
void main() {
  late Routine routine;
  final mockRoutinesProvider = MockRoutinesProvider();
  final mockWorkoutLogRepository = MockWorkoutLogRepository();

  setUp(() {
    routine = getTestRoutine();
    routine.sessions[0].date = DateTime(2025, 3, 29);

    when(mockRoutinesProvider.findById(any)).thenAnswer((_) => routine);
    when(mockWorkoutLogRepository.deleteLocalDrift(any)).thenAnswer((_) async => Future.value());
  });

  Widget renderWidget({locale = 'en', isOnline = true}) {
    final key = GlobalKey<NavigatorState>();

    return ProviderScope(
      overrides: [
        networkStatusProvider.overrideWithValue(isOnline),
        workoutLogRepositoryProvider.overrideWithValue(mockWorkoutLogRepository),
        routinesChangeProvider.overrideWithValue(mockRoutinesProvider),
      ],
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

  testWidgets('Handle offline status', (WidgetTester tester) async {
    // If the user is offline, the delete button is deactivated and no dialog is shown

    await withClock(Clock.fixed(DateTime(2025, 3, 29)), () async {
      await tester.pumpWidget(renderWidget(isOnline: false));
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('delete-log-1')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('delete-button')), findsNothing);
      expect(find.byKey(const ValueKey('cancel-button')), findsNothing);
      verifyNever(mockWorkoutLogRepository.deleteLocalDrift(any));
    });
  });
}
