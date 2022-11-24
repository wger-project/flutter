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
const tLanguage3 = Language(id: 3, shortName: 'fr', fullName: 'Français');

const tMuscle1 = Muscle(id: 1, name: 'Flutterus maximus', nameEn: 'Flutterus', isFront: true);
const tMuscle2 = Muscle(id: 2, name: 'Biceps brachii', nameEn: 'Biceps', isFront: true);
const tMuscle3 = Muscle(id: 3, name: 'Gluteus maximus', nameEn: 'Booty', isFront: false);

const tCategory1 = ExerciseCategory(id: 1, name: 'Arms');
const tCategory2 = ExerciseCategory(id: 2, name: 'Legs');
const tCategory3 = ExerciseCategory(id: 3, name: 'Abs');
const tCategory4 = ExerciseCategory(id: 4, name: 'Shoulders');
const tCategory5 = ExerciseCategory(id: 5, name: 'Calves');

const tEquipment1 = Equipment(id: 1, name: 'Bench');
const tEquipment2 = Equipment(id: 1, name: 'Dumbbell');
const tEquipment3 = Equipment(id: 2, name: 'Matress');

final benchPress = ExerciseBase(
  id: 1,
  uuid: '364f196c-881b-4839-8bfc-9e8f651521b6',
  creationDate: DateTime(2021, 09, 01),
  updateDate: DateTime(2021, 09, 10),
  category: tCategory1,
  equipment: const [tEquipment1, tEquipment2],
  muscles: const [tMuscle1, tMuscle2],
  musclesSecondary: const [tMuscle3],
);

final crunches = ExerciseBase(
  id: 2,
  uuid: '82415754-fc4c-49ea-8ca7-1516dd36d5a0',
  creationDate: DateTime(2021, 08, 01),
  updateDate: DateTime(2021, 08, 10),
  category: tCategory2,
  equipment: const [tEquipment2],
  muscles: const [tMuscle1],
  musclesSecondary: const [tMuscle2],
);

final deadLift = ExerciseBase(
  id: 3,
  uuid: 'ca84e2c5-5608-4d6d-ba57-6d4b6b5e7acd',
  creationDate: DateTime(2021, 08, 01),
  updateDate: DateTime(2021, 08, 01),
  category: tCategory3,
  equipment: const [tEquipment2],
  muscles: const [tMuscle1],
  musclesSecondary: const [tMuscle2],
);

final curls = ExerciseBase(
  id: 4,
  uuid: '361f024c-fdf8-4146-b7d7-0c1b67c58141',
  creationDate: DateTime(2021, 08, 01),
  updateDate: DateTime(2021, 08, 01),
  category: tCategory3,
  equipment: const [tEquipment2],
  muscles: const [tMuscle1],
  musclesSecondary: const [tMuscle2],
);
final squats = ExerciseBase(
  id: 5,
  uuid: '361f024c-fdf8-4146-b7d7-0c1b67c58141',
  creationDate: DateTime(2021, 08, 01),
  updateDate: DateTime(2021, 08, 01),
  category: tCategory3,
  equipment: const [tEquipment2],
  muscles: const [tMuscle1],
  musclesSecondary: const [tMuscle2],
);
final sideRaises = ExerciseBase(
  id: 6,
  uuid: '721ff972-c568-41e3-8cf5-cf1e5c5c801c',
  creationDate: DateTime(2022, 11, 01),
  updateDate: DateTime(2022, 11, 01),
  category: tCategory4,
  equipment: const [tEquipment2],
  muscles: const [tMuscle1],
  musclesSecondary: const [tMuscle2],
);

final benchPressDe = Exercise(
  id: 1,
  uuid: 'f4cc326b-e497-4bd7-a71d-0eb1db522743',
  creationDate: DateTime(2021, 1, 15),
  name: 'Bankdrücken',
  description: 'add clever text',
  baseId: benchPress.id,
  language: tLanguage1,
);
final benchPressEn = Exercise(
  id: 7,
  uuid: 'f4cc326b-e497-4bd7-a71d-0eb1db522743',
  creationDate: DateTime(2021, 1, 15),
  name: 'Bench press',
  description: 'add clever text',
  baseId: benchPress.id,
  language: tLanguage1,
);

final deadLiftEn = Exercise(
  id: 2,
  uuid: 'b7f51a1a-0368-4dfc-a03c-d629a4089b4a',
  creationDate: DateTime(2021, 1, 15),
  name: 'Dead Lift',
  description: 'Lorem ipsum etc',
  baseId: crunches.id,
  language: tLanguage2,
);

final crunchesFr = Exercise(
  id: 3,
  uuid: 'd83f572d-add5-48dc-89cf-75f6770284f1',
  creationDate: DateTime(2021, 4, 1),
  name: 'Crunches',
  description: 'The man in black fled across the desert, and the gunslinger followed',
  baseId: deadLift.id,
  language: tLanguage3,
);

final crunchesDe = Exercise(
  id: 4,
  uuid: 'a3e96c1d-b35f-4b0e-9cf4-ca37666cf521',
  creationDate: DateTime(2021, 4, 1),
  name: 'Crunches',
  description: 'The story so far: in the beginning, the universe was created',
  baseId: deadLift.id,
  language: tLanguage1,
);

final crunchesEn = Exercise(
  id: 5,
  uuid: '8c49a816-2247-4116-94bb-b5c0ce09c609',
  creationDate: DateTime(2021, 4, 1),
  name: 'test exercise 5',
  description: 'I am an invisible man',
  baseId: deadLift.id,
  language: tLanguage2,
);

final curlsEn = Exercise(
  id: 6,
  uuid: '259a637e-957f-4fe1-b61b-f56e3793ebcd',
  creationDate: DateTime(2021, 4, 1),
  name: 'Curls',
  description: 'It was a bright cold day in April, and the clocks were striking thirteen',
  baseId: curls.id,
  language: tLanguage2,
);

final squatsEn = Exercise(
  id: 8,
  uuid: '259a637e-957f-4fe1-b61b-f56e3793ebcd',
  creationDate: DateTime(2021, 4, 1),
  name: 'Squats',
  description: 'It was a bright cold day in April, and the clocks were striking thirteen',
  baseId: curls.id,
  language: tLanguage2,
);

final sideRaisesEn = Exercise(
  id: 9,
  uuid: '6bf89ad0-5a43-4e98-91d3-a8c6886c9712',
  creationDate: DateTime(2022, 11, 1),
  name: 'Side raises',
  description: 'It was a bright cold day in April, and the clocks were striking thirteen',
  baseId: curls.id,
  language: tLanguage2,
);

List<Exercise> getTestExercises() {
  return [benchPressDe, deadLiftEn, crunchesFr];
}

List<ExerciseBase> getTestExerciseBases() {
  benchPress.exercises = [benchPressEn, benchPressDe];
  crunches.exercises = [crunchesEn, crunchesDe, crunchesFr];
  deadLift.exercises = [deadLiftEn];
  curls.exercises = [curlsEn];
  squats.exercises = [squatsEn];
  sideRaises.exercises = [sideRaisesEn];

  return [benchPress, crunches, deadLift, curls, squats, sideRaises];
}
