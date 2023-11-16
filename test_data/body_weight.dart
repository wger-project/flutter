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

final weightEntry1 = WeightEntry(id: 1, weight: 80, date: DateTime(2021, 01, 01));
final weightEntry2 = WeightEntry(id: 2, weight: 81, date: DateTime(2021, 01, 10));

List<WeightEntry> getWeightEntries() {
  return [weightEntry1, weightEntry2];
}
