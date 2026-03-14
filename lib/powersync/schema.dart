/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
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

import 'package:powersync/powersync.dart';
import 'package:wger/database/powersync/tables/exercise.dart';
import 'package:wger/database/powersync/tables/ingredient.dart';
import 'package:wger/database/powersync/tables/language.dart';
import 'package:wger/database/powersync/tables/license.dart';
import 'package:wger/database/powersync/tables/measurements.dart';
import 'package:wger/database/powersync/tables/routines.dart';
import 'package:wger/database/powersync/tables/weight.dart';

Schema schema = const Schema([
  // Core
  PowersyncLanguageTable,
  PowersyncLicenseTable,

  // Exercises
  PowersyncExerciseTable,
  PowersyncTranslationTable,
  PowersyncMuscleTable,
  PowersyncExerciseMuscleM2N,
  PowersyncExerciseSecondaryMuscleM2N,
  PowersyncEquipmentTable,
  PowersyncExerciseEquipmentM2N,
  PowersyncExerciseCategoryTable,
  PowersyncExerciseImageTable,
  PowersyncExerciseVideoTable,

  // Nutrition
  PowersyncIngredientTable,
  PowersyncIngredientImageTable,

  // Body weight
  PowersyncWeightEntryTable,

  // Measurements
  PowersyncMeasurementCategoryTable,
  PowersyncMeasurementEntryTable,

  // Routines
  PowersyncWorkoutLogTable,
  PowersyncWorkoutSessionTable,
  PowersyncRoutineRepetitionUnitTable,
  PowersyncRoutineWeightUnitTable,
]);
