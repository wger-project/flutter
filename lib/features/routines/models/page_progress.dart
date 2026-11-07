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
import 'package:wger/features/routines/models/log.dart';

part 'page_progress.freezed.dart';

/// What happened on one gym mode page during the running workout
@freezed
class PageProgress with _$PageProgress {
  /// Whether the set of a log page has been logged
  final bool done;

  /// The log saved from a log page, so revisiting the page pre-fills the form
  /// and saving updates the row instead of inserting a duplicate
  final Log? loggedEntry;

  /// When the rest of a timer page started, so the countdown keeps running
  /// while the page is not shown
  final DateTime? timerStartedAt;

  const PageProgress({this.done = false, this.loggedEntry, this.timerStartedAt});
}
