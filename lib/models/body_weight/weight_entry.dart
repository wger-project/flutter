/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020,  wger Team
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

import 'package:drift/drift.dart';
import 'package:wger/database/powersync/database.dart';

class WeightEntry {
  String? id;

  late num weight = 0;

  late DateTime date;

  WeightEntry({this.id, num? weight, DateTime? date}) {
    this.date = date ?? DateTime.now();

    if (weight != null) {
      this.weight = weight;
    }
  }

  WeightEntry copyWith({String? id, int? weight, DateTime? date}) => WeightEntry(
    id: id,
    weight: weight ?? this.weight,
    date: date ?? this.date,
  );

  WeightEntryTableCompanion toCompanion({bool includeId = false}) {
    return WeightEntryTableCompanion(
      id: includeId && id != null ? Value(id!) : const Value.absent(),
      date: Value(date),
      weight: Value(weight as double),
    );
  }
}
