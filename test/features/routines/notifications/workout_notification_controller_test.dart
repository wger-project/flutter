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

import 'dart:ui';

import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:wger/core/keys.dart';
import 'package:wger/features/routines/notifications/workout_notification_content.dart';
import 'package:wger/features/routines/notifications/workout_notification_controller.dart';
import 'package:wger/features/routines/notifications/workout_notification_service.dart';
import 'package:wger/features/routines/providers/gym_state.dart';
import 'package:wger/features/routines/providers/gym_state_notifier.dart';
import 'package:wger/features/routines/providers/workout_logs_repository.dart';
import 'package:wger/features/routines/screens/gym_mode.dart';

import '../../../../test_data/routines.dart';
import 'workout_notification_controller_test.mocks.dart';

@GenerateMocks([WorkoutNotificationService, WorkoutLogRepository])
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final now = DateTime.utc(2025, 3, 29, 14, 33);
  late MockWorkoutNotificationService service;
  late MockWorkoutLogRepository logRepo;
  late ProviderContainer container;
  late GymStateNotifier gymState;

  setUp(() {
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
    binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    service = MockWorkoutNotificationService();
    when(service.supportsControls).thenReturn(true);
    when(service.cancelAll()).thenAnswer((_) async {});
    when(service.scheduleRestAlarm(any, any)).thenAnswer((_) async {});
    when(service.showControls(any, any)).thenAnswer((_) async {});
    when(service.showNotLogged(any)).thenAnswer((_) async {});
    when(service.actionHandled()).thenAnswer((_) async {});
    when(service.initialize(any, onTap: anyNamed('onTap'))).thenAnswer((_) async {});
    logRepo = MockWorkoutLogRepository();
    when(logRepo.addLocalDrift(any, dayId: anyNamed('dayId'))).thenAnswer((_) async {});

    container = ProviderContainer.test(
      overrides: [
        workoutNotificationServiceProvider.overrideWithValue(service),
        workoutLogRepositoryProvider.overrideWithValue(logRepo),
      ],
    );
    container.read(workoutNotificationControllerProvider);
    gymState = container.read(gymStateProvider.notifier);
  });

  /// Lets the controller's queued platform calls run
  Future<void> settle() => pumpEventQueue();

  void initGymMode() {
    final routine = getTestRoutine();
    gymState.initData(routine, routine.days.first.id!, 1);
  }

  /// Moves to the first rest of the fixture (120 s), initializing if needed
  Future<void> startRest() async {
    if (!gymState.state.isInitialized) {
      initGymMode();
    }
    final timer = gymState.state.pages
        .expand((p) => p.slotPages)
        .firstWhere((p) => p.type == SlotPageType.timer);
    withClock(Clock.fixed(now), () => gymState.setCurrentPage(timer.pageIndex - 1));
    await withClock(Clock.fixed(now), () async {
      gymState.setCurrentPage(timer.pageIndex);
      await settle();
    });
  }

  test('A rest away from gym mode schedules the alarm and shows the controls', () async {
    await startRest();

    verifyInOrder([
      service.cancelAll(),
      service.scheduleRestAlarm(argThat(isA<RestAlarm>()), any),
      service.showControls(argThat(isA<WorkoutControls>()), any),
    ]);
  });

  test('Unchanged notifications cause no platform calls', () async {
    await startRest();
    clearInteractions(service);

    // A state change that does not touch the notification
    await withClock(Clock.fixed(now), () async {
      gymState.setShowDistinctLogs(false);
      await settle();
    });

    verifyNever(service.cancelAll());
    verifyNever(service.scheduleRestAlarm(any, any));
    verifyNever(service.showControls(any, any));
  });

  test('Nothing while gym mode is on screen, back when the app goes to the background', () async {
    await startRest();
    clearInteractions(service);

    container.read(gymModeVisibleProvider.notifier).set(true);
    await settle();
    verify(service.cancelAll()).called(1);
    verifyNever(service.scheduleRestAlarm(any, any));
    verifyNever(service.showControls(any, any));

    await withClock(Clock.fixed(now), () async {
      binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      await settle();
    });
    verify(service.scheduleRestAlarm(any, any)).called(1);
    verify(service.showControls(any, any)).called(1);
  });

  test('Ending gym mode removes everything', () async {
    await startRest();
    clearInteractions(service);

    gymState.clear();
    await settle();

    verify(service.cancelAll()).called(1);
    verifyNever(service.scheduleRestAlarm(any, any));
    verifyNever(service.showControls(any, any));
  });

  test('Each setting only switches off its own notification', () async {
    initGymMode();
    gymState.state = gymState.state.copyWith(restAlarmEnabled: false);
    await startRest();
    verifyNever(service.scheduleRestAlarm(any, any));
    verify(service.showControls(any, any));

    clearInteractions(service);
    await withClock(Clock.fixed(now), () async {
      gymState.state = gymState.state.copyWith(
        restAlarmEnabled: true,
        showWorkoutNotification: false,
      );
      await settle();
    });
    verify(service.scheduleRestAlarm(any, any)).called(1);
    verifyNever(service.showControls(any, any));
  });

  test('No controls on platforms without them', () async {
    when(service.supportsControls).thenReturn(false);

    await startRest();

    verify(service.scheduleRestAlarm(any, any)).called(1);
    verifyNever(service.showControls(any, any));
  });

  group('Startup', () {
    test('Initializes the service with the tap handler', () {
      verify(service.initialize(any, onTap: argThat(isNotNull, named: 'onTap'))).called(1);
    });

    test('Leftovers of an earlier run are removed when the app comes to the front', () async {
      await settle();
      clearInteractions(service);

      // The listener only accepts single steps
      [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ].forEach(binding.handleAppLifecycleStateChanged);
      await settle();

      verify(service.cancelAll()).called(1);
    });
  });

  group('Actions', () {
    SlotPageEntry slotPage(int index) => gymState.state.getSlotEntryPageByIndex(index)!;

    /// The payload the notification on the current page carries
    String payloadFor({String? logSlotUuid, String? restSlotUuid, DateTime? workoutStart}) =>
        WorkoutNotificationPayload(
          routineId: gymState.state.routine.id!,
          dayId: gymState.state.dayId,
          iteration: gymState.state.iteration,
          workoutStart: workoutStart ?? gymState.state.workoutStart,
          logSlotUuid: logSlotUuid,
          restSlotUuid: restSlotUuid,
        ).encode();

    test('"Log set" from the rest logs the next set and shows the next rest', () async {
      await startRest();
      final rest = gymState.state.currentPage;
      clearInteractions(service);

      await withClock(Clock.fixed(now), () async {
        await container
            .read(workoutNotificationControllerProvider)
            .handleAction(
              WORKOUT_NOTIFICATION_ACTION_LOG_SET,
              payloadFor(logSlotUuid: slotPage(rest + 1).uuid),
            );
        await settle();
      });

      verify(logRepo.addLocalDrift(any, dayId: anyNamed('dayId'))).called(1);
      expect(gymState.state.currentPage, rest + 2);
      // Only once the notification shows the new rest may iOS suspend the app
      verifyInOrder([service.showControls(any, any), service.actionHandled()]);
      final alarms = verify(service.scheduleRestAlarm(captureAny, any)).captured;
      expect((alarms.last as RestAlarm).payload.restSlotUuid, slotPage(rest + 2).uuid);
    });

    test('Actions arrive through the port from the background isolate', () async {
      await startRest();
      final rest = gymState.state.currentPage;

      IsolateNameServer.lookupPortByName(WORKOUT_NOTIFICATION_PORT)!.send([
        WORKOUT_NOTIFICATION_ACTION_SKIP_REST,
        payloadFor(restSlotUuid: slotPage(rest).uuid),
      ]);
      await settle();

      expect(gymState.state.currentPage, rest + 1);
    });

    test('A stale action changes nothing but shows the notification again', () async {
      await startRest();
      final rest = gymState.state.currentPage;
      clearInteractions(service);

      await withClock(Clock.fixed(now), () async {
        final controller = container.read(workoutNotificationControllerProvider);
        // From another session
        await controller.handleAction(
          WORKOUT_NOTIFICATION_ACTION_LOG_SET,
          payloadFor(
            logSlotUuid: slotPage(rest + 1).uuid,
            workoutStart: DateTime.utc(2020),
          ),
        );
        // For a rest the user already left
        await controller.handleAction(
          WORKOUT_NOTIFICATION_ACTION_SKIP_REST,
          payloadFor(restSlotUuid: slotPage(rest - 2).uuid),
        );
        await settle();
      });

      verifyNever(logRepo.addLocalDrift(any, dayId: anyNamed('dayId')));
      expect(gymState.state.currentPage, rest);
      verify(service.cancelAll()).called(2);
      verify(service.showControls(any, any)).called(2);
    });

    test('Without a running session the user is sent to the app', () async {
      await container
          .read(workoutNotificationControllerProvider)
          .handleAction(WORKOUT_NOTIFICATION_ACTION_LOG_SET, null);
      await settle();

      verifyInOrder([service.showNotLogged(any), service.actionHandled()]);
      verifyNever(logRepo.addLocalDrift(any, dayId: anyNamed('dayId')));
    });
  });

  group('Tap on the notification', () {
    Future<void> pumpApp(WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            navigatorKey: navigatorKey,
            home: const Text('home'),
            routes: {GymModeScreen.routeName: (_) => const Text('gym mode')},
          ),
        ),
      );
    }

    String currentPayload() => WorkoutNotificationPayload(
      routineId: gymState.state.routine.id!,
      dayId: gymState.state.dayId,
      iteration: gymState.state.iteration,
      workoutStart: gymState.state.workoutStart,
    ).encode();

    testWidgets('Opens the running gym mode', (tester) async {
      initGymMode();
      await pumpApp(tester);

      container.read(workoutNotificationControllerProvider).handleTap(currentPayload());
      await tester.pumpAndSettle();

      expect(find.text('gym mode'), findsOneWidget);
    });

    testWidgets('Stays put for another session or with gym mode on screen', (tester) async {
      initGymMode();
      await pumpApp(tester);
      final controller = container.read(workoutNotificationControllerProvider);

      controller.handleTap(
        WorkoutNotificationPayload(
          routineId: gymState.state.routine.id!,
          dayId: gymState.state.dayId,
          iteration: gymState.state.iteration,
          workoutStart: DateTime.utc(2020),
        ).encode(),
      );
      container.read(gymModeVisibleProvider.notifier).set(true);
      controller.handleTap(currentPayload());
      await tester.pumpAndSettle();

      expect(find.text('gym mode'), findsNothing);
    });
  });
}
