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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/slot.dart';
import 'package:wger/models/workouts/slot_entry.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/widgets/routines/forms/slot.dart';

import '../../../test_data/routines.dart';
import 'slot_form_test.mocks.dart';

@GenerateMocks([RoutinesRepository])
void main() {
  group('computeSlotGroups', () {
    final routine = getTestRoutine();
    final benchPress = routine.days[0].slots[0].entries[0].exerciseObj;
    final sideRaises = routine.days[0].slots[1].entries[0].exerciseObj;

    SlotEntry makeEntry(int slotId, int exerciseId, {required exerciseObj}) {
      return SlotEntry(
        slotId: slotId,
        type: SlotEntryType.normal,
        order: 1,
        exerciseId: exerciseId,
        repetitionUnitId: 1,
        repetitionRounding: 1,
        weightUnitId: 1,
        weightRounding: 1,
        exercise: exerciseObj,
      );
    }

    Slot makeSlot(int id, int order, SlotEntry entry) {
      final s = Slot.withData(id: id, day: 1, order: order);
      s.entries.add(entry);
      return s;
    }

    test('empty list returns empty map', () {
      final groups = computeSlotGroups([], 'en');
      expect(groups, isEmpty);
    });

    test('single slot is not grouped', () {
      final slots = [makeSlot(1, 1, makeEntry(1, benchPress.id!, exerciseObj: benchPress))];
      final groups = computeSlotGroups(slots, 'en');

      expect(groups[0]!.groupSize, 1);
      expect(groups[0]!.indexInGroup, 0);
      expect(groups[0]!.exerciseName, isNull);
    });

    test('two consecutive same-exercise slots form a group', () {
      final slots = [
        makeSlot(1, 1, makeEntry(1, benchPress.id!, exerciseObj: benchPress)),
        makeSlot(2, 2, makeEntry(2, benchPress.id!, exerciseObj: benchPress)),
      ];
      final groups = computeSlotGroups(slots, 'en');

      expect(groups[0]!.groupSize, 2);
      expect(groups[0]!.indexInGroup, 0);
      expect(groups[0]!.exerciseName, benchPress.getTranslation('en').name);

      expect(groups[1]!.groupSize, 2);
      expect(groups[1]!.indexInGroup, 1);
    });

    test('different exercises are not grouped', () {
      final slots = [
        makeSlot(1, 1, makeEntry(1, benchPress.id!, exerciseObj: benchPress)),
        makeSlot(2, 2, makeEntry(2, sideRaises.id!, exerciseObj: sideRaises)),
      ];
      final groups = computeSlotGroups(slots, 'en');

      expect(groups[0]!.groupSize, 1);
      expect(groups[1]!.groupSize, 1);
    });

    test('only consecutive same-exercise slots are grouped', () {
      // Bench, Bench, Side raises, Bench → group[2], single, single
      final slots = [
        makeSlot(1, 1, makeEntry(1, benchPress.id!, exerciseObj: benchPress)),
        makeSlot(2, 2, makeEntry(2, benchPress.id!, exerciseObj: benchPress)),
        makeSlot(3, 3, makeEntry(3, sideRaises.id!, exerciseObj: sideRaises)),
        makeSlot(4, 4, makeEntry(4, benchPress.id!, exerciseObj: benchPress)),
      ];
      final groups = computeSlotGroups(slots, 'en');

      expect(groups[0]!.groupSize, 2);
      expect(groups[1]!.groupSize, 2);
      expect(groups[2]!.groupSize, 1);
      expect(groups[3]!.groupSize, 1);
    });

    test('superset slots (multiple entries) are never grouped', () {
      final supersetSlot = Slot.withData(id: 1, day: 1, order: 1);
      supersetSlot.entries.add(makeEntry(1, benchPress.id!, exerciseObj: benchPress));
      supersetSlot.entries.add(makeEntry(1, sideRaises.id!, exerciseObj: sideRaises));

      final slots = [
        supersetSlot,
        makeSlot(2, 2, makeEntry(2, benchPress.id!, exerciseObj: benchPress)),
      ];
      final groups = computeSlotGroups(slots, 'en');

      expect(groups[0]!.groupSize, 1);
      expect(groups[1]!.groupSize, 1);
    });
  });

  group('ReorderableSlotList', () {
    late MockRoutinesRepository mockRepo;
    final routine = getTestRoutine();
    final day = routine.days[0]; // has 2 slots: bench press + side raises

    setUp(() {
      mockRepo = MockRoutinesRepository();
      when(mockRepo.deleteSlotServer(any)).thenAnswer((_) async {});
      when(mockRepo.editSlotServer(any)).thenAnswer((_) async {});
      when(
        mockRepo.addSlotServer(any),
      ).thenAnswer((_) async => Slot.withData(id: 99, day: day.id, order: 3));
      when(
        mockRepo.addSlotEntryServer(any),
      ).thenAnswer((_) async => day.slots[0].entries[0]);
      when(mockRepo.fetchAndSetRoutineFullServer(any)).thenAnswer((_) async => routine);
    });

    Widget buildWidget(List<Slot> slots) {
      final container = ProviderContainer.test(
        overrides: [
          routinesRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      container.read(routinesRiverpodProvider.notifier).state = AsyncData(
        RoutinesState(
          routines: [routine],
        ),
      );

      return UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: ReorderableSlotList(slots, day),
            ),
          ),
        ),
      );
    }

    testWidgets('renders "Superset N" for superset slots', (tester) async {
      final supersetSlot = Slot.withData(id: 10, day: day.id, order: 1);
      supersetSlot.entries.add(day.slots[0].entries[0]);
      supersetSlot.addExerciseBase(day.slots[0].entries[0].exerciseObj);
      final entry2 = SlotEntry(
        slotId: 10,
        type: SlotEntryType.normal,
        order: 2,
        exerciseId: day.slots[1].entries[0].exerciseId,
        repetitionUnitId: 1,
        repetitionRounding: 1,
        weightUnitId: 1,
        weightRounding: 1,
        exercise: day.slots[1].entries[0].exerciseObj,
      );
      supersetSlot.entries.add(entry2);
      supersetSlot.addExerciseBase(day.slots[1].entries[0].exerciseObj);

      await tester.pumpWidget(buildWidget([supersetSlot]));
      await tester.pumpAndSettle();

      expect(find.text('Superset 1'), findsOne);
      expect(find.text('Exercise 1'), findsNothing);
    });

    testWidgets('renders "Exercise N" for normal slots', (tester) async {
      await tester.pumpWidget(buildWidget(day.slots));
      await tester.pumpAndSettle();

      expect(find.text('Exercise 1'), findsOne);
      expect(find.text('Exercise 2'), findsOne);
    });

    testWidgets('renders "Set N" instead of "Exercise N" for grouped slots', (tester) async {
      // Two bench press slots in a row → should be grouped
      final benchEntry1 = day.slots[0].entries[0];
      final slot1 = Slot.withData(id: 1, day: day.id, order: 1);
      slot1.entries.add(benchEntry1);
      final slot2 = Slot.withData(id: 2, day: day.id, order: 2);
      slot2.entries.add(benchEntry1);

      await tester.pumpWidget(buildWidget([slot1, slot2]));
      await tester.pumpAndSettle();

      expect(find.text('Set 1'), findsOne);
      expect(find.text('Set 2'), findsOne);
      expect(find.text('Exercise 1'), findsNothing);
    });

    testWidgets('shows exercise name as subtitle for first slot in a group', (tester) async {
      final benchEntry = day.slots[0].entries[0];
      final slot1 = Slot.withData(id: 1, day: day.id, order: 1);
      slot1.entries.add(benchEntry);
      final slot2 = Slot.withData(id: 2, day: day.id, order: 2);
      slot2.entries.add(benchEntry);

      await tester.pumpWidget(buildWidget([slot1, slot2]));
      await tester.pumpAndSettle();

      // Exercise name should appear once (as group subtitle for Set 1)
      expect(find.text(benchEntry.exerciseObj.getTranslation('en').name), findsOne);
    });

    testWidgets('exercise name is only shown for the first slot of a group', (tester) async {
      final benchEntry = day.slots[0].entries[0];
      final exerciseName = benchEntry.exerciseObj.getTranslation('en').name;
      final slot1 = Slot.withData(id: 1, day: day.id, order: 1);
      slot1.entries.add(benchEntry);
      final slot2 = Slot.withData(id: 2, day: day.id, order: 2);
      slot2.entries.add(benchEntry);
      final slot3 = Slot.withData(id: 3, day: day.id, order: 3);
      slot3.entries.add(benchEntry);

      await tester.pumpWidget(buildWidget([slot1, slot2, slot3]));
      await tester.pumpAndSettle();

      // Name appears exactly once (subtitle of Set 1), not on Set 2 or Set 3
      expect(find.text(exerciseName), findsOne);
    });

    testWidgets('shows "Add Set" button for single-entry slot', (tester) async {
      await tester.pumpWidget(buildWidget([day.slots[0]]));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.content_copy), findsOne);
    });

    testWidgets('does not show "Add Set" button for superset slot', (tester) async {
      final supersetSlot = Slot.withData(id: 10, day: day.id, order: 1);
      supersetSlot.entries.add(day.slots[0].entries[0]);
      // Add a second entry to make it a superset
      final entry2 = SlotEntry(
        slotId: 10,
        type: SlotEntryType.normal,
        order: 2,
        exerciseId: day.slots[1].entries[0].exerciseId,
        repetitionUnitId: 1,
        repetitionRounding: 1,
        weightUnitId: 1,
        weightRounding: 1,
        exercise: day.slots[1].entries[0].exerciseObj,
      );
      supersetSlot.entries.add(entry2);

      await tester.pumpWidget(buildWidget([supersetSlot]));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.content_copy), findsNothing);
    });

    testWidgets('tapping "Add Set" calls addSlot and addSlotEntry', (tester) async {
      final slot = day.slots[0];
      await tester.pumpWidget(buildWidget([slot]));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.content_copy));
      await tester.pumpAndSettle();

      verify(
        mockRepo.addSlotServer(
          argThat(
            isA<Slot>().having((s) => s.day, 'day', day.id).having((s) => s.order, 'order', 2),
          ),
        ),
      ).called(1);

      verify(
        mockRepo.addSlotEntryServer(
          argThat(
            isA<SlotEntry>().having(
              (e) => e.exerciseId,
              'exerciseId',
              slot.entries[0].exerciseId,
            ),
          ),
        ),
      ).called(1);
    });

    testWidgets('tapping "Add Set" calls editSlots to shift subsequent slots', (tester) async {
      final benchEntry = day.slots[0].entries[0];
      final slot1 = Slot.withData(id: 1, day: day.id, order: 1);
      slot1.entries.add(benchEntry);
      final slot2 = Slot.withData(id: 2, day: day.id, order: 2);
      slot2.entries.add(day.slots[1].entries[0]); // different exercise, comes after

      await tester.pumpWidget(buildWidget([slot1, slot2]));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.content_copy).first);
      await tester.pumpAndSettle();

      // slot2 must be shifted to order 3 to make room for the new slot at order 2
      verify(
        mockRepo.editSlotServer(
          argThat(isA<Slot>().having((s) => s.order, 'order', 3)),
        ),
      ).called(1);
    });

    testWidgets('"Add Set" button only appears on the last slot of a group', (tester) async {
      final benchEntry = day.slots[0].entries[0];
      final slot1 = Slot.withData(id: 1, day: day.id, order: 1);
      slot1.entries.add(benchEntry);
      final slot2 = Slot.withData(id: 2, day: day.id, order: 2);
      slot2.entries.add(benchEntry);
      final slot3 = Slot.withData(id: 3, day: day.id, order: 3);
      slot3.entries.add(benchEntry);

      await tester.pumpWidget(buildWidget([slot1, slot2, slot3]));
      await tester.pumpAndSettle();

      // Only one copy button for the whole group (on the last slot)
      expect(find.byIcon(Icons.content_copy), findsOne);
    });
  });
}
