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

import 'package:wger/models/measurements/measurement_category.dart';
import 'package:wger/models/measurements/measurement_entry.dart';

final testMeasurementEntry1 = MeasurementEntry(
  uuid: '1',
  categoryId: 1,
  date: DateTime(2022, 9, 10),
  value: 30,
  notes: '',
);
final testMeasurementEntry2 = MeasurementEntry(
  uuid: '2',
  categoryId: 1,
  date: DateTime(2022, 10, 5),
  value: 25,
  notes: '',
);
final testMeasurementEntry3 = MeasurementEntry(
  uuid: '3',
  categoryId: 1,
  date: DateTime(2022, 10, 10),
  value: 17,
  notes: '',
);
final testMeasurementEntry4 = MeasurementEntry(
  uuid: '4',
  categoryId: 1,
  date: DateTime(2022, 11, 1),
  value: 17,
  notes: '',
);
final testMeasurementEntry5 = MeasurementEntry(
  uuid: '5',
  categoryId: 1,
  date: DateTime(2022, 11, 10),
  value: 20,
  notes: '',
);
final testMeasurementEntry6 = MeasurementEntry(
  uuid: '6',
  categoryId: 1,
  date: DateTime(2022, 11, 15),
  value: 23,
  notes: '',
);

List<MeasurementCategory> getMeasurementCategories() {
  final category = MeasurementCategory(
    uuid: '1',
    name: 'Body fat',
    unit: '%',
    entries: [
      testMeasurementEntry1,
      testMeasurementEntry2,
      testMeasurementEntry3,
      testMeasurementEntry4,
      testMeasurementEntry5,
      testMeasurementEntry6,
    ],
  );

  return [category];
}
