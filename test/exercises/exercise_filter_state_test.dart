/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 - 2026 wger Team
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

import 'package:flutter_test/flutter_test.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/providers/exercise_filter_state.dart';

import '../../test_data/exercises.dart';

void main() {
  group('FilterCategory', () {
    test('selected returns only items mapped to true', () {
      final cat = FilterCategory<String>(
        title: 'cats',
        items: {'a': true, 'b': false, 'c': true},
      );

      expect(cat.selected, ['a', 'c']);
    });

    test('selected returns empty list when nothing is marked', () {
      final cat = FilterCategory<String>(
        title: 'cats',
        items: {'a': false, 'b': false},
      );

      expect(cat.selected, isEmpty);
    });

    test('copyWith overrides only the named fields', () {
      final original = FilterCategory<String>(
        title: 'orig',
        items: {'a': true},
      );

      final copy = original.copyWith(title: 'new', isExpanded: true);

      expect(copy.title, 'new');
      expect(copy.isExpanded, true);
      expect(copy.items, {'a': true});
    });
  });

  group('Filters', () {
    test('default constructor produces empty category and equipment lists', () {
      final filters = Filters();

      expect(filters.exerciseCategories.items, isEmpty);
      expect(filters.equipment.items, isEmpty);
      expect(filters.searchTerm, '');
      expect(filters.filterCategories, hasLength(2));
    });

    test('isNothingMarked true when no items are selected', () {
      final filters = Filters(
        exerciseCategories: FilterCategory<ExerciseCategory>(
          title: 'c',
          items: {testCategoryArms: false, testCategoryLegs: false},
        ),
        equipment: FilterCategory<Equipment>(
          title: 'e',
          items: {testEquipmentBench: false},
        ),
      );

      expect(filters.isNothingMarked, isTrue);
    });

    test('isNothingMarked false when at least one category is selected', () {
      final filters = Filters(
        exerciseCategories: FilterCategory<ExerciseCategory>(
          title: 'c',
          items: {testCategoryArms: true, testCategoryLegs: false},
        ),
      );

      expect(filters.isNothingMarked, isFalse);
    });

    test('isNothingMarked false when at least one piece of equipment is selected', () {
      final filters = Filters(
        equipment: FilterCategory<Equipment>(
          title: 'e',
          items: {testEquipmentBench: true},
        ),
      );

      expect(filters.isNothingMarked, isFalse);
    });

    test('copyWith preserves unspecified fields', () {
      final equipment = FilterCategory<Equipment>(
        title: 'e',
        items: {testEquipmentBench: true},
      );
      final original = Filters(equipment: equipment, searchTerm: 'foo');

      final copy = original.copyWith(searchTerm: 'bar');

      expect(copy.searchTerm, 'bar');
      expect(copy.equipment, same(equipment));
    });
  });

  group('ExerciseFilterState', () {
    test('default constructor has empty lists, not loading, fresh Filters', () {
      final state = ExerciseFilterState();

      expect(state.exercises, isEmpty);
      expect(state.filteredExercises, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.filters, isA<Filters>());
    });

    test('copyWith replaces only the named fields', () {
      final state = ExerciseFilterState(isLoading: true);
      final newFilters = Filters(searchTerm: 'updated');

      final copy = state.copyWith(filters: newFilters, isLoading: false);

      expect(copy.filters.searchTerm, 'updated');
      expect(copy.isLoading, isFalse);
      expect(copy.exercises, isEmpty);
    });
  });
}
