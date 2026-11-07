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
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:wger/features/routines/models/log.dart';
import 'package:wger/features/routines/notifications/workout_notification_content.dart';
import 'package:wger/features/routines/notifications/workout_notification_controller.dart';
import 'package:wger/features/routines/notifications/workout_notification_service.dart';
import 'package:wger/features/routines/providers/gym_state.dart';
import 'package:wger/features/routines/providers/gym_state_notifier.dart';
import 'package:wger/features/routines/providers/workout_logs_notifier.dart';
import 'package:wger/features/routines/providers/workout_logs_repository.dart';

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
    when(service.initialize(any)).thenAnswer((_) async {});
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

  /// The listener only accepts single steps between lifecycle states
  void stepLifecycle(List<AppLifecycleState> states) =>
      states.forEach(binding.handleAppLifecycleStateChanged);

  void toBackground() => stepLifecycle([AppLifecycleState.inactive, AppLifecycleState.hidden]);

  void toForeground() => stepLifecycle([AppLifecycleState.inactive, AppLifecycleState.resumed]);

  /// Gym mode open in the background, on the first rest of the fixture (120 s)
  Future<void> startRest() async {
    if (!gymState.state.isInitialized) {
      initGymMode();
    }
    container.read(gymModeVisibleProvider.notifier).set(true);
    if (binding.lifecycleState == AppLifecycleState.resumed) {
      toBackground();
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

  test('A rest in the background schedules the alarm and shows the controls', () async {
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

  test('A failed platform call is retried on the next update', () async {
    // E.g. the rest ended between building and scheduling the alarm
    when(service.scheduleRestAlarm(any, any)).thenThrow(ArgumentError('in the past'));
    await startRest();

    when(service.scheduleRestAlarm(any, any)).thenAnswer((_) async {});
    clearInteractions(service);
    await withClock(Clock.fixed(now), () async {
      gymState.setShowDistinctLogs(false);
      await settle();
    });

    verify(service.scheduleRestAlarm(any, any)).called(1);
    verify(service.showControls(any, any)).called(1);
  });

  test('Nothing while gym mode is on screen, back when the app goes to the background', () async {
    await startRest();
    clearInteractions(service);

    toForeground();
    await settle();
    verify(service.cancelAll()).called(1);
    verifyNever(service.scheduleRestAlarm(any, any));
    verifyNever(service.showControls(any, any));

    await withClock(Clock.fixed(now), () async {
      toBackground();
      await settle();
    });
    verify(service.scheduleRestAlarm(any, any)).called(1);
    verify(service.showControls(any, any)).called(1);
  });

  test('Leaving gym mode removes everything, the session stays resumable', () async {
    await startRest();
    clearInteractions(service);

    // X or back closes the screen, also with the app on its way to the background
    container.read(gymModeVisibleProvider.notifier).set(false);
    await settle();

    verify(service.cancelAll()).called(1);
    verifyNever(service.scheduleRestAlarm(any, any));
    verifyNever(service.showControls(any, any));
    expect(gymState.state.isInitialized, isTrue);
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
    gymState.state = gymState.state.copyWith(alertOnCountdownEnd: false);
    await startRest();
    // Only the silent switch of the controls at the rest end
    final silent = verify(service.scheduleRestAlarm(captureAny, any)).captured.single as RestAlarm;
    expect(silent.silent, isTrue);
    verify(service.showControls(any, any));

    clearInteractions(service);
    await withClock(Clock.fixed(now), () async {
      gymState.state = gymState.state.copyWith(
        alertOnCountdownEnd: true,
        showWorkoutNotification: false,
      );
      await settle();
    });
    final alarm = verify(service.scheduleRestAlarm(captureAny, any)).captured.single as RestAlarm;
    expect(alarm.silent, isFalse);
    verifyNever(service.showControls(any, any));
  });

  test('No controls on platforms without them', () async {
    when(service.supportsControls).thenReturn(false);

    await startRest();

    verify(service.scheduleRestAlarm(any, any)).called(1);
    verifyNever(service.showControls(any, any));
  });

  group('Startup', () {
    test('Initializes the service at startup', () {
      verify(service.initialize(any)).called(1);
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

    test('Platforms without notifications set nothing up, the web has no isolates', () {
      IsolateNameServer.removePortNameMapping(WORKOUT_NOTIFICATION_PORT);
      final noop = ProviderContainer.test(
        overrides: [
          workoutNotificationServiceProvider.overrideWithValue(NoopWorkoutNotificationService()),
        ],
      );

      noop.read(workoutNotificationControllerProvider);

      expect(IsolateNameServer.lookupPortByName(WORKOUT_NOTIFICATION_PORT), isNull);
    });
  });

  group('Actions', () {
    SlotPageEntry slotPage(int index) => gymState.state.getSlotEntryPageByIndex(index)!;

    /// The payload the notification on the current page carries
    String payloadFor({String? logSlotKey, String? restSlotKey, DateTime? workoutStart}) =>
        WorkoutNotificationPayload(
          routineId: gymState.state.routine.id!,
          dayId: gymState.state.dayId,
          iteration: gymState.state.iteration,
          workoutStart: workoutStart ?? gymState.state.workoutStart,
          logSlotKey: logSlotKey,
          restSlotKey: restSlotKey,
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
              payloadFor(logSlotKey: slotPage(rest + 1).key),
            );
        await settle();
      });

      verify(logRepo.addLocalDrift(any, dayId: anyNamed('dayId'))).called(1);
      expect(gymState.state.currentPage, rest + 2);
      // Only once the notification shows the new rest may iOS suspend the app
      verifyInOrder([service.showControls(any, any), service.actionHandled()]);
      final alarms = verify(service.scheduleRestAlarm(captureAny, any)).captured;
      expect((alarms.last as RestAlarm).payload.restSlotKey, slotPage(rest + 2).key);
    });

    test('Actions arrive through the port from the background isolate', () async {
      await startRest();
      final rest = gymState.state.currentPage;

      IsolateNameServer.lookupPortByName(WORKOUT_NOTIFICATION_PORT)!.send([
        WORKOUT_NOTIFICATION_ACTION_SKIP_REST,
        payloadFor(restSlotKey: slotPage(rest).key),
        null,
      ]);
      await settle();

      expect(gymState.state.currentPage, rest + 1);
    });

    group('Quick logs', () {
      late Log earlier;

      setUp(() {
        earlier = Log(
          exerciseId: getTestRoutine().days.first.slots.first.entries.first.exerciseId,
          repetitions: 9,
          weight: 60,
        );
        earlier.weightUnit = testWeightUnit1;
        when(
          logRepo.watchLogsByExerciseDrift(
            routineId: anyNamed('routineId'),
            exerciseId: anyNamed('exerciseId'),
            since: anyNamed('since'),
          ),
        ).thenAnswer((_) => Stream.value([earlier]));
      });

      Log capturedLog() =>
          verify(logRepo.addLocalDrift(captureAny, dayId: anyNamed('dayId'))).captured.single
              as Log;

      test('The rest end offers earlier logs of the next set', () async {
        await startRest();

        // The rest end shows them, the running rest not
        final alarms = verify(service.scheduleRestAlarm(captureAny, any)).captured;
        expect((alarms.last as RestAlarm).quickLogs, ['9 × 60 kg']);
      });

      test('Also when the log page already loaded the earlier logs', () async {
        initGymMode();
        final next = gymState.state.pages
            .expand((p) => p.slotPages)
            .firstWhere((p) => p.type == SlotPageType.log);
        final pastLogs = container.listen(
          pastExerciseLogsProvider(
            routineId: gymState.state.routine.id!,
            exerciseId: next.setConfigData!.exerciseId,
            weeksBack: gymState.state.logScopeWeeks,
          ),
          (_, _) {},
        );
        addTearDown(pastLogs.close);
        await settle();

        await startRest();

        // The rest end shows them, the running rest not
        final alarms = verify(service.scheduleRestAlarm(captureAny, any)).captured;
        expect((alarms.last as RestAlarm).quickLogs, ['9 × 60 kg']);
      });

      test('A picked quick log arrives through the port and logs its values', () async {
        await startRest();
        final rest = gymState.state.currentPage;

        IsolateNameServer.lookupPortByName(WORKOUT_NOTIFICATION_PORT)!.send([
          WORKOUT_NOTIFICATION_ACTION_LOG_SET,
          payloadFor(logSlotKey: slotPage(rest + 1).key),
          '9 × 60 kg',
        ]);
        await settle();

        final saved = capturedLog();
        expect(saved.repetitions, 9);
        expect(saved.weight, 60);
        expect(gymState.state.currentPage, rest + 2);
      });

      test('A label the notification no longer offers logs nothing', () async {
        await startRest();
        final rest = gymState.state.currentPage;

        await container
            .read(workoutNotificationControllerProvider)
            .handleAction(
              WORKOUT_NOTIFICATION_ACTION_LOG_SET,
              payloadFor(logSlotKey: slotPage(rest + 1).key),
              '7 × 50 kg',
            );
        await settle();

        verifyNever(logRepo.addLocalDrift(any, dayId: anyNamed('dayId')));
        expect(gymState.state.currentPage, rest);
      });
    });

    test('"+30 s" makes the rest longer and moves the alarm', () async {
      await startRest();
      final rest = gymState.state.currentPage;
      final endsAt = gymState.state.restEndsAt!;
      clearInteractions(service);

      await withClock(Clock.fixed(now), () async {
        await container
            .read(workoutNotificationControllerProvider)
            .handleAction(
              WORKOUT_NOTIFICATION_ACTION_EXTEND_REST,
              payloadFor(restSlotKey: slotPage(rest).key),
            );
        await settle();
      });

      expect(gymState.state.restEndsAt, endsAt.add(REST_EXTENSION));
      final alarms = verify(service.scheduleRestAlarm(captureAny, any)).captured;
      expect((alarms.last as RestAlarm).at, endsAt.add(REST_EXTENSION));
    });

    test('"+30 s" from an earlier rest changes nothing', () async {
      await startRest();
      final endsAt = gymState.state.restEndsAt!;

      await container
          .read(workoutNotificationControllerProvider)
          .handleAction(
            WORKOUT_NOTIFICATION_ACTION_EXTEND_REST,
            payloadFor(restSlotKey: 'another rest'),
          );
      await settle();

      expect(gymState.state.restEndsAt, endsAt);
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
            logSlotKey: slotPage(rest + 1).key,
            workoutStart: DateTime.utc(2020),
          ),
        );
        // For a rest the user already left
        await controller.handleAction(
          WORKOUT_NOTIFICATION_ACTION_SKIP_REST,
          payloadFor(restSlotKey: slotPage(rest - 2).key),
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
}
