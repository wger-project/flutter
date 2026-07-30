/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020 - 2026 wger Team
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

import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';

/// Body weight entries are measurements in the user's official body weight
/// category (metric_type=body_weight, is_official=true), created by the server.
const testBodyWeightCategoryId = 'bw';

final testWeightEntry1 = MeasurementEntry(
  id: '1',
  categoryId: testBodyWeightCategoryId,
  value: 80.0,
  date: DateTime.utc(2021, 01, 01, 15, 30),
  notes: '',
);
final testWeightEntry2 = MeasurementEntry(
  id: '2',
  categoryId: testBodyWeightCategoryId,
  value: 81.0,
  date: DateTime.utc(2021, 01, 10, 10, 0),
  notes: '',
);

/// Entry recorded in pounds (extra_data.unit); 176.4 lb are 80.01 kg
final testWeightEntryLb = MeasurementEntry(
  id: '3',
  categoryId: testBodyWeightCategoryId,
  value: 176.4,
  date: DateTime.utc(2021, 01, 20, 8, 0),
  notes: '',
  extraData: const {'unit': 'lb'},
);

/// The official category with [entries] attached. Entries default to the two
/// test entries, newest first, matching the repository's watchAll() order.
MeasurementCategory getBodyWeightCategory([List<MeasurementEntry>? entries]) {
  return MeasurementCategory(
    id: testBodyWeightCategoryId,
    name: 'Weight',
    unit: 'kg',
    metricType: MetricType.bodyWeight,
    isOfficial: true,
    entries: entries ?? [testWeightEntry2, testWeightEntry1],
  );
}

MeasurementCategory getScreenshotBodyWeightCategory() {
  MeasurementEntry entry(String id, num value, DateTime date) => MeasurementEntry(
    id: id,
    categoryId: testBodyWeightCategoryId,
    value: value,
    date: date,
    notes: '',
  );

  return getBodyWeightCategory([
    entry('15', 80, DateTime.utc(2021, 8, 10)),
    entry('14', 83, DateTime.utc(2021, 7, 30)),
    entry('13', 86, DateTime.utc(2021, 7, 20)),
    entry('12', 88, DateTime.utc(2021, 7, 15)),
    entry('11', 89, DateTime.utc(2021, 6, 20)),
    entry('10', 91, DateTime.utc(2021, 6, 5)),
    entry('9', 90, DateTime.utc(2021, 05, 1)),
    entry('8', 91.1, DateTime.utc(2021, 03, 30)),
    entry('7', 91, DateTime.utc(2021, 03, 20)),
    entry('6', 90, DateTime.utc(2021, 02, 28)),
    entry('5', 86, DateTime.utc(2021, 02, 20)),
    entry('4', 83, DateTime.utc(2021, 01, 30)),
    entry('3', 82, DateTime.utc(2021, 01, 20)),
    entry('2', 81, DateTime.utc(2021, 01, 10)),
    entry('1', 86, DateTime.utc(2021, 01, 01)),
  ]);
}
