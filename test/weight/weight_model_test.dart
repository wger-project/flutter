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
import 'package:wger/models/body_weight/weight_entry.dart';

void main() {
  group('fetchPost', () {
    test('Test that the weight entries are correctly converted to json', () async {
      WeightEntry weightEntry = WeightEntry(id: 1, weight: 80, date: DateTime(2020, 12, 31));
      expect(weightEntry.toJson(), {'id': 1, 'weight': '80', 'date': '2020-12-31'});

      weightEntry = WeightEntry(id: 2, weight: 70.2, date: DateTime(2020, 12, 01));
      expect(weightEntry.toJson(), {'id': 2, 'weight': '70.2', 'date': '2020-12-01'});
    });

    test('Test that the weight entries are correctly converted from json', () async {
      final WeightEntry weightEntryObj =
          WeightEntry(id: 1, weight: 80, date: DateTime(2020, 12, 31));
      final WeightEntry weightEntry = WeightEntry.fromJson({
        'id': 1,
        'weight': '80',
        'date': '2020-12-31',
      });
      expect(weightEntry.id, weightEntryObj.id);
      expect(weightEntry.weight, weightEntryObj.weight);
      expect(weightEntry.date, weightEntryObj.date);
    });
  });

  group('model', () {
    test('Test the individual values from the model', () {
      WeightEntry weightModel;
      //_weightModel = WeightEntry();
      weightModel = WeightEntry(id: 1, weight: 80, date: DateTime(2020, 10, 01));

      expect(weightModel.id, 1);
      expect(weightModel.weight, 80);
      expect(weightModel.date, DateTime(2020, 10, 01));
    });
  });
}
