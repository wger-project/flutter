/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2025 wger Team
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

import 'package:json_annotation/json_annotation.dart';
import 'package:wger/helpers/json.dart';
import 'package:wger/models/trophies/trophy.dart';

part 'user_trophy_progression.g.dart';

@JsonSerializable()
class UserTrophyProgression {
  @JsonKey(required: true)
  final Trophy trophy;

  @JsonKey(required: true, name: 'is_earned')
  final bool isEarned;

  @JsonKey(required: true, name: 'earned_at', fromJson: utcIso8601ToLocalDateNull)
  final DateTime? earnedAt;

  /// Progress towards earning the trophy (0-100%)
  @JsonKey(required: true)
  final num progress;

  /// Current value towards the trophy goal (e.g., number of workouts completed)
  @JsonKey(required: true, name: 'current_value', fromJson: stringToNumNull)
  num? currentValue;

  /// Target value to achieve the trophy goal
  @JsonKey(required: true, name: 'target_value', fromJson: stringToNumNull)
  num? targetValue;

  /// Human-readable progress display (e.g., "3 / 10" or "51%")
  @JsonKey(required: true, name: 'progress_display')
  String? progressDisplay;

  UserTrophyProgression({
    required this.trophy,
    required this.isEarned,
    required this.earnedAt,
    required this.progress,
    required this.currentValue,
    required this.targetValue,
    this.progressDisplay,
  });

  // Boilerplate
  factory UserTrophyProgression.fromJson(Map<String, dynamic> json) =>
      _$UserTrophyProgressionFromJson(json);

  Map<String, dynamic> toJson() => _$UserTrophyProgressionToJson(this);
}
