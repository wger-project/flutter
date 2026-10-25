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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:wger/core/consts.dart';
import 'package:wger/features/exercises/models/image.dart';
import 'package:wger/features/routines/models/log.dart';
import 'package:wger/features/routines/notifications/workout_notification_content.dart';
import 'package:wger/features/routines/providers/gym_state.dart';
import 'package:wger/features/routines/providers/gym_state_notifier.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

import '../../../../test_data/routines.dart';

void main() {
  final now = DateTime.utc(2025, 3, 29, 14, 33);
  final i18n = lookupAppLocalizations(const Locale('en'));
  late GymStateNotifier notifier;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
    final container = ProviderContainer.test();
    notifier = container.read(gymStateProvider.notifier);
    final routine = getTestRoutine();
    notifier.initData(routine, routine.days.first.id!, 1);
  });

  // Fixture: start, then bench press (overview, 3x log/timer, 120 s rest),
  // then side raises (overview, 3x log/timer, no rest time), session, summary
  List<SlotPageEntry> slotPages() => notifier.state.pages.expand((p) => p.slotPages).toList();
  List<SlotPageEntry> logs() => slotPages().where((p) => p.type == SlotPageType.log).toList();
  List<SlotPageEntry> timers() => slotPages().where((p) => p.type == SlotPageType.timer).toList();

  WorkoutNotificationTarget build({
    bool withControls = true,
    List<Log> recentLogs = const [],
    Uri? Function(String? path)? mediaUrl,
  }) => buildWorkoutNotification(
    notifier.state,
    now: now,
    i18n: i18n,
    languageCode: 'en',
    withControls: withControls,
    recentLogs: recentLogs,
    mediaUrl: mediaUrl,
  );

  void onPage(SlotPageEntry page, {DateTime? restStartedAt, DateTime? restEndsAt}) {
    notifier.state = notifier.state.copyWith(
      currentPage: page.pageIndex,
      clearRest: true,
      restStartedAt: restStartedAt,
      restEndsAt: restEndsAt,
    );
  }

  test('Nothing without an initialized gym state', () {
    notifier.clear();

    expect(build(), WorkoutNotificationTarget.none);
  });

  group('Rest', () {
    test('A running countdown gets an alarm at its end and counting down controls', () {
      final endsAt = now.add(const Duration(seconds: 90));
      final timer = timers().first;
      onPage(timer, restStartedAt: now, restEndsAt: endsAt);

      final target = build();

      expect(target.alarm!.at, endsAt);
      expect(target.alarm!.title, 'Rest is over');
      expect(target.alarm!.body, 'Next: Bench press 3x100kg');
      expect(target.alarm!.canLogSet, isTrue);
      expect(target.alarm!.payload.logSlotUuid, logs()[1].uuid);
      expect(target.controls!.chronometerAt, endsAt);
      expect(target.controls!.chronometerCountsDown, isTrue);
      expect(target.controls!.canSkipRest, isTrue);
      expect(target.controls!.payload.restSlotUuid, timer.uuid);
    });

    test('No alarm when the setting is off', () {
      notifier.state = notifier.state.copyWith(alertOnCountdownEnd: false);
      onPage(timers().first, restStartedAt: now, restEndsAt: now.add(const Duration(seconds: 90)));

      final target = build();

      expect(target.alarm, isNull);
      expect(target.controls, isNotNull);
    });

    test('A rest that is already over has no alarm and no chronometer', () {
      onPage(
        timers().first,
        restStartedAt: now.subtract(const Duration(seconds: 150)),
        restEndsAt: now.subtract(const Duration(seconds: 30)),
      );

      final target = build();

      expect(target.alarm, isNull);
      expect(target.controls!.title, 'Rest is over');
      expect(target.controls!.chronometerAt, isNull);
    });

    test('A rest that counts up shows the time since its start', () {
      final startedAt = now.subtract(const Duration(seconds: 20));
      onPage(timers().last, restStartedAt: startedAt);

      final target = build();

      expect(target.alarm, isNull);
      expect(target.controls!.title, 'Pause');
      expect(target.controls!.chronometerAt, startedAt);
      expect(target.controls!.chronometerCountsDown, isFalse);
    });

    test('The last rest of an exercise names the next one but cannot log it', () {
      // The overview page of the next exercise comes in between
      onPage(timers()[2], restStartedAt: now, restEndsAt: now.add(const Duration(seconds: 90)));

      final target = build();

      expect(target.alarm!.body, 'Next: Side raises 12x10kg');
      expect(target.alarm!.canLogSet, isFalse);
      expect(target.controls!.canLogSet, isFalse);
    });

    test('A next set without planned values cannot be logged', () {
      logs()[1].setConfigData!
        ..repetitions = null
        ..weight = null;
      onPage(timers().first, restStartedAt: now, restEndsAt: now.add(const Duration(seconds: 90)));

      expect(build().alarm!.canLogSet, isFalse);
    });

    test('Without controls only the alarm remains', () {
      onPage(timers().first, restStartedAt: now, restEndsAt: now.add(const Duration(seconds: 90)));

      final target = build(withControls: false);

      expect(target.alarm, isNotNull);
      expect(target.controls, isNull);
    });
  });

  group('Other pages', () {
    test('A set page shows the exercise and the set number', () {
      onPage(logs()[1]);

      final controls = build().controls!;

      expect(controls.title, 'Bench press');
      expect(controls.body, 'Set 2 of 3 · 3x100kg');
      expect(controls.canLogSet, isTrue);
      expect(controls.canSkipRest, isFalse);
      expect(controls.payload.logSlotUuid, logs()[1].uuid);
    });

    test('A logged set cannot be logged again', () {
      notifier.markSlotPageAsDone(logs()[1].uuid, isDone: true);
      onPage(logs()[1]);

      expect(build().controls!.canLogSet, isFalse);
    });

    test('Any other page shows the workout in progress', () {
      notifier.state = notifier.state.copyWith(currentPage: 0);

      final target = build();

      expect(target.alarm, isNull);
      expect(target.controls!.title, 'Workout in progress');
      expect(target.controls!.chronometerAt, notifier.state.workoutStart);
      expect(target.controls!.canLogSet, isFalse);
    });

    test('"+30 s" only for a countdown, also once it is over', () {
      final timer = timers().first;
      onPage(timer, restStartedAt: now, restEndsAt: now.add(const Duration(seconds: 90)));
      expect(build().controls!.canExtendRest, isTrue);
      expect(build().alarm!.canExtendRest, isTrue);

      onPage(timer, restStartedAt: now, restEndsAt: now.subtract(const Duration(seconds: 1)));
      expect(build().controls!.canExtendRest, isTrue);

      onPage(timer, restStartedAt: now);
      expect(build().controls!.canExtendRest, isFalse);

      onPage(logs()[1]);
      expect(build().controls!.canExtendRest, isFalse);
    });

    test('Without controls there is nothing outside a rest', () {
      onPage(logs()[1]);

      expect(build(withControls: false), WorkoutNotificationTarget.none);
    });
  });

  group('Quick logs', () {
    Log logOf({
      required num repetitions,
      num? weight,
      num? rir,
      int repetitionsUnitId = REP_UNIT_REPETITIONS_ID,
      int? exerciseId,
    }) {
      final planned = logs()[1].setConfigData!;
      final log = Log(
        exerciseId: exerciseId ?? planned.exerciseId,
        repetitions: repetitions,
        repetitionsUnitId: repetitionsUnitId,
        weight: weight,
        rir: rir,
      );
      log.weightUnit = testWeightUnit1;
      return log;
    }

    test('Newest first, one per label, without the planned values', () {
      final planned = logs()[1].setConfigData!;
      final recent = [
        logOf(repetitions: 9, weight: 60),
        logOf(repetitions: planned.repetitions!, weight: planned.weight),
        logOf(repetitions: 9, weight: 60),
        logOf(repetitions: 8, weight: 62.5, rir: 2),
        logOf(repetitions: 12),
        logOf(repetitions: 6, weight: 70),
      ];

      final choices = quickLogChoices(planned, recent);

      expect(choices.keys, ['9 × 60 kg', '8 × 62.5 kg (2 RiR)', '12']);
      expect(choices['9 × 60 kg'], same(recent[0]));
    });

    test('Skips other exercises and units the label cannot name', () {
      final planned = logs()[1].setConfigData!;

      final choices = quickLogChoices(planned, [
        logOf(repetitions: 9, weight: 60, exerciseId: planned.exerciseId + 1),
        logOf(repetitions: 30, repetitionsUnitId: testRepetitionUnit2.id),
      ]);

      expect(choices, isEmpty);
    });

    test('The rest before a set and the set page offer them with "log set"', () {
      final recent = [logOf(repetitions: 9, weight: 60)];
      final endsAt = now.add(const Duration(seconds: 90));
      onPage(timers().first, restStartedAt: now, restEndsAt: endsAt);

      var target = build(recentLogs: recent);
      expect(target.controls!.quickLogs, ['9 × 60 kg']);
      expect(target.alarm!.quickLogs, ['9 × 60 kg']);

      onPage(logs()[1]);
      target = build(recentLogs: recent);
      expect(target.controls!.quickLogs, ['9 × 60 kg']);

      notifier.markSlotPageAsDone(logs()[1].uuid, isDone: true);
      expect(build(recentLogs: recent).controls!.quickLogs, isEmpty);
    });

    test("The notification shows the main image of the set's exercise", () {
      final config = logs()[1].setConfigData!;
      config.exercise = config.exercise.copyWith(
        images: [
          ExerciseImage(
            id: 1,
            uuid: 'image',
            exerciseId: config.exerciseId,
            image: '/media/bench.png',
            isMain: true,
            isAiGenerated: false,
            style: ExerciseImageStyle.photo,
            width: null,
            height: null,
            created: now,
            lastUpdate: now,
            licenseId: 1,
            licenseTitle: '',
            licenseObjectUrl: '',
            licenseAuthor: null,
            licenseAuthorUrl: '',
            licenseDerivativeSourceUrl: '',
          ),
        ],
      );
      Uri? mediaUrl(String? path) => path == null ? null : Uri.parse('https://wger.test$path');
      onPage(timers().first, restStartedAt: now, restEndsAt: now.add(const Duration(seconds: 90)));

      final target = build(mediaUrl: mediaUrl);

      expect(target.controls!.image, Uri.parse('https://wger.test/media/bench.png'));
      expect(target.alarm!.image, Uri.parse('https://wger.test/media/bench.png'));
    });
  });

  group('WorkoutNotificationPayload', () {
    test('Survives the round trip as a string', () {
      final payload = WorkoutNotificationPayload(
        routineId: 1,
        dayId: 2,
        iteration: 3,
        workoutStart: DateTime.utc(2025, 3, 29, 14, 33),
        logSlotUuid: 'log',
        restSlotUuid: 'rest',
      );

      expect(WorkoutNotificationPayload.decode(payload.encode()), payload);
    });

    test('Foreign or missing payloads decode to null', () {
      expect(WorkoutNotificationPayload.decode(null), isNull);
      expect(WorkoutNotificationPayload.decode('not json'), isNull);
      expect(WorkoutNotificationPayload.decode('{"other": 1}'), isNull);
    });
  });
}
