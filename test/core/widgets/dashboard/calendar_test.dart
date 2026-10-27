/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 wger Team
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

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:wger/core/widgets/dashboard/calendar.dart';
import 'package:wger/core/widgets/error.dart';
import 'package:wger/core/widgets/progress_indicator.dart';
import 'package:wger/features/account/models/user_profile.dart';
import 'package:wger/features/account/providers/user_profile_notifier.dart';
import 'package:wger/features/measurements/models/measurement_bucket.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/providers/measurement_notifier.dart';
import 'package:wger/features/nutrition/providers/nutrition_notifier.dart';
import 'package:wger/features/routines/models/session.dart';
import 'package:wger/features/routines/providers/routines_notifier.dart';
import 'package:wger/features/routines/providers/workout_session_notifier.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/l10n/localizations_delegates.dart';

import '../../../../test_data/body_weight.dart';
import '../../../../test_data/routines.dart';

/// Feeds a fixed profile into the widget without the repository underneath.
class _StubUserProfileNotifier extends UserProfileNotifier {
  _StubUserProfileNotifier(this._profile);

  final UserProfile _profile;

  @override
  Stream<UserProfile?> build() => Stream.value(_profile);
}

/// Mirrors routine hydration: only sessions linked to a routine are attached.
class _StubRoutinesRiverpod extends RoutinesRiverpod {
  _StubRoutinesRiverpod(this._sessions, this._hasRoutines);

  final List<WorkoutSession> _sessions;
  final bool _hasRoutines;

  @override
  Stream<RoutinesState> build() {
    final routine = getTestRoutine();
    routine.sessions = _sessions.where((session) => session.routineId == routine.id).toList();
    return Stream.value(RoutinesState(routines: _hasRoutines ? [routine] : []));
  }
}

class _StubNutritionNotifier extends NutritionNotifier {
  @override
  Stream<NutritionState> build() => Stream.value(const NutritionState());
}

