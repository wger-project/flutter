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

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:wger/core/widgets/dashboard/calendar.dart';
import 'package:wger/features/account/models/user_profile.dart';
import 'package:wger/features/account/providers/user_profile_notifier.dart';
import 'package:wger/features/measurements/models/measurement_bucket.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/providers/measurement_notifier.dart';
import 'package:wger/features/nutrition/providers/nutrition_notifier.dart';
import 'package:wger/features/routines/models/session.dart';
import 'package:wger/features/routines/providers/routines_notifier.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

import '../../../../test_data/body_weight.dart';
import '../../../../test_data/routines.dart';

/// Feeds a fixed profile into the widget without the repository underneath.
class _StubUserProfileNotifier extends UserProfileNotifier {
  _StubUserProfileNotifier(this._profile);

  final UserProfile _profile;

  @override
  Stream<UserProfile?> build() => Stream.value(_profile);
}

/// Feeds fixed sessions in, which the state derives from its routines.
class _StubRoutinesRiverpod extends RoutinesRiverpod {
  _StubRoutinesRiverpod(this._sessions);

  final List<WorkoutSession> _sessions;

  @override
  Stream<RoutinesState> build() =>
      Stream.value(RoutinesState(routines: [getTestRoutine()..sessions = _sessions]));
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
        routinesRiverpodProvider.overrideWith(() => _StubRoutinesRiverpod(sessions)),
        nutritionProvider.overrideWith(_StubNutritionNotifier.new),
      ],
      child: const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(child: DashboardCalendarWidget()),
        ),
      ),
    );
  }

  /// The day the calendar starts on, which is the one it lists events for
  final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

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
