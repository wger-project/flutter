/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:wger/features/routines/models/base_config.dart';
import 'package:wger/features/routines/models/requirement_rules.dart';
import 'package:wger/features/routines/models/slot_entry.dart';

import '../../../../test_data/exercises.dart';
import '../../../fixtures/fixture_reader.dart';

void main() {
  test('Checks that the data is correctly read from the server', () {
    final apiResponse = fixture('routines/slot_entry.json');

    final slotEntry = SlotEntry.fromJson(json.decode(apiResponse));
    expect(slotEntry.id, 143);
    expect(slotEntry.exerciseObjOrNull, isNull);
    expect(slotEntry.slotId, 140);
    expect(slotEntry.order, 2);
    expect(slotEntry.config, null);
    expect(slotEntry.repetitionUnitId, 1);
    expect(slotEntry.repetitionRounding, 1.25);
    expect(slotEntry.weightUnitId, 1);
    expect(slotEntry.weightRounding, 2.5);
    expect(slotEntry.repetitionsConfigs.length, 1);
    expect(slotEntry.repetitionsConfigs[0].id, 139);
    expect(slotEntry.maxRepetitionsConfigs.length, 1);
    expect(slotEntry.weightConfigs.length, 1);
    expect(slotEntry.maxWeightConfigs.length, 1);
    expect(slotEntry.nrOfSetsConfigs.length, 1);
    expect(slotEntry.maxNrOfSetsConfigs.length, 1);
    expect(slotEntry.rirConfigs.length, 1);
    expect(slotEntry.maxRirConfigs.length, 0);
    expect(slotEntry.restTimeConfigs.length, 1);
    expect(slotEntry.maxRestTimeConfigs.length, 1);
  });

  test('withData leaves the weight unit unset so the profile default applies', () {
    final slotEntry = SlotEntry.withData(slotId: 1, exercise: testSquats);

    expect(slotEntry.weightUnitId, isNull);
    expect(slotEntry.weightUnitObj, isNull);
  });

  test('Checks that an empty model correctly calculates hasProgressionRules', () {
    final slotEntry = SlotEntry.empty();
    expect(slotEntry.hasProgressionRules, false);
  });

  test('Checks that an model with data correctly calculates hasProgressionRules', () {
    final slotEntry = SlotEntry.empty();
    slotEntry.weightConfigs.add(BaseConfig.firstIteration(3, 1));
    slotEntry.weightConfigs.add(BaseConfig.firstIteration(4, 1));
    expect(slotEntry.hasProgressionRules, true);
  });

  test('hasProgressionRules stays true after removing the duplicated branch', () {
    // Regression test for the removed duplicate code: previously
    // `maxWeightConfigs.length > 1` appeared twice in the OR chain.
    final slotEntry = SlotEntry.empty();
    slotEntry.maxWeightConfigs.add(BaseConfig.firstIteration(22, 3));
    slotEntry.maxWeightConfigs.add(BaseConfig.firstIteration(1, 3));

    expect(slotEntry.hasProgressionRules, true);
  });

  test('a single-iteration entry has no progression rules', () {
    final slotEntry = SlotEntry.empty();
    slotEntry.maxWeightConfigs.add(BaseConfig.firstIteration(22, 3));

    expect(slotEntry.hasProgressionRules, false);
  });

  group('reading a gated progression entry from the backend (routine_structure.json)', () {
    late SlotEntry gatedEntry;

    setUp(() {
      final apiResponse = fixture('routines/routine_structure.json');
      final routineJson = json.decode(apiResponse) as Map<String, dynamic>;

      // id: 10 slot entry has weight_configs / max_weight_configs sequence.
      final armsDay = (routineJson['days'] as List).firstWhere((d) => d['id'] == 10);
      final entryJson = armsDay['slots'][0]['entries'][0];
      gatedEntry = SlotEntry.fromJson(entryJson);
    });

    test('parses all three weight iterations', () {
      expect(gatedEntry.weightConfigs.length, 3);
      expect(gatedEntry.weightConfigs[0].iteration, 1);
      expect(gatedEntry.weightConfigs[1].iteration, 2);
      expect(gatedEntry.weightConfigs[2].iteration, 8);
    });

    test('is flagged as having progression rules', () {
      expect(gatedEntry.hasProgressionRules, true);
    });

    test('the repeating +1kg step carries an (empty) requirements map, not null', () {
      final steppingConfig = gatedEntry.weightConfigs[1];

      expect(steppingConfig.repeat, true);
      expect(steppingConfig.requirements, isNotNull);
      expect(ConfigRequirements.fromMap(steppingConfig.requirements)!.isEmpty, isTrue);
    });

    test('getConfigsByType(ConfigType.maxWeight) returns the parsed max_weight_configs list', () {
      expect(gatedEntry.getConfigsByType(ConfigType.maxWeight), gatedEntry.maxWeightConfigs);
      expect(gatedEntry.getConfigsByType(ConfigType.maxWeight).length, 3);
    });
  });
  group('exercise hydration', () {
    SlotEntry makeEntry() => SlotEntry(
      id: 42,
      slotId: 1,
      exerciseId: 1,
      repetitionUnitId: 1,
      repetitionRounding: 1,
      weightUnitId: 1,
      weightRounding: 1.25,
    );

    test('reading an unhydrated exercise throws a descriptive error', () {
      expect(
        () => makeEntry().exerciseObj,
        throwsA(isA<StateError>().having((e) => e.message, 'message', contains('42'))),
      );
    });

    test('setting the exercise hydrates the entry', () {
      final entry = makeEntry()..exercise = testBenchPress;

      expect(entry.exerciseObj.id, testBenchPress.id);
      expect(entry.exerciseObjOrNull, isNotNull);
      expect(entry.exerciseId, testBenchPress.id);
    });
  });
}
