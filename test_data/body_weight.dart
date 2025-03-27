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

import 'package:wger/models/body_weight/weight_entry.dart';

final testWeightEntry1 = WeightEntry(id: 1, weight: 80, date: DateTime(2021, 01, 01));
final testWeightEntry2 = WeightEntry(id: 2, weight: 81, date: DateTime(2021, 01, 10));

List<WeightEntry> getWeightEntries() {
  return [testWeightEntry1, testWeightEntry2];
}

List<WeightEntry> getScreenshotWeightEntries() {
  return [
    WeightEntry(id: 1, weight: 86, date: DateTime(2021, 01, 01)),
    WeightEntry(id: 2, weight: 81, date: DateTime(2021, 01, 10)),
    WeightEntry(id: 3, weight: 82, date: DateTime(2021, 01, 20)),
    WeightEntry(id: 4, weight: 83, date: DateTime(2021, 01, 30)),
    WeightEntry(id: 5, weight: 86, date: DateTime(2021, 02, 20)),
    WeightEntry(id: 6, weight: 90, date: DateTime(2021, 02, 28)),
    WeightEntry(id: 7, weight: 91, date: DateTime(2021, 03, 20)),
    WeightEntry(id: 8, weight: 91.1, date: DateTime(2021, 03, 30)),
    WeightEntry(id: 9, weight: 90, date: DateTime(2021, 05, 1)),
    WeightEntry(id: 10, weight: 91, date: DateTime(2021, 6, 5)),
    WeightEntry(id: 11, weight: 89, date: DateTime(2021, 6, 20)),
    WeightEntry(id: 12, weight: 88, date: DateTime(2021, 7, 15)),
    WeightEntry(id: 13, weight: 86, date: DateTime(2021, 7, 20)),
    WeightEntry(id: 14, weight: 83, date: DateTime(2021, 7, 30)),
    WeightEntry(id: 15, weight: 80, date: DateTime(2021, 8, 10)),
  ];
}