void main() {
  setUpAll(tzdata.initializeTimeZones);

  final bodyWeight = getBodyWeightCategory();

  /// One daily bucket, i.e. what the calendar reads for a day that was measured
  MeasurementBucket bucket(
    DateTime day,
    num sum, {
    int count = 1,
    String? unit,
  }) => MeasurementBucket(
    start: day,
    unit: unit,
    count: count,
    sum: sum,
    min: sum / count,
    max: sum / count,
  );

  Widget renderWidget({
    required Map<String, List<MeasurementBucket>> dailyBuckets,
    List<MeasurementCategory> categories = const [],
    List<WorkoutSession> sessions = const [],
    Stream<List<WorkoutSession>>? sessionStream,
    bool hasRoutines = true,
    bool isMetric = true,
    String? timeZone,
  }) {
    return ProviderScope(
      overrides: [
        userProfileProvider.overrideWith(
          () => _StubUserProfileNotifier(
            UserProfile(id: 1, weightUnitStr: isMetric ? 'kg' : 'lb', timeZone: timeZone),
          ),
        ),
        measurementCategoriesProvider.overrideWith((ref) => Stream.value(categories)),
        measurementDailyBucketsProvider.overrideWith((ref) => Stream.value(dailyBuckets)),
        routinesRiverpodProvider.overrideWith(() => _StubRoutinesRiverpod(sessions, hasRoutines)),
        workoutSessionProvider.overrideWithBuild(
          (ref, notifier) => sessionStream ?? Stream.value(sessions),
        ),
        nutritionProvider.overrideWith(_StubNutritionNotifier.new),
      ],
      child: const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(child: DashboardCalendarWidget()),
        ),
      ),
    );
  }

  /// The day the calendar starts on, which is the one it lists events for
  final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  testWidgets('sessions without a routine appear alongside linked sessions exactly once', (
    tester,
  ) async {
    await tester.pumpWidget(
      renderWidget(
        dailyBuckets: const {},
        sessions: [
          WorkoutSession(
            id: 'standalone-session',
            routineId: null,
            datetimeStart: today.add(const Duration(hours: 9)),
            impression: WorkoutImpression.good,
          ),
          WorkoutSession(
            id: 'linked-session',
            routineId: getTestRoutine().id,
            datetimeStart: today.add(const Duration(hours: 10)),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Workout session'), findsNWidgets(2));
    expect(find.textContaining('Impression: Good'), findsOneWidget);
    expect(find.textContaining('Impression: Neutral'), findsOneWidget);
  });

  for (final routineId in <int?>[null, 99]) {
    testWidgets('sessions remain visible with no routines (routine: $routineId)', (tester) async {
      await tester.pumpWidget(
        renderWidget(
          dailyBuckets: const {},
          hasRoutines: false,
          sessions: [
            WorkoutSession(
              routineId: routineId,
              datetimeStart: today.add(const Duration(hours: 9)),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Workout session'), findsOneWidget);
    });
  }

  testWidgets('the calendar updates when a session loses its routine', (tester) async {
    final controller = StreamController<List<WorkoutSession>>();
    addTearDown(() => unawaited(controller.close()));
    final session = WorkoutSession(
      id: 'preserved-session',
      routineId: getTestRoutine().id,
      datetimeStart: today.add(const Duration(hours: 9)),
    );

    await tester.pumpWidget(
      renderWidget(dailyBuckets: const {}, sessions: [session], sessionStream: controller.stream),
    );
    controller.add([session]);
    await tester.pumpAndSettle();
    expect(find.text('Workout session'), findsOneWidget);

    controller.add([session.copyWith(routineId: null, impression: WorkoutImpression.good)]);
    await tester.pumpAndSettle();

    expect(find.text('Workout session'), findsOneWidget);
    expect(find.textContaining('Impression: Good'), findsOneWidget);
    expect(find.textContaining('Impression: Neutral'), findsNothing);
  });

  testWidgets('waits for the session stream before showing the calendar', (tester) async {
    final controller = StreamController<List<WorkoutSession>>();
    addTearDown(() => unawaited(controller.close()));

    await tester.pumpWidget(
      renderWidget(dailyBuckets: const {}, sessionStream: controller.stream),
    );
    await tester.pump();

    expect(find.byType(BoxedProgressIndicator), findsOneWidget);

    controller.add([]);
    await tester.pumpAndSettle();

    expect(find.byType(BoxedProgressIndicator), findsNothing);
    expect(find.text('Workout session'), findsNothing);
  });

  testWidgets('shows an error when the session stream fails', (tester) async {
    await tester.pumpWidget(
      renderWidget(
        dailyBuckets: const {},
        sessionStream: Stream.error(StateError('Workout history unavailable')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(StreamErrorIndicator), findsOneWidget);
    expect(find.textContaining('Workout history unavailable'), findsOneWidget);
    expect(find.byType(BoxedProgressIndicator), findsNothing);
  });

  testWidgets('a day of readings is one event, not one per reading', (tester) async {
    await tester.pumpWidget(
      renderWidget(
        categories: [bodyWeight],
        dailyBuckets: {
          bodyWeight.id!: [bucket(today, 240, count: 3)],
        },
      ),
    );
    await tester.pumpAndSettle();

    // Three weigh-ins averaging 80 kg, shown as the day's one value
    expect(find.text('80 kg'), findsOneWidget);
  });

  testWidgets('body weight is shown in the unit of the profile', (tester) async {
    await tester.pumpWidget(
      renderWidget(
        categories: [bodyWeight],
        dailyBuckets: {
          bodyWeight.id!: [bucket(today, 80)],
        },
        isMetric: false,
      ),
    );
    await tester.pumpAndSettle();

    // 80 kg are 176.37 lb; the value is stored in kg and converted for the card
    expect(find.text('176.37 lb'), findsOneWidget);
  });

  testWidgets('another measurement is named and shown in its category unit', (tester) async {
    final biceps = MeasurementCategory(id: 'biceps', name: 'Biceps', unit: 'cm');

    await tester.pumpWidget(
      renderWidget(
        categories: [biceps],
        dailyBuckets: {
          biceps.id!: [bucket(today, 38.5)],
        },
        // The profile unit governs body weight only
        isMetric: false,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Biceps: 38.5 cm'), findsOneWidget);
  });

  // The instant is midnight of the day the calendar opens on. Far enough east
  // it is that day, far enough west it is still the one before, and neither
  // depends on the zone the test machine runs in
  WorkoutSession sessionAtMidnight() => WorkoutSession(routineId: 1, datetimeStart: today.toUtc());

  testWidgets('a session counts towards the day it is on in the owner zone', (tester) async {
    await tester.pumpWidget(
      renderWidget(
        dailyBuckets: const {},
        sessions: [sessionAtMidnight()],
        timeZone: 'Pacific/Kiritimati',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Impression'), findsOneWidget);
  });

  testWidgets('the same session is the day before in a zone far enough west', (tester) async {
    await tester.pumpWidget(
      renderWidget(
        dailyBuckets: const {},
        sessions: [sessionAtMidnight()],
        timeZone: 'Pacific/Midway',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Impression'), findsNothing);
  });

  testWidgets('a profile without a zone falls back to the device day', (tester) async {
    final session = WorkoutSession(
      routineId: 1,
      datetimeStart: today.add(const Duration(hours: 12)),
    );

    await tester.pumpWidget(
      renderWidget(dailyBuckets: const {}, sessions: [session]),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Impression'), findsOneWidget);
  });
}
