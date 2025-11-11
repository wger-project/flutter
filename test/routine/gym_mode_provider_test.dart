/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020, 2025 wger Team
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
import 'package:wger/models/workouts/day_data.dart';
import 'package:wger/providers/gym_state.dart';

import '../../test_data/routines.dart';

void main() {
  group('GymStateNotifier.calculatePages', () {
    late GymStateNotifier notifier;
    late ProviderContainer container;
    late DayData day;

    setUp(() {
      container = ProviderContainer.test();
      notifier = container.read(gymStateProvider.notifier);
      day = getTestRoutine().dayData.first;
    });

    test(
      'Correctly generates pages: exercise and timer',
      () {
        // Arrange
        notifier.state = notifier.state.copyWith(showExercisePages: true, showTimerPages: true);

        // Act
        notifier.calculatePages(day);

        // Assert
        final pages = notifier.state.pages;
        expect(pages.length, 4, reason: '4 PageEntries (start, set 1, set 2, session)');

        final setEntry = pages.firstWhere((p) => p.type == PageType.set);
        expect(setEntry.slotPages.length, 3, reason: 'Three sets for the exercise');

        expect(setEntry.slotPages[0].type, SlotPageType.exerciseOverview);
        expect(setEntry.slotPages[1].type, SlotPageType.timer);
        expect(setEntry.slotPages[2].type, SlotPageType.log);

        expect(notifier.state.totalPages, 7);
      },
    );

    test('Correctly generates pages: no exercises and no timer', () {
      // Arrange
      notifier.state = notifier.state.copyWith(showExercisePages: false, showTimerPages: false);

      // Act
      notifier.calculatePages(day);

      // Assert
      final pages = notifier.state.pages;
      expect(pages.length, 4, reason: '4 PageEntries (start, set 1, set 2, session)');

      final setEntry = pages.firstWhere((p) => p.type == PageType.set);
      expect(setEntry.slotPages.length, 1);
      expect(setEntry.slotPages[0].type, SlotPageType.log);
      expect(notifier.state.totalPages, 3);
    });

    test('Correctly generates pages: exercises and no timer', () {
      // Arrange
      notifier.state = notifier.state.copyWith(showExercisePages: true, showTimerPages: false);

      // Act
      notifier.calculatePages(day);

      // Assert
      final pages = notifier.state.pages;
      expect(pages.length, 4, reason: '4 PageEntries (start, set 1, set 2, session)');

      final setEntry = pages.firstWhere((p) => p.type == PageType.set);
      expect(setEntry.slotPages.length, 2);
      expect(setEntry.slotPages[0].type, SlotPageType.exerciseOverview);
      expect(setEntry.slotPages[1].type, SlotPageType.log);
      expect(notifier.state.totalPages, 5);
    });
  });
}
