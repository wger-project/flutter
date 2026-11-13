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

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:wger/features/routines/models/page_progress.dart';
import 'package:wger/features/routines/notifications/workout_live_activity.dart';
import 'package:wger/features/routines/notifications/workout_notification_content.dart';
import 'package:wger/features/routines/providers/gym_state.dart';
import 'package:wger/features/routines/providers/gym_state_notifier.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

import '../../../../test_data/routines.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final now = DateTime.utc(2099, 1, 1, 12);
  final i18n = lookupAppLocalizations(const Locale('en'));
  final labels = WorkoutNotificationLabels.of(i18n);
  late GymStateNotifier notifier;

  setUp(() {
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

  void onPage(SlotPageEntry page, {DateTime? restStartedAt}) {
    notifier.state = notifier.state.copyWith(
      currentPage: page.pageIndex,
      progress: {
        ...notifier.state.progress,
        if (restStartedAt != null) page.key: PageProgress(timerStartedAt: restStartedAt),
      },
    );
  }

  WorkoutNotificationTarget target() => buildWorkoutNotification(
    notifier.state,
    now: now,
    i18n: i18n,
    languageCode: 'en',
    withControls: true,
  );

  Map<String, Object?>? content() =>
      workoutActivityContent(notifier.state, target(), labels: labels, now: now);

  double seconds(DateTime at) => at.millisecondsSinceEpoch / 1000;

  group('Content', () {
    test('None before the workout is started or without a gym state', () {
      expect(notifier.state.currentPage, 0);
      expect(content(), isNull);

      notifier.clear();
      expect(content(), isNull);
    });

    test('Between rests the set and the workout time counting up', () {
      onPage(logs()[0]);

      final shown = content()!;

      expect(shown['title'], 'Bench press');
      expect(shown['body'], 'Set 1 of 3 · 3x100kg');
      expect(shown['resting'], isFalse);
      expect(shown['timerFrom'], seconds(notifier.state.workoutStart));
      expect(shown['workoutStart'], seconds(notifier.state.workoutStart));
      expect(shown['timerTo'], isNull);
      expect(shown['canLog'], isTrue);
      expect(shown['canSkip'], isFalse);
      expect(shown['afterTitle'], isNull);
      expect(shown['logLabel'], labels.logSet);
      expect(
        WorkoutNotificationPayload.decode(shown['payload']! as String)!.logSlotKey,
        logs()[0].key,
      );
    });

    test('A countdown with the next set, and what to show once it is over', () {
      final timer = timers().first;
      onPage(timer, restStartedAt: now);
      final endsAt = notifier.state.restEndsAt!;

      final shown = content()!;

      expect(shown['title'], 'Pause');
      expect(shown['body'], 'Next: Bench press 3x100kg');
      expect(shown['resting'], isTrue);
      expect(shown['timerFrom'], seconds(now));
      expect(shown['timerTo'], seconds(endsAt));
      expect(shown['canSkip'], isTrue);
      expect(shown['canExtend'], isTrue);
      // The widget switches to these once iOS marks the activity stale
      expect(shown['afterTitle'], 'Bench press');
      expect(shown['afterSubtitle'], 'Rest is over');
      expect(shown['afterBody'], 'Set 2 of 3 · 3x100kg');
      expect(shown['afterCanLog'], isTrue);
      expect(shown['afterCanExtend'], isTrue);
      final payload = WorkoutNotificationPayload.decode(shown['payload']! as String)!;
      expect(payload.logSlotKey, logs()[1].key);
      expect(payload.restSlotKey, timer.key);
      expect(payload.matches(notifier.state), isTrue);
    });

    test('A rest that is over shows the set, without a countdown', () {
      onPage(timers().first, restStartedAt: now.subtract(const Duration(minutes: 10)));

      final shown = content()!;

      expect(shown['title'], 'Bench press');
      expect(shown['subtitle'], 'Rest is over');
      expect(shown['resting'], isFalse);
      expect(shown['timerTo'], isNull);
      expect(shown['timerFrom'], seconds(notifier.state.workoutStart));
      expect(shown['canLog'], isTrue);
    });

    test('A rest that counts up shows the time since its start', () {
      final startedAt = now.subtract(const Duration(seconds: 20));
      onPage(timers().last, restStartedAt: startedAt);

      final shown = content()!;

      expect(shown['resting'], isTrue);
      expect(shown['timerFrom'], seconds(startedAt));
      expect(shown['timerTo'], isNull);
      expect(shown['afterTitle'], isNull);
    });
  });

  group('Platform', () {
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    late List<MethodCall> calls;

    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      calls = [];
      messenger.setMockMethodCallHandler(WORKOUT_LIVE_ACTIVITY_CHANNEL, (call) async {
        calls.add(call);
        return null;
      });
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
      messenger.setMockMethodCallHandler(WORKOUT_LIVE_ACTIVITY_CHANNEL, null);
    });

    test('One activity for the workout, updated on changes, ended on leaving', () async {
      final activity = WorkoutLiveActivity();
      void update({bool visible = true}) =>
          activity.update(notifier.state, target(), visible: visible, labels: labels, now: now);

      // Before the start: ends what an earlier process may have left
      update();
      onPage(logs()[0]);
      update();
      update();
      onPage(timers().first, restStartedAt: now);
      update();
      update(visible: false);
      update(visible: false);
      await activity.idle;

      expect(calls.map((c) => c.method), ['end', 'sync', 'sync', 'end']);
      expect((calls[1].arguments as Map)['title'], 'Bench press');
      expect((calls[2].arguments as Map)['timerTo'], isNotNull);

      // Saving the workout clears the gym state, which ends it too
      update();
      notifier.clear();
      update();
      await activity.idle;
      expect(calls.map((c) => c.method).skip(4), ['sync', 'end']);
    });

    test('Not available, e.g. started in the background: the next update tries again', () async {
      var fail = true;
      messenger.setMockMethodCallHandler(WORKOUT_LIVE_ACTIVITY_CHANNEL, (call) async {
        calls.add(call);
        if (fail && call.method == 'sync') {
          throw PlatformException(code: 'ACTIVITY_START_FAILED');
        }
        return null;
      });
      final activity = WorkoutLiveActivity();
      onPage(logs()[0]);

      activity.update(notifier.state, target(), visible: true, labels: labels, now: now);
      await activity.idle;
      fail = false;
      activity.update(notifier.state, target(), visible: true, labels: labels, now: now);
      await activity.idle;

      expect(calls.map((c) => c.method), ['sync', 'sync']);
    });

    test('Buttons arrive as notification actions', () async {
      final received = <List<String>>[];
      WorkoutLiveActivity().listen((action, payload) async => received.add([action, payload]));

      Object? reply = 'none';
      await messenger.handlePlatformMessage(
        WORKOUT_LIVE_ACTIVITY_CHANNEL.name,
        WORKOUT_LIVE_ACTIVITY_CHANNEL.codec.encodeMethodCall(
          const MethodCall('action', {'action': 'skip_rest', 'payload': '{}'}),
        ),
        (data) => reply = WORKOUT_LIVE_ACTIVITY_CHANNEL.codec.decodeEnvelope(data!),
      );

      expect(received, [
        ['skip_rest', '{}'],
      ]);
      // Answered, so iOS can end the background task
      expect(reply, isNull);
      WORKOUT_LIVE_ACTIVITY_CHANNEL.setMethodCallHandler(null);
    });
  });
}
