/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2025 - 2026 wger Team
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

// Core user-journey tests for the redesigned gym-mode log page. These pump a
// single [LogPage] inside a seeded Riverpod container and assert on gym-state
// plus stable widget keys (gym-input-*, gym-log-set-button, gym-set-row-<uuid>)
// rather than on translated copy or field ordering, so cosmetic UI changes do
// not cause false failures.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/user/user_profile.dart';
import 'package:wger/models/workouts/log.dart';
import 'package:wger/providers/gym_state.dart';
import 'package:wger/providers/gym_state_notifier.dart';
import 'package:wger/providers/rest_timer_notifier.dart';
import 'package:wger/providers/user_profile_notifier.dart';
import 'package:wger/providers/workout_logs_notifier.dart';
import 'package:wger/theme/theme.dart';
import 'package:wger/widgets/routines/gym_mode/log_page.dart';

import '../../../../test_data/routines.dart';

/// Captures logged sets instead of writing them to the local drift database.
class _FakeLogMutations implements WorkoutLogMutations {
  final List<Log> added = [];

  @override
  Future<void> addEntry(Log log) async => added.add(log);

  @override
  Future<void> updateEntry(Log log) async {}

  @override
  Future<void> deleteEntry(String id) async {}
}

/// Stubs the user profile so the log page does not reach for the real drift DB
/// when picking the default weight unit.
class _FakeUserProfileNotifier extends UserProfileNotifier {
  @override
  Stream<UserProfile?> build() => Stream<UserProfile?>.value(null);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LogPage core journeys', () {
    late ProviderContainer container;
    late _FakeLogMutations fakeLogs;

    setUp(() {
      SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
      fakeLogs = _FakeLogMutations();
      container = ProviderContainer.test(
        overrides: [
          workoutLogProvider.overrideWithValue(fakeLogs),
          userProfileProvider.overrideWith(_FakeUserProfileNotifier.new),
        ],
      );

      final routine = getTestRoutine();
      final notifier = container.read(gymStateProvider.notifier);
      notifier.state = notifier.state.copyWith(
        dayId: 1,
        iteration: 1,
        routine: routine,
      );
      notifier.calculatePages();
    });

    /// The first exercise's set page (Bench press in the test routine).
    PageEntry firstSetPage() =>
        container.read(gymStateProvider).pages.firstWhere((p) => p.type == PageType.set);

    List<SlotPageEntry> logSlots(PageEntry page) =>
        page.slotPages.where((sp) => sp.type == SlotPageType.log).toList();

    /// Re-reads [page] from the (immutable) state after a mutation.
    PageEntry reread(PageEntry page) =>
        container.read(gymStateProvider).pages.firstWhere((p) => p.uuid == page.uuid);

