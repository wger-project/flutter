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

import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/exercises/muscle.dart';

const muscle1 = Muscle(id: 1, name: 'Flutterus maximus', isFront: true);
const muscle2 = Muscle(id: 2, name: 'Biceps', isFront: true);
const muscle3 = Muscle(id: 3, name: 'Booty', isFront: false);

const category1 = ExerciseCategory(id: 1, name: 'Arms');
const category2 = ExerciseCategory(id: 2, name: 'Legs');
const category3 = ExerciseCategory(id: 3, name: 'Abs');

const equipment1 = Equipment(id: 1, name: 'Bench');
const equipment2 = Equipment(id: 1, name: 'Dumbbell');

final exercise1 = Exercise(
  id: 1,
  uuid: 'uuid',
  creationDate: DateTime(2021, 1, 15),
  name: 'test exercise 1',
  description: 'add clever text',
  category: category1,
  categoryId: 1,
  muscles: [muscle1, muscle2],
  musclesSecondary: [muscle3],
  equipment: [equipment1, equipment2],
);

final exercise2 = Exercise(
  id: 2,
  uuid: '111-2222-44444',
  creationDate: DateTime(2021, 1, 15),
  name: 'test exercise 2',
  description: 'Lorem ipsum etc',
  category: category2,
  categoryId: 2,
  muscles: [muscle1],
  musclesSecondary: [muscle2],
  equipment: [equipment2],
);

final exercise3 = Exercise(
  id: 3,
  uuid: 'a3b6c7bb-9d22-4119-a5fc-818584d5e9bc',
  creationDate: DateTime(2021, 4, 1),
  name: 'test exercise 3',
  description: 'The man in black fled across the desert, and the gunslinger followed',
  category: category3,
  categoryId: 3,
  muscles: [muscle1],
  musclesSecondary: [muscle2],
  equipment: [equipment2],
);
