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

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:wger/features/routines/models/set_config_data.dart';

import '../../../fixtures/fixture_reader.dart';

void main() {
  Map<String, dynamic> firstSet() {
    final days = jsonDecode(fixture('routines/routine_date_sequence_gym.json')) as List;
    return Map<String, dynamic>.from(days.first['slots'][0]['sets'][0] as Map);
  }

  test('Reads the short text, older servers send none', () {
    final json = firstSet();
    expect(SetConfigData.fromJson(json).textReprShort, isNull);

    json['text_repr_short'] = '10 × 100 kg';
    expect(SetConfigData.fromJson(json).textReprShort, '10 × 100 kg');
  });
}
