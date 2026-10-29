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

part 'workout_progress.freezed.dart';
part 'workout_progress.g.dart';

/// The progress through a running workout, as stored in the preferences. The
/// pages themselves are derived from the routine again and matched by key.
@freezed
sealed class WorkoutProgress with _$WorkoutProgress {
  const factory WorkoutProgress({
    required int dayId,
    required int iteration,
    required String currentPageKey,
    required DateTime workoutStart,
    required DateTime validUntil,
    @Default({}) Map<String, StoredPageProgress> pages,
  }) = _WorkoutProgress;

  factory WorkoutProgress.fromJson(Map<String, dynamic> json) => _$WorkoutProgressFromJson(json);
}

/// The stored part of a page's progress, the logged entry only by its ID
@freezed
sealed class StoredPageProgress with _$StoredPageProgress {
  const factory StoredPageProgress({
    @Default(false) bool done,
    String? logId,
    DateTime? timerStartedAt,
  }) = _StoredPageProgress;

  factory StoredPageProgress.fromJson(Map<String, dynamic> json) =>
      _$StoredPageProgressFromJson(json);
}
