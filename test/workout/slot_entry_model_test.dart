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
import 'package:wger/models/workouts/base_config.dart';
import 'package:wger/models/workouts/slot_entry.dart';

import '../fixtures/fixture_reader.dart';

void main() {
  test('Checks that the data is correctly read from the server', () {
    final apiResponse = fixture('routines/slot_entry.json');

    final slotEntry = SlotEntry.fromJson(json.decode(apiResponse));
    expect(slotEntry.id, 143);
    expect(slotEntry.slotId, 140);
    expect(slotEntry.order, 2);
    expect(slotEntry.config, null);
    expect(slotEntry.repetitionUnitId, 1);
    expect(slotEntry.repetitionRounding, 1.25);
    expect(slotEntry.weightUnitId, 1);
    expect(slotEntry.weightRounding, 2.5);
    expect(slotEntry.repsConfigs.length, 1);
    expect(slotEntry.repsConfigs[0].id, 139);
    expect(slotEntry.maxRepsConfigs.length, 1);
    expect(slotEntry.weightConfigs.length, 1);
    expect(slotEntry.maxWeightConfigs.length, 1);
    expect(slotEntry.nrOfSetsConfigs.length, 1);
    expect(slotEntry.maxNrOfSetsConfigs.length, 1);
    expect(slotEntry.rirConfigs.length, 1);
    expect(slotEntry.maxRirConfigs.length, 0);
    expect(slotEntry.restTimeConfigs.length, 1);
    expect(slotEntry.maxRestTimeConfigs.length, 1);
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
}
