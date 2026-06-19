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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/providers/network_provider.dart';
import 'package:wger/providers/routines_notifier.dart';
import 'package:wger/widgets/dashboard/widgets/routines.dart';

import '../../../test_data/routines.dart';

/// Feeds a fixed [RoutinesState] into the widget without touching the repo or
/// the reference-data streams the real notifier builds on.
class _StubRoutinesRiverpod extends RoutinesRiverpod {
  _StubRoutinesRiverpod(this._routines);

  final List<Routine> _routines;

  @override
  Stream<RoutinesState> build() => Stream.value(RoutinesState(routines: _routines));
}

void main() {
  Widget renderWidget({
    required Routine routine,
    bool isOnline = true,
    Override? hydrationOverride,
  }) {
    final container = ProviderContainer.test(
      overrides: [
        networkStatusProvider.overrideWithValue(isOnline),
        routinesRiverpodProvider.overrideWith(() => _StubRoutinesRiverpod([routine])),
        ?hydrationOverride,
      ],
    );

    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(child: DashboardRoutineWidget()),
        ),
      ),
    );
  }

  testWidgets('shows a spinner while the structure is hydrating', (tester) async {
    final routine = getTestRoutine().copyWith(isHydrated: false);

    await tester.pumpWidget(
      renderWidget(
        routine: routine,
        // Never completes, so the hydration stays in the loading state.
        hydrationOverride: routineHydrationProvider(
          routine.id!,
        ).overrideWith((ref) => Completer<void>().future),
      ),
    );
    // Let the stubbed routines stream emit and the widget settle into its data
    // state. No pumpAndSettle: the spinner animates forever.
    await tester.pump();
    await tester.pump();

    expect(find.text('3 day workout'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsWidgets);
    // The detail toggle is replaced by the spinner while loading.
    expect(find.byIcon(Icons.info_outline), findsNothing);
  });

  testWidgets('shows the routine detail (no spinner) once hydrated', (tester) async {
    // getTestRoutine() is already hydrated, so the widget never watches the
    // hydration provider.
    await tester.pumpWidget(renderWidget(routine: getTestRoutine()));
    await tester.pumpAndSettle();

    expect(find.text('3 day workout'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byIcon(Icons.info_outline), findsOneWidget);
  });

  testWidgets('locks the detail offline when the routine was never hydrated', (tester) async {
    final routine = getTestRoutine().copyWith(isHydrated: false);

    await tester.pumpWidget(renderWidget(routine: routine, isOnline: false));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // The "go to detail page" button is disabled while locked.
    final goToDetail = tester.widget<TextButton>(find.byType(TextButton));
    expect(goToDetail.onPressed, isNull);
  });
}
