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

import 'package:wger/models/exercises/base.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/exercises/language.dart';
import 'package:wger/models/exercises/muscle.dart';

const tLanguage1 = Language(id: 1, shortName: 'de', fullName: 'Deutsch');
const tLanguage2 = Language(id: 2, shortName: 'en', fullName: 'English');

const tMuscle1 = Muscle(id: 1, name: 'Flutterus maximus', isFront: true);
const tMuscle2 = Muscle(id: 2, name: 'Biceps', isFront: true);
const tMuscle3 = Muscle(id: 3, name: 'Booty', isFront: false);

const tCategory1 = ExerciseCategory(id: 1, name: 'Arms');
const tCategory2 = ExerciseCategory(id: 2, name: 'Legs');
const tCategory3 = ExerciseCategory(id: 3, name: 'Abs');
const tCategory4 = ExerciseCategory(id: 4, name: 'Shoulders');

const tEquipment1 = Equipment(id: 1, name: 'Bench');
const tEquipment2 = Equipment(id: 1, name: 'Dumbbell');
const tEquipment3 = Equipment(id: 2, name: 'Matress');

final tBase1 = ExerciseBase(
  id: 1,
  uuid: 'uuid1',
  creationDate: DateTime(2021, 09, 01),
  updateDate: DateTime(2021, 09, 10),
  category: tCategory1,
  equipment: const [tEquipment1, tEquipment2],
  muscles: const [tMuscle1, tMuscle2],
  musclesSecondary: const [tMuscle3],
);

final tBase2 = ExerciseBase(
  id: 2,
  uuid: 'uuid2',
  creationDate: DateTime(2021, 08, 01),
  updateDate: DateTime(2021, 08, 10),
  category: tCategory2,
  equipment: const [tEquipment2],
  muscles: const [tMuscle1],
  musclesSecondary: const [tMuscle2],
);

final tBase3 = ExerciseBase(
  id: 3,
  uuid: 'uuid3',
  creationDate: DateTime(2021, 08, 01),
  updateDate: DateTime(2021, 08, 01),
  category: tCategory3,
  equipment: const [tEquipment2],
  muscles: const [tMuscle1],
  musclesSecondary: const [tMuscle2],
);

final tExercise1 = Exercise(
  id: 1,
  uuid: 'uuid',
  creationDate: DateTime(2021, 1, 15),
  name: 'test exercise 1',
  description: 'add clever text',
  base: tBase1,
  language: tLanguage1,
);

final tExercise2 = Exercise(
  id: 2,
  uuid: '111-2222-44444',
  creationDate: DateTime(2021, 1, 15),
  name: 'test exercise 2',
  description: 'Lorem ipsum etc',
  base: tBase2,
  language: tLanguage2,
);

final tExercise3 = Exercise(
  id: 3,
  uuid: 'a3b6c7bb-9d22-4119-a5fc-818584d5e9bc',
  creationDate: DateTime(2021, 4, 1),
  name: 'test exercise 3',
  description: 'The man in black fled across the desert, and the gunslinger followed',
  base: tBase3,
  language: tLanguage2,
);

List<Exercise> getTestExercises() {
  return [tExercise1, tExercise2, tExercise3];
}

List<ExerciseBase> getTestExerciseBases() {
  return getTestExercises().map((e) => e.baseObj).toList();
}
