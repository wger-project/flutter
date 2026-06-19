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
import 'package:wger/providers/add_exercise_state.dart';

import '../../test_data/exercises.dart';

void main() {
  group('AddExerciseState defaults', () {
    test('starts with empty author, no language, no category', () {
      const state = AddExerciseState();

      expect(state.author, '');
      expect(state.languageEn, isNull);
      expect(state.languageTranslation, isNull);
      expect(state.category, isNull);
      expect(state.equipment, isEmpty);
      expect(state.primaryMuscles, isEmpty);
      expect(state.secondaryMuscles, isEmpty);
      expect(state.alternateNamesEn, isEmpty);
      expect(state.alternateNamesTrans, isEmpty);
      expect(state.exerciseImages, isEmpty);
    });

    test('newVariation reflects whether variationConnectToExercise is set', () {
      const noVariation = AddExerciseState();
      const withVariation = AddExerciseState(variationConnectToExercise: 42);

      expect(noVariation.newVariation, isFalse);
      expect(withVariation.newVariation, isTrue);
    });
  });

  group('exerciseApiObject, English-only submission', () {
    const state = AddExerciseState(
      author: 'Alice',
      exerciseNameEn: 'Bench Press',
      descriptionEn: 'Lie down and press.',
      languageEn: testEnglish,
      category: testCategoryArms,
      equipment: [testEquipmentBench],
      primaryMuscles: [tMuscle1],
      secondaryMuscles: [tMuscle2],
      alternateNamesEn: ['Chest Press', '', 'Flat Bench'],
    );

    test('maps category, muscles, and equipment to their ids', () {
      final api = state.exerciseApiObject;

      expect(api.author, 'Alice');
      expect(api.category, testCategoryArms.id);
      expect(api.muscles, [tMuscle1.id]);
      expect(api.musclesSecondary, [tMuscle2.id]);
      expect(api.equipment, [testEquipmentBench.id]);
    });

    test('emits exactly one translation when no translation language is set', () {
      final api = state.exerciseApiObject;

      expect(api.translations, hasLength(1));
      expect(api.translations.first.language, testEnglish.id);
      expect(api.translations.first.name, 'Bench Press');
    });

    test('drops empty alternate names from aliases', () {
      final api = state.exerciseApiObject;

      final aliases = api.translations.first.aliases.map((a) => a.alias).toList();
      expect(aliases, ['Chest Press', 'Flat Bench']);
    });
  });

  group('exerciseApiObject, with translation', () {
    const state = AddExerciseState(
      author: 'Alice',
      exerciseNameEn: 'Bench Press',
      descriptionEn: 'Lie down and press.',
      languageEn: testEnglish,
      exerciseNameTrans: 'Bankdrücken',
      descriptionTrans: 'Hinlegen und drücken.',
      languageTranslation: testGerman,
      alternateNamesTrans: ['Flachbankdrücken'],
      category: testCategoryArms,
      primaryMuscles: [tMuscle1],
    );

    test('emits two translations when a translation language is set', () {
      final api = state.exerciseApiObject;

      expect(api.translations, hasLength(2));
      expect(api.translations[0].language, testEnglish.id);
      expect(api.translations[1].language, testGerman.id);
      expect(api.translations[1].name, 'Bankdrücken');
      expect(
        api.translations[1].aliases.map((a) => a.alias).toList(),
        ['Flachbankdrücken'],
      );
    });
  });

  group('copyWith', () {
    test('replaces only the named fields', () {
      const original = AddExerciseState(author: 'Alice', exerciseNameEn: 'Press');

      final copy = original.copyWith(author: 'Bob');

      expect(copy.author, 'Bob');
      expect(copy.exerciseNameEn, 'Press');
    });
  });
}
