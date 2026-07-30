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

/// The progress through a running workout, as stored in the preferences
///
/// Only the parts that can't be recalculated are kept. The pages themselves are
/// derived from the routine again on the next start, which is also why the
/// finished log pages are referenced by their page index: the UUIDs are
/// generated anew every time the pages are calculated.
class WorkoutProgress {
  final int dayId;
  final int iteration;
  final int currentPage;
  final DateTime workoutStart;
  final DateTime validUntil;

  /// Absolute page indices of the log pages already marked as done
  final List<int> donePageIndices;

  const WorkoutProgress({
    required this.dayId,
    required this.iteration,
    required this.currentPage,
    required this.workoutStart,
    required this.validUntil,
    required this.donePageIndices,
  });

  factory WorkoutProgress.fromJson(Map<String, dynamic> json) => WorkoutProgress(
    dayId: json['dayId'] as int,
    iteration: json['iteration'] as int,
    currentPage: json['currentPage'] as int,
    workoutStart: DateTime.parse(json['workoutStart'] as String),
    validUntil: DateTime.parse(json['validUntil'] as String),
    donePageIndices: (json['donePageIndices'] as List<dynamic>).cast<int>(),
  );

  Map<String, dynamic> toJson() => {
    'dayId': dayId,
    'iteration': iteration,
    'currentPage': currentPage,
    'workoutStart': workoutStart.toIso8601String(),
    'validUntil': validUntil.toIso8601String(),
    'donePageIndices': donePageIndices,
  };

  @override
  String toString() =>
      'WorkoutProgress('
      'dayId: $dayId, '
      'iteration: $iteration, '
      'currentPage: $currentPage, '
      'workoutStart: $workoutStart, '
      'validUntil: $validUntil, '
      'donePageIndices: $donePageIndices'
      ')';
}
