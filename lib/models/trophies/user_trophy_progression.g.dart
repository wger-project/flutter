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

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_trophy_progression.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserTrophyProgression _$UserTrophyProgressionFromJson(
  Map<String, dynamic> json,
) {
  $checkKeys(
    json,
    requiredKeys: const [
      'trophy',
      'is_earned',
      'earned_at',
      'progress',
      'current_value',
      'target_value',
      'progress_display',
    ],
  );
  return UserTrophyProgression(
    trophy: Trophy.fromJson(json['trophy'] as Map<String, dynamic>),
    isEarned: json['is_earned'] as bool,
    earnedAt: utcIso8601ToLocalDate(json['earned_at'] as String),
    progress: json['progress'] as num,
    currentValue: stringToNumNull(json['current_value'] as String?),
    targetValue: stringToNumNull(json['target_value'] as String?),
    progressDisplay: json['progress_display'] as String?,
  );
}

Map<String, dynamic> _$UserTrophyProgressionToJson(
  UserTrophyProgression instance,
) => <String, dynamic>{
  'trophy': instance.trophy,
  'is_earned': instance.isEarned,
  'earned_at': instance.earnedAt.toIso8601String(),
  'progress': instance.progress,
  'current_value': instance.currentValue,
  'target_value': instance.targetValue,
  'progress_display': instance.progressDisplay,
};