    Future<void> pumpLogPage(WidgetTester tester) async {
      final pageEntry = firstSetPage();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            locale: const Locale('en'),
            theme: wgerLightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  final controller = PageController();
                  return PageView(
                    controller: controller,
                    children: [LogPage(controller, pageEntry: pageEntry)],
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('renders the log page with the exercise name (FR3)', (tester) async {
      await pumpLogPage(tester);

      expect(find.byType(LogPage), findsOneWidget);
      // The active exercise is named in the hero/header at all times.
      expect(find.text('Bench press'), findsWidgets);
    });

    testWidgets('inputs are pre-filled from the routine target (FR1e)', (tester) async {
      await pumpLogPage(tester);

      // The first pending set seeds its inputs from the configured target
      // (Bench press: 10 × 10 kg) so the user only adjusts, never types blind.
      final weight = tester.widget<TextField>(find.byKey(const ValueKey('gym-input-weight')));
      final reps = tester.widget<TextField>(find.byKey(const ValueKey('gym-input-reps')));
      expect(weight.controller!.text, '100');
      expect(reps.controller!.text, '3');
    });

    testWidgets(
      'hero shows the exercise prescription + note even when the active set is a '
      'warm-up that carries none (regression)',
      (tester) async {
        // Mirror the real data shape: a warm-up first (active) set with no target
        // text or note, while the prescription + note live on the working set.
        final slots = logSlots(firstSetPage());
        expect(slots.length, greaterThanOrEqualTo(2));
        slots.first.setConfigData!
          ..textRepr = ''
          ..comment = '';
        slots[1].setConfigData!
          ..textRepr = '5 Reps @ 1 RiR 180s rest'
          ..comment = 'Sub: Machine Chest Press';

        await pumpLogPage(tester);

        // The warm-up is active, but the hero must fall back to the working set
        // so neither the target pill nor the note disappears.
        expect(find.text('5 Reps @ 1 RiR 180s rest'), findsOneWidget);
        expect(find.text('Sub: Machine Chest Press'), findsOneWidget);
      },
    );

    testWidgets('logging a set persists it and marks the set done (FR1a)', (tester) async {
      final firstLogUuid = logSlots(firstSetPage()).first.uuid;
      await pumpLogPage(tester);

      await tester.enterText(find.byKey(const ValueKey('gym-input-weight')), '52.5');
      await tester.enterText(find.byKey(const ValueKey('gym-input-reps')), '8');
      await tester.tap(find.byKey(const ValueKey('gym-log-set-button')));
      await tester.pumpAndSettle();

      expect(fakeLogs.added, hasLength(1));
      expect(fakeLogs.added.single.weight, 52.5);
      expect(fakeLogs.added.single.repetitions, 8);

      final slot = reread(firstSetPage()).slotPages.firstWhere((sp) => sp.uuid == firstLogUuid);
      expect(slot.logDone, isTrue);

      // Logging starts the (keep-alive) rest timer; stop it so no periodic timer
      // outlives the test.
      container.read(restTimerProvider.notifier).cancel();
    });

    testWidgets('logging with a blank RiR is allowed (FR2b)', (tester) async {
      final firstLogUuid = logSlots(firstSetPage()).first.uuid;
      await pumpLogPage(tester);

      // The Bench press config has a RiR, so the field is present; clearing it
      // must not block submission.
      expect(find.byKey(const ValueKey('gym-input-rir')), findsOneWidget);
      await tester.enterText(find.byKey(const ValueKey('gym-input-rir')), '');
      await tester.tap(find.byKey(const ValueKey('gym-log-set-button')));
      await tester.pumpAndSettle();

      expect(fakeLogs.added, hasLength(1));
      expect(fakeLogs.added.single.rir, isNull);
      final slot = reread(firstSetPage()).slotPages.firstWhere((sp) => sp.uuid == firstLogUuid);
      expect(slot.logDone, isTrue);

      container.read(restTimerProvider.notifier).cancel();
    });

    testWidgets('adding a set shows a new set row (FR6a)', (tester) async {
      await pumpLogPage(tester);

      final page = firstSetPage();
      final before = logSlots(page).length;

      container.read(gymStateProvider.notifier).addSetToPage(page.uuid);
      await tester.pumpAndSettle();

      final after = logSlots(reread(page));
      expect(after, hasLength(before + 1));
      expect(find.byKey(ValueKey('gym-set-row-${after.last.uuid}')), findsOneWidget);
    });

    testWidgets('removing a set drops its row (FR6b)', (tester) async {
      await pumpLogPage(tester);

      final page = firstSetPage();
      final slots = logSlots(page);
      final removed = slots.last;
      expect(find.byKey(ValueKey('gym-set-row-${removed.uuid}')), findsOneWidget);

      container.read(gymStateProvider.notifier).removeSetFromPage(page.uuid, removed.uuid);
      await tester.pumpAndSettle();

      expect(logSlots(reread(page)), hasLength(slots.length - 1));
      expect(find.byKey(ValueKey('gym-set-row-${removed.uuid}')), findsNothing);
    });

    // Regression for the "hydration" bug (TODO.md): finishing the last set of an
    // exercise auto-advances to the next page, which disposes the LogPage's State
    // (PageView does not keep it alive). Jumping back rebuilds the State from
    // scratch; adding a set then has to re-seed the new slot from the rebuilt
    // page. The exercise config (name/target/comment) must survive that round
    // trip rather than coming back empty.
    testWidgets('adding a set after finishing the exercise survives a jump-away/back', (
      tester,
    ) async {
      // The two set pages share one controller, exactly like the real PageView in
      // gym_mode.dart. A small cacheExtent guarantees the first page's State is
      // disposed once we advance past it.
      final setPages = container
          .read(gymStateProvider)
          .pages
          .where((p) => p.type == PageType.set)
          .toList();

      // Give the first exercise's sets a comment so we can assert the hero note
      // survives the round trip (the test routine ships empty comments).
      for (final sp in setPages.first.slotPages) {
        sp.setConfigData?.comment = 'Keep your back straight';
      }

      final controller = PageController();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            locale: const Locale('en'),
            theme: wgerLightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: PageView(
                controller: controller,
                children: [
                  for (final p in setPages) LogPage(controller, pageEntry: p),
                  const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final page = setPages.first;

      // Finish every set of the first exercise through the UI. Logging the last
      // one auto-advances to the next page, disposing this LogPage's State.
      for (var i = 0; i < logSlots(page).length; i++) {
        await tester.tap(find.byKey(const ValueKey('gym-log-set-button')));
        await tester.pumpAndSettle();
      }
      expect(reread(page).allLogsDone, isTrue);

      // Jump back to the (now finished) first exercise: rebuilds the State.
      controller.jumpToPage(0);
      await tester.pumpAndSettle();

      // Add another set, as the user would to log an extra one.
      await tester.tap(find.byKey(const ValueKey('gym-add-set-button')));
      await tester.pumpAndSettle();

      final added = logSlots(reread(page)).last;
      // The new set must carry the exercise's config, not a null/empty one.
      expect(added.setConfigData, isNotNull);
      expect(added.setConfigData!.exercise.id, 1); // Bench press
      expect(added.setConfigData!.textRepr, '3x100kg');

      // The hero still names the exercise, shows the target prescription pill
      // and the note, and the input panel pre-fills from the carried-over config.
      expect(find.text('Bench press'), findsWidgets);
      expect(find.text('3x100kg'), findsOneWidget);
      expect(find.text('Keep your back straight'), findsOneWidget);
      final weight = tester.widget<TextField>(find.byKey(const ValueKey('gym-input-weight')));
      expect(weight.controller!.text, '100');

      container.read(restTimerProvider.notifier).cancel();
    });
  });
}
