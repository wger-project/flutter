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

import 'package:flutter_test/flutter_test.dart';
import 'package:wger/models/workouts/repetition_unit.dart';
import 'package:wger/models/workouts/setting.dart';
import 'package:wger/models/workouts/weight_unit.dart';

void main() {
  group('Test the singleSettingRepText method', () {
    test('Default rep and weight units, no RiR', () async {
      const repUnit = RepetitionUnit(id: 1, name: 'mol');
      const weightUnit = WeightUnit(id: 1, name: 'mg');

      final setting = Setting.empty();
      setting.reps = 2;
      setting.weight = 30;
      setting.rir = '';
      setting.repetitionUnit = repUnit;
      setting.weightUnit = weightUnit;
      expect(setting.singleSettingRepText, '2 × 30 mg');
    });

    test('Default rep and weight units', () async {
      const repUnit = RepetitionUnit(id: 1, name: 'mol');
      const weightUnit = WeightUnit(id: 1, name: 'mg');

      final setting = Setting.empty();
      setting.reps = 2;
      setting.weight = 30;
      setting.rir = '1.5';
      setting.repetitionUnit = repUnit;
      setting.weightUnit = weightUnit;
      expect(setting.singleSettingRepText, '2 × 30 mg \n (1.5 RiR)');
    });

    test('No weight, default rep and weight units', () async {
      const repUnit = RepetitionUnit(id: 1, name: 'mol');
      const weightUnit = WeightUnit(id: 1, name: 'mg');

      final setting = Setting.empty();
      setting.reps = 2;
      setting.weight = null;
      setting.rir = '1.5';
      setting.repetitionUnit = repUnit;
      setting.weightUnit = weightUnit;
      expect(setting.singleSettingRepText, '2 mol \n (1.5 RiR)');
    });

    test('Custom rep and weight units, no RiR', () async {
      const repUnit = RepetitionUnit(id: 2, name: 'mol');
      const weightUnit = WeightUnit(id: 2, name: 'mg');

      final setting = Setting.empty();
      setting.reps = 2;
      setting.weight = 30;
      setting.rir = '';
      setting.repetitionUnit = repUnit;
      setting.weightUnit = weightUnit;
      expect(setting.singleSettingRepText, '2 mol × 30 mg');
    });

    test('Custom rep and weight units, RiR', () async {
      const repUnit = RepetitionUnit(id: 2, name: 'mol');
      const weightUnit = WeightUnit(id: 2, name: 'mg');

      final setting = Setting.empty();
      setting.reps = 2;
      setting.weight = 30;
      setting.rir = '3';
      setting.repetitionUnit = repUnit;
      setting.weightUnit = weightUnit;
      expect(setting.singleSettingRepText, '2 mol × 30 mg \n (3 RiR)');
    });
  });
}
