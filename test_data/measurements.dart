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

import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';

final testMeasurementEntry1 = MeasurementEntry(
  id: '1',
  categoryId: '1',
  date: DateTime(2022, 9, 10),
  value: 30,
  notes: '',
);
final testMeasurementEntry2 = MeasurementEntry(
  id: '2',
  categoryId: '1',
  date: DateTime(2022, 10, 5),
  value: 25,
  notes: '',
);
final testMeasurementEntry3 = MeasurementEntry(
  id: '3',
  categoryId: '1',
  date: DateTime(2022, 10, 10),
  value: 17,
  notes: '',
);
final testMeasurementEntry4 = MeasurementEntry(
  id: '4',
  categoryId: '1',
  date: DateTime(2022, 11, 1),
  value: 17,
  notes: '',
);
final testMeasurementEntry5 = MeasurementEntry(
  id: '5',
  categoryId: '1',
  date: DateTime(2022, 11, 10),
  value: 20,
  notes: '',
);
final testMeasurementEntry6 = MeasurementEntry(
  id: '6',
  categoryId: '1',
  date: DateTime(2022, 11, 15),
  value: 23,
  notes: '',
);

final testMeasurementEntry7 = MeasurementEntry(
  id: '7',
  categoryId: '2',
  date: DateTime(2026, 02, 1),
  value: 40,
  notes: '',
);

final testMeasurementEntry8 = MeasurementEntry(
  id: '8',
  categoryId: '2',
  date: DateTime(2026, 03, 14),
  value: 45,
  notes: '',
);

final testNeasurementEntry9 = MeasurementEntry(
  id: 'e1',
  categoryId: 'sys',
  date: DateTime(2026, 1, 1),
  value: 120,
  notes: '',
);

final testNeasurementEntry10 = MeasurementEntry(
  id: 'e2',
  categoryId: 'dia',
  date: DateTime(2026, 1, 1),
  value: 80,
  notes: '',
);

/// Multi-value group: blood pressure with systolic/diastolic components.
final testMeasurementCategoryBloodPressure = MeasurementCategory(
  id: 'bp',
  name: 'Blood pressure',
  unit: 'mmHg',
  metricType: MetricType.bloodPressure,
  children: [testMeasurementCategorySystolic, testMeasurementCategoryDiastolic],
);

final testMeasurementCategorySystolic = MeasurementCategory(
  id: 'sys',
  name: 'Systolic',
  unit: 'mmHg',
  parentId: 'bp',
  order: 0,
);

final testMeasurementCategoryDiastolic = MeasurementCategory(
  id: 'dia',
  name: 'Diastolic',
  unit: 'mmHg',
  parentId: 'bp',
  order: 1,
);

/// The blood pressure group as a flat list (parent first) with the children
/// attached to the parent, matching the shape the repository's watchAll()
/// returns. Not included in [getMeasurementCategories].
List<MeasurementCategory> getBloodPressureGroup() {
  return [
    testMeasurementCategoryBloodPressure,
    testMeasurementCategorySystolic,
    testMeasurementCategoryDiastolic,
  ];
}

List<MeasurementCategory> getMeasurementCategories() {
  return [
    MeasurementCategory(
      id: '1',
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
    ),
    MeasurementCategory(
      id: '2',
      name: 'Biceps',
      unit: 'cm',
      entries: [
        testMeasurementEntry7,
        testMeasurementEntry8,
      ],
    ),
  ];
}
