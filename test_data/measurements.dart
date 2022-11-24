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

import 'package:wger/models/measurements/measurement_category.dart';
import 'package:wger/models/measurements/measurement_entry.dart';

final e1 = MeasurementEntry(id: 1, category: 1, date: DateTime(2022, 9, 10), value: 30, notes: '');
final e2 = MeasurementEntry(id: 2, category: 1, date: DateTime(2022, 10, 5), value: 25, notes: '');
final e3 = MeasurementEntry(id: 3, category: 1, date: DateTime(2022, 10, 10), value: 17, notes: '');
final e4 = MeasurementEntry(id: 4, category: 1, date: DateTime(2022, 11, 1), value: 17, notes: '');
final e5 = MeasurementEntry(id: 5, category: 1, date: DateTime(2022, 11, 10), value: 20, notes: '');
final e6 = MeasurementEntry(id: 6, category: 1, date: DateTime(2022, 11, 15), value: 23, notes: '');

List<MeasurementCategory> getMeasurementCategories() {
  final entries = [e1, e2, e3, e4, e5, e6];
  final category = MeasurementCategory(id: 1, name: 'Body fat', unit: '%', entries: entries);

  return [category];
}
