/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 wger Team
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

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wger/features/exercises/models/exercise.dart';
import 'package:wger/features/routines/models/weight_unit.dart';

part 'added_exercise.freezed.dart';

/// An exercise added in gym mode that is not part of the routine
@freezed
class AddedExercise with _$AddedExercise {
  /// Key of the page the exercise follows
  final String afterPageKey;

  final Exercise exercise;

  /// Borrowed from the page it follows, the logs need one
  final int slotEntryId;

  final WeightUnit? weightUnit;

  const AddedExercise({
    required this.afterPageKey,
    required this.exercise,
    required this.slotEntryId,
    this.weightUnit,
  });
}
